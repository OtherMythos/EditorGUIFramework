::EditorGUIFramework.Object <- class{
    mId_ = null
    mBus_ = null
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
};