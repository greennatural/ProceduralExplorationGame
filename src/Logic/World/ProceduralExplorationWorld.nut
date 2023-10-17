//TODO get rid of this.
::ExplorationCount <- 0;

::ProceduralExplorationWorld <- class extends ::World{
    mMapData_ = null;

    static WORLD_DEPTH = 20;
    ABOVE_GROUND = null;
    mVoxMesh_ = null;

    mActivePlaces_ = null;
    mCurrentFoundRegions_ = null;
    mRegionEntries_ = null;

    mCloudManager_ = null;

    ProceduralRegionEntry = class{
        mLandNode_ = null;
        mLandItem_ = null;
        mDecoratioNode_ = null;
        mVisible_ = false;
        mPlaces_ = null;
        constructor(node, decorationNode){
            mLandNode_ = node;
            mDecoratioNode_ = decorationNode;
            if(mLandNode_){
                mLandItem_ = mLandNode_.getAttachedObject(0);
            }
            mPlaces_ = [];
        }
        function setVisible(visible){
            mVisible_ = visible;
            setVisible_();
        }
        //Workaround to resolve the recursive setVisible from the world.
        function setVisible_(){
            if(mLandNode_){
                mLandItem_.setDatablock(mVisible_ ? "baseVoxelMaterial" : "MaskedWorld");
            }

            foreach(i in mPlaces_){
                //TODO this will be massively inefficient so improve that
                i.getSceneNode().setVisible(mVisible_);
            }
            mDecoratioNode_.setVisible(mVisible_);
        }
        function pushPlace(place){
            mPlaces_.append(place);
        }
    }

    constructor(worldId){
        base.constructor(worldId);

        mCurrentFoundRegions_ = {};
        mRegionEntries_ = {};
    }

    function setup(){
        base.setup();

        resetSessionGenMap();
    }

    function getMapData(){
        return mMapData_;
    }

    function getWorldType(){
        return WorldTypes.PROCEDURAL_EXPLORATION_WORLD;
    }

    //TODO long term remove this and generate the map data somewhere else so it can be threaded easier.
    function resetSessionGenMap(){
        local gen = ::MapGen();
        local data = {
            "seed": _random.randInt(0, 1000),
            "moistureSeed": _random.randInt(0, 1000),
            "variation": _random.randInt(0, 1000),
            "width": 400,
            "height": 400,
            "numRivers": 24,
            "seaLevel": 100,
            "numRegions": 16,
            "altitudeBiomes": [10, 100],
            "placeFrequency": [0, 1, 1, 4, 4, 30]
        };
        local outData = gen.generate(data);

        resetSession(outData);
    }

    function resetSession(mapData){
        //TODO would prefer to have the base call further up.
        createScene();

        ABOVE_GROUND = 0xFF - mapData.seaLevel;

        base.resetSession();

        mMapData_ = mapData;

        voxeliseMap();

        mCloudManager_ = CloudManager(mParentNode_, mMapData_.width, mMapData_.height);

        setupPlaces();
        createPlacedItems();

        mPlayerEntry_.setPosition(Vec3(mMapData_.width / 2, 0, -mMapData_.height / 2));
    }

    function getPositionForAppearEnemy_(enemyType){
        //TODO in future have a more sophisticated method to solve this, for instance spawn locations stored in entity defs.
        if(enemyType == EnemyId.SQUID){
            return MapGenHelpers.findRandomPositionInWater(mMapData_, 0);
        }else{
            return MapGenHelpers.findRandomPointOnLand(mMapData_, mPlayerEntry_.getPosition(), 50);
        }
    }

    function update(){
        base.update();

        mCloudManager_.update();
    }

    function updatePlayerPos(playerPos){
        base.updatePlayerPos(playerPos);

        updateCameraPosition();
    }

    function updateCameraPosition(){
        local zPos = getZForPos(mPosition_);

        local camera = ::CompositorManager.getCameraForSceneType(CompositorSceneType.EXPLORATION)
        assert(camera != null);
        local parentNode = camera.getParentNode();

        local xPos = cos(mRotation_.x)*mCurrentZoomLevel_;
        local yPos = sin(mRotation_.x)*mCurrentZoomLevel_;
        local rot = Vec3(xPos, 0, yPos);
        yPos = sin(mRotation_.y)*mCurrentZoomLevel_;
        rot += Vec3(0, yPos, 0);

        parentNode.setPosition(Vec3(mPosition_.x, zPos, mPosition_.z) + rot );
        camera.lookAt(mPosition_.x, zPos, mPosition_.z);
    }

    function processCameraMove(x, y){
        mRotation_ += Vec2(x, y) * -0.05;
        local first = PI * 0.5;
        local second = PI * 0.1;
        if(mRotation_.y > first) mRotation_.y = first;
        if(mRotation_.y < second) mRotation_.y = second;

        local mouseScroll = _input.getMouseWheelValue();
        if(mouseScroll != 0){
            mCurrentZoomLevel_ += mouseScroll;
            if(mCurrentZoomLevel_ < MIN_ZOOM) mCurrentZoomLevel_ = MIN_ZOOM;
        }

        updateCameraPosition();
    }

    function getZForPos(pos){
        //Move somewhere else.

        local x = pos.x.tointeger();
        local y = -pos.z.tointeger();

        local buf = mMapData_.voxelBuffer;
        buf.seek((x + y * mMapData_.width) * 4);
        local voxFloat = (buf.readn('i') & 0xFF).tofloat();
        local altitude = (((voxFloat - mMapData_.seaLevel) / ABOVE_GROUND) * WORLD_DEPTH).tointeger() + 1;
        local clampedAltitude = altitude < 0 ? 0 : altitude;

        return clampedAltitude * 0.4;
    }

    function createScene(){
        //mParentNode_ = _scene.getRootSceneNode().createChildSceneNode();

        if(mMapData_){
            local camera = ::CompositorManager.getCameraForSceneType(CompositorSceneType.EXPLORATION)
            assert(camera != null);
            local parentNode = camera.getParentNode();
            parentNode.setPosition(0, 40, 60);
            camera.lookAt(0, 0, 0);
            //TODO This negative coordinate is incorrect.
            //parentNode.setPosition(mMapData_.width / 2, 40, -mMapData_.height / 2);
        }

        //Create the ocean plane
        local oceanNode = mParentNode_.createChildSceneNode();
        local oceanItem = _scene.createItem("plane");
        oceanItem.setCastsShadows(false);
        oceanItem.setRenderQueueGroup(30);
        oceanItem.setDatablock("oceanUnlit");
        oceanNode.attachObject(oceanItem);
        oceanNode.setScale(500, 500, 500)
        oceanNode.setOrientation(Quat(-sqrt(0.5), 0, 0, sqrt(0.5)));

    }

    function voxeliseMap(){
        assert(mMapData_ != null);

        local parentVoxNode = mParentNode_.createChildSceneNode();
        //for(local i = 0; i < mMapData_.regionData.len(); i++){
            local regionNode = parentVoxNode.createChildSceneNode();
            //local landNode = voxeliseMapRegion_(i, parentVoxNode);
            local vox = VoxToMesh(Timer());
            local meshes = vox.createTerrainFromVoxelBlob("test", mMapData_);
            assert(meshes.len() == mMapData_.regionData.len());
            foreach(c,i in meshes){
                local decorationNode = regionNode.createChildSceneNode();

                local item = _scene.createItem(i);
                item.setRenderQueueGroup(30);
                local landNode = regionNode.createChildSceneNode();
                landNode.attachObject(item);
                landNode.setScale(1, 0.4, 1);
                landNode.setPosition(0, 0, -mMapData_.width);
                //landNode.setOrientation(Quat(-sqrt(0.5), 0, 0, sqrt(0.5)));
                landNode.setOrientation(Quat(0, 0, 0, 1));
                landNode.setVisible(true);

                mRegionEntries_.rawset(c, ProceduralRegionEntry(landNode, decorationNode));
            }
        //}
    }

    function voxeliseMapRegion_(regionIdx, parentNode){
        local width = mMapData_.width;
        local height = mMapData_.height;
        local voxData = array(width * height * WORLD_DEPTH, null);
        local buf = mMapData_.voxelBuffer;
        local bufSecond = mMapData_.secondaryVoxBuffer;
        buf.seek(0);
        bufSecond.seek(0);
        local voxVals = [
            2, 112, 0, 147, 6
        ];
        local waterVal = 192;
        local written = false;
        for(local y = 0; y < height; y++){
            for(local x = 0; x < width; x++){
                local vox = buf.readn('i');
                local region = (bufSecond.readn('i') >> 8) & 0xFF;
                local voxFloat = (vox & 0xFF).tofloat();
                if(voxFloat <= mMapData_.seaLevel) continue;
                if(region != regionIdx) continue;
                //+1 because vox values at 0 still need to be drawn.
                local altitude = (((voxFloat - mMapData_.seaLevel) / ABOVE_GROUND) * WORLD_DEPTH).tointeger() + 1;
                local voxelMeta = (vox >> 8) & MAP_VOXEL_MASK;
                local isRiver = (vox >> 8) & MapVoxelTypes.RIVER;
                if(isRiver){
                    altitude-=2;
                    if(altitude < 1) altitude = 1;
                }
                //if(voxFloat <= mMapData_.seaLevel) voxelMeta = 3;
                for(local i = 0; i < altitude; i++){
                    voxData[x + (y * width) + (i*width*height)] = isRiver ? waterVal : voxVals[voxelMeta];
                    written = true;
                }
            }
        }
        if(!written) return null;
        local vox = VoxToMesh(Timer(), 1 << 2, 0.4);
        //TODO get rid of this with the proper function to destory meshes.
        ::ExplorationCount++;
        local meshObj = vox.createMeshForVoxelData(format("worldVox%i-%i", ::ExplorationCount, regionIdx), voxData, width, height, WORLD_DEPTH);
        mVoxMesh_ = meshObj;

        local item = _scene.createItem(meshObj);
        item.setRenderQueueGroup(30);
        local landNode = parentNode.createChildSceneNode();
        landNode.attachObject(item);
        landNode.setScale(1, 1, 0.4);
        landNode.setOrientation(Quat(-sqrt(0.5), 0, 0, sqrt(0.5)));

        vox.printStats();
        landNode.setVisible(false);

        return landNode;
    }

    function setupPlaces(){
        //TODO see about getting rid of this.
        mActivePlaces_ = [];
        foreach(c,i in mMapData_.placeData){
            local placeEntry = mEntityFactory_.constructPlace(i, c, ::Base.mExplorationLogic.mGui_);
            mActivePlaces_.append(placeEntry);
            mRegionEntries_[i.region].pushPlace(placeEntry);
        }
    }

    function createPlacedItems(){
        foreach(c,i in mMapData_.placedItems){
            local node = mRegionEntries_[i.region].mDecoratioNode_;
            mEntityFactory_.constructPlacedItem(node, i, c);
            //mActivePlaces_.append(itemEntry);
        }
    }

    function getTraverseTerrainForPosition(pos){
        return ::MapGenHelpers.getTraverseTerrainForPosition(mMapData_, pos);
    }
    function getIsWaterForPosition(pos){
        return ::MapGenHelpers.getIsWaterForPosition(mMapData_, pos);
    }

    function processActiveChange_(active){
        if(!active){
            destroyEnemyMap_(mActivePlaces_);
        }

        //Re-check the visibility of the nodes.
        foreach(i in mRegionEntries_){
            i.setVisible_();
        }
    }

    function notifyPlayerVoxelChange(){
        local playerPos = mPlayerEntry_.getPosition();
        local radius = 4;

        local circleX = playerPos.x;
        local circleY = -playerPos.z;

        //The coordinates of the circle's rectangle
        local startX = circleX - radius;
        local startY = circleY - radius;
        local endX = circleX + radius;
        local endY = circleY + radius;

        //Find the actual chunk coordinates that lie within the circle's rectangle
        local startXTile = floor(startX);
        local startYTile = floor(startY);
        local endXTile = ceil(endX);
        local endYTile = ceil(endY);

        //Hold a reference to the function to avoid the mapGenHelpers lookup each time.
        local targetFunc = ::MapGenHelpers.getRegionForData;

        local foundRegions = {};
        for (local y = startYTile; y < endYTile; y++){
            for (local x = startXTile; x < endXTile; x++){
                //Go through these chunks to determine what to load.
                if(_checkRectCircleCollision(x, y, radius, circleX, circleY)){
                    //printf("Collided with %i %i", x, y);
                    //Query the voxel data and determine what the region is.
                    local targetRegion = targetFunc(mMapData_, playerPos);
                    //print("Found target region " + targetRegion);
                    foundRegions.rawset(targetRegion, true);
                }
            }
        }

        foreach(c,i in foundRegions){
            if(!mCurrentFoundRegions_.rawin(c)){
                mCurrentFoundRegions_.rawset(c, true);
                print("Found new region " + c);
                processFoundNewRegion(c);
            }
        }
    }
    function _checkRectCircleCollision(tileX, tileY, radius, circleX, circleY){
        local distX = abs(circleX - (tileX)-0.5);
        local distY = abs(circleY - (tileY)-0.5);

        if(distX > (0.5 + radius)) return false;
        if(distY > (0.5 + radius)) return false;

        if(distX <= (0.5)) return true;
        if(distY <= (0.5)) return true;

        local dx = distX - 0.5;
        local dy = distY - 0.5;

        return (dx*dx+dy*dy<=(radius*radius));
    }

    function processFoundNewRegion(regionId){
        assert(mRegionEntries_.rawin(regionId));
        local regionEntry = mRegionEntries_[regionId];
        if(regionEntry != null){
            regionEntry.setVisible(true);
        }
        mGui_.mWorldMapDisplay_.mMapViewer_.notifyRegionFound(regionId);
    }
};