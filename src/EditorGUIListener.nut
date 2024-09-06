::EditorGUIFramework.Listener <- class{

    mCallback_ = null

    constructor(callback, context=null){
        if(context != null){
            mCallback_ = callback.bindenv(context);
        }else{
            mCallback_ = callback;
        }
    }

    function call(data, event){
        mCallback_(data, event);
    }
};