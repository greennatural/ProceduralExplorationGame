::CharacterModel <- class{
    mModelType_ = CharacterModelType.NONE;
    mParentNode_ = null;
    mNodes_ = null;
    mEquipNodes_ = null;
    mRenderQueue_ = 0;

    mCurrentAnimations_ = null;

    constructor(modelType, parent, nodes, equipNodes, renderQueue=0){
        mModelType_ = modelType;
        mParentNode_ = parent;
        mNodes_ = nodes;
        mEquipNodes_ = equipNodes;
        mRenderQueue_ = renderQueue;

        mCurrentAnimations_ = {};
    }

    function destroy(){
        mCurrentAnimations_.clear();
    }

    function setOrientation(orientation){
        mParentNode_.setOrientation(orientation);
    }

    function startAnimation(animId){
        //local newAnim = _animation.createAnimation(animName, mNodes_);
        //local newAnim = _animation.createAnimation(animName, mNodes_);
        local newAnim = createAnimation(animId);
        mCurrentAnimations_.rawset(animId, newAnim);
        resetAnimTimes_();
    }
    function stopAnimation(animId){
        mCurrentAnimations_.rawdelete(animId);
    }
    function resetAnimTimes_(){
        foreach(c,i in mCurrentAnimations_){
            i.setTime(0);
        }
    }

    function createAnimation(animId){
        local target = ::CharacterModelAnims[animId];
        local targetIds = ::CharacterGenerator.mModelTypes_[mModelType_].mNodeIds;
        local targetNodes = [];
        foreach(i in target.mUsedNodes){
            assert(targetIds.rawin(i));
            targetNodes.append(mNodes_[targetIds[i]]);
        }
        assert(target.mUsedNodes.len() == targetNodes.len());

        local animationInfo = _animation.createAnimationInfo(targetNodes);
        return _animation.createAnimation(target.mName, animationInfo);
    }

    function equipToNode(item, targetNode){
        if(!mEquipNodes_.rawin(targetNode)) return;
        local targetNode = mEquipNodes_[targetNode];
        targetNode.recursiveDestroyChildren();

        if(item == null) return;

        local model = _scene.createItem(item.getMesh());
        local offsetPos = item.getEquippablePosition();
        local offsetOrientation = item.getEquippableOrientation();
        local attachNode = targetNode;
        if(offsetPos != null || offsetOrientation != null){
            local childNode = targetNode.createChildSceneNode();
            childNode.setPosition(offsetPos != null ? offsetPos : Vec3());
            childNode.setOrientation(offsetOrientation != null ? offsetOrientation : Quat());

            attachNode = childNode;
        }

        model.setRenderQueueGroup(mRenderQueue_);
        attachNode.attachObject(model);
    }
};