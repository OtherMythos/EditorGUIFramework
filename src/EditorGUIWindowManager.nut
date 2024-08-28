::EditorGUIFramework.WindowManager <- class{

    mBus_ = null;
    mActiveWindows_ = null
    mCurrentMousePos_ = null
    mStateContext_ = null;
    mStateMachine_ = null;

    mToolbar_ = null;
    mZOrderManager_ = null;

    //Z indexes indexed by their internal Z.
    mZIndexes_ = null
    //Windows in order with the highest index at the end.
    //Indexes represent those give to _gui.
    mZIndexesOrdered_ = null

    MAX_WINDOWS = 100
    MAX_TOOLBAR_MENUS = 10

    constructor(bus){
        mBus_ = bus;
        mActiveWindows_ = [];
        mCurrentMousePos_ = Vec2();
        mStateContext_ = {
            "winMan": this,
            "mouseButton": array(EditorGUIFramework_WindowManagerStateEvent.MAX, false)
            "mousePos": Vec2(),
            "mouseOffset": null,
            "windowStartSize": null,

            "data": null
        };
        mStateMachine_ = StateMachine(mStateContext_);
        mZOrderManager_ = ZOrderManager();

        mZIndexes_ = array(MAX_WINDOWS, null);
        mZIndexesOrdered_ = [];

        mBus_.subscribeObject(this);
    }

    function notifyBusEvent(event, data){
        if(event == EditorGUIFramework_BusEvent.MOUSE_BUTTON_PRESS){
            mStateContext_.mouseButton[data] = true;
            if(mStateMachine_.isState(EditorGUIFramework_WindowManagerState.NONE)){
                reprocessMousePosition_();
            }
        }else if(event == EditorGUIFramework_BusEvent.MOUSE_BUTTON_RELEASE){
            mStateContext_.mouseButton[data] = false;
            //reprocessMousePosition_();
        }else if(event == EditorGUIFramework_BusEvent.MOUSE_POS_CHANGE){
            mStateContext_.mousePos = data;
            setMousePosition(data);
        }else if(event == EditorGUIFramework_BusEvent.WINDOW_MOVE_DRAG_BEGAN){
            //TODO bit of a hack to get windows dragging properly.
            mStateContext_.mouseButton[0] = true;
            attemptWindowDragBegin_(data);
        }else if(event == EditorGUIFramework_BusEvent.TOOLBAR_OPENED){
            mStateMachine_.notify(EditorGUIFramework_WindowManagerStateEvent.TOOLBAR_OPENED, mStateContext_, null);
        }else if(event == EditorGUIFramework_BusEvent.TOOLBAR_CLOSED){
            mStateMachine_.notify(EditorGUIFramework_WindowManagerStateEvent.TOOLBAR_CLOSED, mStateContext_, null);
        }
    }

    function update(){
        mStateMachine_.updateState();
    }

    function registerWindow(window){
        if(mActiveWindows_.len() + 1 >= MAX_WINDOWS){
            throw "MAX_WINDOWS has been reached.";
        }
        placeInitialZ_(window);
        //bringWindowToFront(window);
        mActiveWindows_.append(window);
    }

    function deRegisterWindow(window){
        local idx = mActiveWindows_.find(window);
        assert(idx != null);
        mActiveWindows_.remove(idx);

        idx = mZIndexes_.find(window);
        assert(idx != null);
        mZIndexes_[idx] = null;

        window.shutdown();
    }

    function setMousePosition(pos){
        mCurrentMousePos_ = pos;
    }

    function closeWindow_(window){
        if(mStateMachine_.mCurrentState_ != EditorGUIFramework_WindowManagerStateEvent.NONE){
            return;
        }
        mStateMachine_.notify(EditorGUIFramework_WindowManagerStateEvent.WINDOW_CLOSED, mStateContext_, window);
        deRegisterWindow(window);
    }

    //Reorder the Z list so there is a space at the end.
    function freeUpperZIdx_(){
        //Head through the list backwards, until a hole is found.
        for(local i = MAX_WINDOWS-1; i >= 0; i--){
            if(mZIndexes_[i] != null) continue;
            mZIndexes_.remove(i);
            mZIndexes_.append(null);
            assert(mZIndexes_.len() == MAX_WINDOWS);
            return;
        }
        assert(false);
    }
    function placeInitialZ_(window){
        local idx = mZIndexes_.find(null);
        assert(idx != null);
        setZForWindow_(idx, window);
    }
    function setZForWindow_(z, window){
        //TODO OPTIMISATION don't 0N search it.
        local idx = mZIndexes_.find(window);
        if(idx != null){
            mZIndexes_[idx] = null;
        }
        mZIndexes_[z] = window;
        local resolvedZ = mZOrderManager_.getZForWindowObject(EditorGUIFramework_WindowManagerObjectType.WINDOW, z);
        setWindowParam_(window, EditorGUIFramework_WindowParam.Z_ORDER, resolvedZ);
    }

    function bringWindowToFront_(window){
        freeUpperZIdx_();
        setZForWindow_(MAX_WINDOWS-1, window);
    }
    function bringWindowToFront(window){
        bringWindowToFront_(window);
        reprocessWindowZOrder_();
    }

    function setWindowParam_(window, param, val){
        switch(param){
            case EditorGUIFramework_WindowParam.POSITION:{
                window.setParamImpl_(param, val);
                break;
            }
            case EditorGUIFramework_WindowParam.SIZE:{
                window.setParamImpl_(param, val);
                break;
            }
            case EditorGUIFramework_WindowParam.Z_ORDER:{
                window.setParamImpl_(param, val);
                break;
            }
        }
    }

    function setToolbar(toolbar){
        mToolbar_ = toolbar;
        mToolbar_.setup_(mBus_, mZOrderManager_);
    }

    function attemptWindowDragBegin_(window){
        mStateMachine_.notify(EditorGUIFramework_WindowManagerStateEvent.WINDOW_DRAG, mStateContext_, window);
    }

    function requestResizeBegin_(window){
        mStateContext_.mouseButton[0] = true;
        mStateMachine_.notify(EditorGUIFramework_WindowManagerStateEvent.WINDOW_RESIZE, mStateContext_, window);
    }

    function reprocessWindowZOrder_(){
        mZIndexesOrdered_ = mZIndexes_.filter(function(index, val){
            return val != null;
        });
        assert(mZIndexesOrdered_.len() == mActiveWindows_.len());
        foreach(c,i in mZIndexesOrdered_){
            setWindowParam_(i, EditorGUIFramework_WindowParam.Z_ORDER, c);
        }
    }

    function resizeWindowByDelta(window, startSize, delta){
        local intendedSize = startSize + delta;
        if(intendedSize.x <= 100) intendedSize.x = 100;
        if(intendedSize.y <= 100) intendedSize.y = 100;
        setWindowParam_(window, EditorGUIFramework_WindowParam.SIZE, intendedSize);
    }

    function reprocessMousePosition_(){
        local x = mCurrentMousePos_.x;
        local y = mCurrentMousePos_.y;
        for(local c = mActiveWindows_.len()-1; c >= 0; c--){
            local i = mActiveWindows_[c];
            local p = i.mPosWithBorders_;
            local s = i.mSizeWithBorders_;
            if(!checkIntersect_(x, y, p.x, p.y, s.x, s.y)) continue;
            //The mouse is intersecting this window.
            bringWindowToFront(i);
            return;
        }
    }
    function checkIntersect_(x, y, xx, yy, width, height){
        return (x >= xx && y >= yy && x <= xx+width && y <= yy+height);
    }

}

