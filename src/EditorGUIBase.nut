
::EditorGUIFramework.Base <- class{
    mBus_ = null;
    mObjectManager_ = null;
    mWindowManager_ = null;

    mMouseButtonStates_ = null;

    constructor(){
        setupColours();
        _gui.loadSkins("script://EditorGUISkins.json");

        ::EditorGUIFramework.mInterface <- ::EditorGUIFramework.Interface();
        mBus_ = ::EditorGUIFramework.Bus();
        mObjectManager_ = ObjectManager(mBus_);
        mWindowManager_ = ::EditorGUIFramework.WindowManager(mBus_);

        mMouseButtonStates_ = array(EditorGUIFramework_MouseButton.MAX, false);

        mBus_.subscribeObject(this);
    }

    function shutdown(){

    }

    function update(){
        mWindowManager_.update();
    }

    function notifyBusEvent(event, data){

    }
    function notifyBusRequest(request, data){
        if(EditorGUIFramework_BusRequest.SET_CURSOR){
            ::EditorGUIFramework.mInterface.setCursor(data);
            return 0;
        }
        else if(EditorGUIFramework_BusRequest.RESET_CURSOR){
            ::EditorGUIFramework.mInterface.setCursor(_SYSTEM_CURSOR_ARROW);
            return 0;
        }
    }

    function setToolbar(toolbar){
        mWindowManager_.setToolbar(toolbar);
    }

    function setMousePosition(x, y=null){
        local newPos = ::EditorGUIFramework.float2_(x, y);
        mBus_.transmitEvent(EditorGUIFramework_BusEvent.MOUSE_POS_CHANGE, newPos);
    }

    function setMouseButton(button, pressed){
        if(mMouseButtonStates_[button] != pressed){
            //Change in button state.
            mBus_.transmitEvent(
                pressed ? EditorGUIFramework_BusEvent.MOUSE_BUTTON_PRESS : EditorGUIFramework_BusEvent.MOUSE_BUTTON_RELEASE
            , button);
        }
        mMouseButtonStates_[button] = pressed;
    }

    function setupColours(){
        foreach(c,i in ::EditorGUIFramework.Settings){
            local createdBlock = _hlms.unlit.createDatablock("EditorGUIFramework_" + c);
            createdBlock.setColour(i);
            createdBlock.setUseColour(true);
        }
    }

    //TODO Each window should have an id
    function createWindow(name){
        local obj = mObjectManager_.getObject();
        local window = ::EditorGUIFramework.Window(obj, mWindowManager_, name);
        mWindowManager_.registerWindow(window);

        return window;
    }
};

::EditorGUIFramework.Base.ObjectManager <- class{
    mIdCount = 0;
    mTotalObjecs = null;
    mRecycleIds = null;

    mBus_ = null;
    constructor(bus){
        mTotalObjecs = [];
        mRecycleIds = [];
        mBus_ = bus;
    }
    function getObject(){
        return EditorGUIFramework.Object(getId_(), mBus_);
    }
    function releaseObject(obj){
        mRecycleIds.append(obj.mId_);
    }
    function getId_(){
        if(mRecycleIds.len() > 0){
            return mRecycleIds.pop();
        }

        local id = mIdCount;
        mIdCount++;
        return mIdCount;
    }
};