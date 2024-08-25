::EditorGUIFramework.Bus <- class{

    mSubscribed_ = null;

    constructor(){
        mSubscribed_ = [];
    }

    function subscribeObject(object){
        mSubscribed_.append(object);
    }

    function transmitEvent(event, data=null){
        foreach(i in mSubscribed_){
            i.notifyBusEvent(event, data);
        }
    }

    function transmitRequest(request, data){
        foreach(i in mSubscribed_){
            if(!i.rawin("notifyBusRequest")) continue;
            local result = i.notifyBusRequest(request, data);
            if(result != null){
                return result;
            }
        }
    }

};