::EditorGUIFramework.WindowManager.ZOrderManager <- class{

    START = 5;
    UNKNOWN = 6;
    WINDOW_START = 10;
    WINDOW_END = null;
    POST_WINDOW_PADDING = 10;
    POST_WINDOW_START = null;
    TOOLBAR_START = null;
    TOOLBAR_END = null;

    mBlockerWindow_ = null;

    constructor(){
        WINDOW_END = WINDOW_START + ::EditorGUIFramework.WindowManager.MAX_WINDOWS;
        POST_WINDOW_START = WINDOW_END + POST_WINDOW_PADDING;
        TOOLBAR_START = POST_WINDOW_START + POST_WINDOW_PADDING;
        TOOLBAR_END = TOOLBAR_START + ::EditorGUIFramework.WindowManager.MAX_TOOLBAR_MENUS;
    }

    function getZForWindowObject(winType, idx=null){
        switch(winType){
            case EditorGUIFramework_WindowManagerObjectType.WINDOW:{
                assert(idx < ::EditorGUIFramework.WindowManager.MAX_WINDOWS);
                local outIdx = WINDOW_START + idx;
                assert(outIdx >= WINDOW_START && outIdx < WINDOW_END);
                return outIdx;
            }
            case EditorGUIFramework_WindowManagerObjectType.INPUT_BLOCKER:{
                return POST_WINDOW_START + 1;
            }
            case EditorGUIFramework_WindowManagerObjectType.TOOLBAR:{
                return POST_WINDOW_START + 2;
            }
            case EditorGUIFramework_WindowManagerObjectType.TOOLBAR_MENU:{
                assert(idx < ::EditorGUIFramework.WindowManager.MAX_WINDOWS);
                local outIdx = TOOLBAR_START + idx;
                assert(outIdx >= TOOLBAR_START && outIdx < TOOLBAR_END);
                return outIdx;
            }
            default:{
                return UNKNOWN;
            }
        }
    }

    function generateBlockerWindowForObject(winType){
        assert(mBlockerWindow_ == null);

        mBlockerWindow_ = _gui.createWindow();
        mBlockerWindow_.setPosition(0, 0);
        mBlockerWindow_.setSize(_window.getSize());
        mBlockerWindow_.setVisualsEnabled(false);

        local zIdx = getZForWindowObject(EditorGUIFramework_WindowManagerObjectType.INPUT_BLOCKER);
        mBlockerWindow_.setZOrder(zIdx);
    }

    function releaseBlockerWindow(){
        assert(mBlockerWindow_ != null);
        _gui.destroy(mBlockerWindow_);
        mBlockerWindow_ = null;
    }

}

