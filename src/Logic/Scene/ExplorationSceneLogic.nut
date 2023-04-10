::ExplorationCount <- 0;
::ExplorationSceneLogic <- class{

    mParentNode_ = null;
    mWorldData_ = null;
    mVoxMesh_ = null;

    mPlayerNode_ = null;
    mMobScale_ = Vec3(0.2, 0.2, 0.2);

    static WORLD_DEPTH = 20;
    ABOVE_GROUND = null;

    constructor(){
    }

    function setup(){
        ABOVE_GROUND = 0xFF - mWorldData_.seaLevel;
        createScene();
        voxeliseMap();
    }

    function shutdown(){
        if(mParentNode_) mParentNode_.destroyNodeAndChildren();
        if(mVoxMesh_ == null){
        }

        mParentNode_ = null;
    }

    function resetExploration(worldData){
        shutdown();
        mWorldData_ = worldData;
        setup();
    }

    function voxeliseMap(){
        assert(mWorldData_ != null);
        local width = mWorldData_.width;
        local height = mWorldData_.height;
        local voxData = array(width * height * WORLD_DEPTH, null);
        local buf = mWorldData_.voxelBuffer;
        buf.seek(0);
        local voxVals = [
            2, 112, 0, 192
        ];
        for(local y = 0; y < height; y++){
            for(local x = 0; x < width; x++){
                local vox = buf.readn('i')
                local voxFloat = (vox & 0xFF).tofloat();
                if(voxFloat <= mWorldData_.seaLevel) continue;
                local altitude = (((voxFloat - mWorldData_.seaLevel) / ABOVE_GROUND) * WORLD_DEPTH).tointeger();
                local voxelMeta = (vox >> 8) & 0x7F;
                //if(voxFloat <= mWorldData_.seaLevel) voxelMeta = 3;
                for(local i = 0; i < altitude; i++){
                    voxData[x + (y * width) + (i*width*height)] = voxVals[voxelMeta];
                }
            }
        }
        local vox = VoxToMesh(1 << 2);
        //TODO get rid of this with the proper function to destory meshes.
        ::ExplorationCount++;
        local meshObj = vox.createMeshForVoxelData("worldVox" + ::ExplorationCount, voxData, width, height, WORLD_DEPTH);
        mVoxMesh_ = meshObj;

        local item = _scene.createItem(meshObj);
        item.setRenderQueueGroup(30);
        local landNode = mParentNode_.createChildSceneNode();
        landNode.attachObject(item);
        //landNode.setScale(2, 2, 2);
        landNode.setOrientation(Quat(-sqrt(0.5), 0, 0, sqrt(0.5)));

        local stats = vox.getStats();
        printf("Stats %i", stats.numTris);
    }

    function getZForPos(pos){
        //Move somewhere else.

        local x = pos.x.tointeger();
        local y = -pos.y.tointeger();

        local buf = mWorldData_.voxelBuffer;
        buf.seek((x + y * mWorldData_.width) * 4);
        local voxFloat = (buf.readn('i') & 0xFF).tofloat();
        local altitude = (((voxFloat - mWorldData_.seaLevel) / ABOVE_GROUND) * WORLD_DEPTH).tointeger();
        local clampedAltitude = altitude < 0 ? 0 : altitude;

        return clampedAltitude;
    }

    function updatePercentage(percentage){
    }

    function appearEnemy(enemy){
        local enemyNode = mParentNode_.createChildSceneNode();
        local enemyItem = _scene.createItem("goblin.mesh");
        enemyItem.setRenderQueueGroup(30);
        enemyNode.attachObject(enemyItem);
        local zPos = getZForPos(enemy.mPos_);
        local pos = Vec3(enemy.mPos_.x, zPos, enemy.mPos_.y);
        enemyNode.setPosition(pos);
        enemyNode.setScale(mMobScale_);
        print("Adding " + pos);
    }

    function createScene(){
        mParentNode_ = _scene.getRootSceneNode().createChildSceneNode();

        if(mWorldData_){
            local camera = ::CompositorManager.getCameraForSceneType(CompositorSceneType.EXPLORATION)
            assert(camera != null);
            local parentNode = camera.getParentNode();
            parentNode.setPosition(0, 40, 60);
            camera.lookAt(0, 0, 0);
            //TODO This negative coordinate is incorrect.
            //parentNode.setPosition(mWorldData_.width / 2, 40, -mWorldData_.height / 2);
        }

        //Create the ocean plane
        local oceanNode = mParentNode_.createChildSceneNode();
        local oceanItem = _scene.createItem("plane");
        oceanItem.setRenderQueueGroup(30);
        oceanItem.setDatablock("oceanUnlit");
        oceanNode.attachObject(oceanItem);
        oceanNode.setScale(500, 500, 500)
        oceanNode.setOrientation(Quat(-sqrt(0.5), 0, 0, sqrt(0.5)));

        mPlayerNode_ = mParentNode_.createChildSceneNode();
        local playerItem = _scene.createItem("player.mesh");
        playerItem.setRenderQueueGroup(30);
        mPlayerNode_.attachObject(playerItem);
        mPlayerNode_.setScale(mMobScale_);
    }

    function updatePlayerPos(playerPos){
        local zPos = getZForPos(playerPos);

        local camera = ::CompositorManager.getCameraForSceneType(CompositorSceneType.EXPLORATION)
        assert(camera != null);
        local parentNode = camera.getParentNode();
        parentNode.setPosition(Vec3(playerPos.x, zPos + 20, playerPos.y + 20));
        camera.lookAt(playerPos.x, 0, playerPos.y);

        mPlayerNode_.setPosition(Vec3(playerPos.x, zPos, playerPos.y));
    }

    function getFoundPositionForItem(item){
        return Vec3(0, 0, 0);
    }
    function getFoundPositionForEncounter(item){
        return Vec3(0, 0, 0);
    }
};