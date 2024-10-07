
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

    function mouseInteracting(){
        return mWindowManager_.mouseInteracting();
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

    function attachWindowManagerListener(listener){
        mWindowManager_.attachWindowManagerListener(listener);
    }

    function createWindow(id, name){
        local obj = mObjectManager_.getObject();
        local window = ::EditorGUIFramework.Window(id, obj, mWindowManager_, name);
        mWindowManager_.registerWindow(id, window);

        return window;
    }

    function createPopup(id, name, constructionData=null){
        local obj = mObjectManager_.getObject();
        local popup = ::EditorGUIFramework.Popup(id, obj, mWindowManager_, name, constructionData);
        mWindowManager_.registerPopup(id, popup);

        return popup;
    }

    ToolbarListener = class{
        mCreator_ = null
        mZOrderManager_ = null

        constructor(creator, zOrderManager){
            mCreator_ = creator;
            mZOrderManager_ = zOrderManager;
        }

        function notifyToolbarDestroyed_(){
            mZOrderManager_.releaseBlockerWindow();
            mCreator_.mBus_.transmitEvent(EditorGUIFramework_BusEvent.TOOLBAR_CLOSED);
        }

        function notifyToolbarClicked_(){
            //mButtonHighlightPanel_.setVisible(false);
        }
    };

    function createToolbarMenu(data, pos){
        local obj = mObjectManager_.getObject();
        local zOrderManager = mWindowManager_.mZOrderManager_;
        local toolbar = ::EditorGUIFramework.Toolbar.ToolbarMenu(ToolbarListener(this, zOrderManager), data, zOrderManager, pos, false);

        zOrderManager.generateBlockerWindowForObject(EditorGUIFramework_WindowManagerObjectType.TOOLBAR_MENU_SOLO);

        mBus_.transmitEvent(EditorGUIFramework_BusEvent.TOOLBAR_OPENED);

        return toolbar;
    }

    function serialiseWindowStates(outPath){
        _system.ensureUserDirectory();

        local outData = {
            "vals": []
        };
        mWindowManager_.populateArrayWithWindowState_(outData.vals);

        _system.writeJsonAsFile(outPath, outData);
    }

    function loadWindowStates(loadPath){
        if(!_system.exists(loadPath)) return;
        local data = _system.readJSONAsTable(loadPath);
        if(!data.rawin("vals")) return;

        local parsedWindows = {};
        foreach(i in data.rawget("vals")){
            if(!i.rawin("id")) continue;
            local value = {
                "size": null,
                "pos": null,
            };
            if(i.rawin("size")) value.size = Vec2(i.rawget("size"));
            if(i.rawin("pos")) value.pos = Vec2(i.rawget("pos"));
            parsedWindows.rawset(i.rawget("id"), value);
        }

        //With the windows parsed, go through and find and position them.
        mWindowManager_.applyWindowStateData(parsedWindows);
    }
};

::EditorGUIFramework.Base.ObjectManager <- class{
    mIdCount = 0;
    mTotalObjects = null;
    mRecycleIds = null;

    mBus_ = null;
    constructor(bus){
        mTotalObjects = [];
        mRecycleIds = [];
        mBus_ = bus;
    }
    //NOTE do not commit
    function getObjectTest(item){
        item.mId_ = getId_();
        item.mBus_ = mBus_;
        mTotalObjects[item.mId_] = item;
    }
    function getWidgetForTest(id){
        return mTotalObjects[id];
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
        mTotalObjects.append(null);
        return id;
    }
};