::EditorGUIFramework.WindowManager.StateMachine <- class{

    mCurrentState_ = null;
    mCurrentStateDef_ = null;
    mStateFunctions_ = null;
    mContextData_ = null;

    mStateDefs_ = array(EditorGUIFramework_WindowManagerState.MAX);

    constructor(contextData){
        mContextData_ = contextData;
        beginState_(EditorGUIFramework_WindowManagerState.NONE);
    }

    function isState(state){
        return state == mCurrentState_;
    }

    function beginState_(state){
        if(mCurrentStateDef_ != null){
            mCurrentStateDef_.end(mContextData_);
        }
        mCurrentStateDef_ = mStateDefs_[state]();
        mCurrentStateDef_.start(mContextData_);
        mCurrentState_ = state;
    }

    function updateState(){
        if(mCurrentStateDef_ == null) return;
        local retState = mCurrentStateDef_.update(mContextData_);
        if(retState != null && retState != mCurrentState_){
            beginState_(retState);
        }
    }

    function notify(event, ctx, data=null){
        if(mCurrentStateDef_ == null) return;
        local retState = mCurrentStateDef_.notify(event, ctx, data);
        if(retState != null){
            beginState_(retState);
        }
    }
};

local StateDef = class{
    function start(ctx){ }
    function update(ctx){ }
    function end(ctx){ }
    function notify(event, ctx){ }
};

::EditorGUIFramework.WindowManager.StateMachine.mStateDefs_[EditorGUIFramework_WindowManagerState.NONE] = class extends StateDef{
    function update(ctx){
        //print("none");
    }
    function notify(event, ctx, data){
        if(event == EditorGUIFramework_WindowManagerStateEvent.WINDOW_DRAG){
            ctx.data = data;
            ctx.mouseOffset = ctx.data.mPos_ - ctx.mousePos;
            return EditorGUIFramework_WindowManagerState.WINDOW_DRAG;
        }
        else if(event == EditorGUIFramework_WindowManagerStateEvent.WINDOW_RESIZE){
            ctx.data = data;
            ctx.mouseOffset = ctx.mousePos;
            ctx.windowStartSize = ctx.data.mSize_.copy();
            return EditorGUIFramework_WindowManagerState.WINDOW_RESIZE;
        }
        else if(event == EditorGUIFramework_WindowManagerStateEvent.TOOLBAR_OPENED){
            return EditorGUIFramework_WindowManagerState.TOOLBAR_OPEN;
        }
    }
}

::EditorGUIFramework.WindowManager.StateMachine.mStateDefs_[EditorGUIFramework_WindowManagerState.WINDOW_DRAG] = class extends StateDef{
    function update(ctx){
        if(!ctx.mouseButton[EditorGUIFramework_MouseButton.LEFT]){
            return EditorGUIFramework_WindowManagerState.NONE;
        }

        ctx.data.setPosition(ctx.mouseOffset + ctx.mousePos);
    }

    function notify(event, ctx, data){
        if(event == EditorGUIFramework_WindowManagerStateEvent.WINDOW_CLOSED){
            if(ctx.data == data){
                ctx.data = null;
                return EditorGUIFramework_WindowManagerState.NONE;
            }
        }
    }
};
::EditorGUIFramework.WindowManager.StateMachine.mStateDefs_[EditorGUIFramework_WindowManagerState.WINDOW_RESIZE] = class extends StateDef{
    function update(ctx){
        if(!ctx.mouseButton[EditorGUIFramework_MouseButton.LEFT]){
            return EditorGUIFramework_WindowManagerState.NONE;
        }

        local delta = ctx.mousePos - ctx.mouseOffset;
        ctx.winMan.resizeWindowByDelta(ctx.data, ctx.windowStartSize, delta);
    }

    function notify(event, ctx, data){
        if(event == EditorGUIFramework_WindowManagerStateEvent.WINDOW_CLOSED){
            if(ctx.data == data){
                ctx.data = null;
                return EditorGUIFramework_WindowManagerState.NONE;
            }
        }
    }
};
::EditorGUIFramework.WindowManager.StateMachine.mStateDefs_[EditorGUIFramework_WindowManagerState.TOOLBAR_OPEN] = class extends StateDef{
    function notify(event, ctx, data){
        if(event == EditorGUIFramework_WindowManagerStateEvent.TOOLBAR_CLOSED){
            return EditorGUIFramework_WindowManagerState.NONE;
        }
    }
};