::EditorGUIFramework.Object <- class{
    mId_ = null
    mBus_ = null
    mUserId_ = 0;
    constructor(id, bus){
        mId_ = id;
        mBus_ = bus;
    }

    function transmitEvent(event, data){
        mBus_.transmitEvent(event, data);
    }
    function transmitRequest(event, data){
        mBus_.transmitRequest(event, data);
    }

    function setUserId(id){
        mUserId_ = id;
    }
    function getUserId(){
        return mUserId_;
    }
};