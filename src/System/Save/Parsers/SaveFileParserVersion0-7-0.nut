::SaveManager.registerParser(0, 7, 0, class extends SaveFileParser{
    constructor(){
        base.constructor(0, 7, 0);
    }

    function setup(){
        local prev = getPreviousParser();
        assert(prev != null);
        mJSONSchema_ = clone prev.mJSONSchema_;
        mDefaultData_ = clone prev.mDefaultData_;
        print(_prettyPrint(mDefaultData_));

        mJSONSchema_.quest <- OBJECT_TYPE.ANY;
        updateData(mDefaultData_);
    }

    #Override
    function updateData(data){
        data.version = getVersionString();
        data.quest <- {};
        return data;
    }

});