::EditorGUIFramework.Window <- class{
    mObj_ = null
    mWindowManager_ = null

    mTitle_ = null
    mPos_ = null
    mPosWithBorders_ = null
    mSize_ = null
    mSizeWithBorders_ = null
    mZ_ = null;
    mFocused_ = false;

    mWindow_ = null
    mTitleLabel_ = null
    mWindowMoveButton_ = null
    mWindowCloseButton_ = null
    mWindowTitlePanel_ = null
    mChildWindow_ = null
    mResizeButton_ = null

    RESIZE_BORDER = 8

    constructor(obj, winMan, title){
        mObj_ = obj;
        mWindowManager_ = winMan;
        mTitle_ = title;

        setup();
        setSize(200, 200);
    }

    function setup(){
        local layoutLine = _gui.createLayoutLine();
        mWindow_ = _gui.createWindow();
        mWindow_.setVisualsEnabled(false);

        mResizeButton_ = mWindow_.createButton();
        mResizeButton_.attachListener(function(widget, action){
            if(action == _GUI_ACTION_PRESSED){
                mWindowManager_.requestResizeBegin_(this);
            }
            else if(action == _GUI_ACTION_HIGHLIGHTED){
                mObj_.transmitRequest(EditorGUIFramework_BusRequest.SET_CURSOR, _SYSTEM_CURSOR_SIZEWE);
            }
            else if(action == _GUI_ACTION_CANCEL){
                mObj_.transmitRequest(EditorGUIFramework_BusRequest.SET_CURSOR, _SYSTEM_CURSOR_ARROW);
            }
        }, this);
        mResizeButton_.setVisualsEnabled(false);

        mWindowTitlePanel_ = mWindow_.createPanel();
        mWindowTitlePanel_.setPosition(0, 0);
        mWindowTitlePanel_.setDatablock("EditorGUIFramework_FrameBg");

        mTitleLabel_ = mWindow_.createLabel();
        layoutLine.addCell(mTitleLabel_);

        mWindowCloseButton_ = mWindow_.createButton();
        mWindowCloseButton_.setText("X");
        mWindowCloseButton_.setSkinPack("EditorGUIFramework/WindowCloseButtonSkinPack");
        mWindowCloseButton_.attachListenerForEvent(function(widget, action){
            mWindowManager_.closeWindow_(this);
        }, _GUI_ACTION_PRESSED, this);
        //layoutLine.addCell(mWindowCloseButton_);

        mWindowMoveButton_ = mWindow_.createButton();
        //mWindowMoveButton_.setText("move");
        mWindowMoveButton_.attachListenerForEvent(function(widget, action){
            mObj_.transmitEvent(EditorGUIFramework_BusEvent.WINDOW_MOVE_DRAG_BEGAN, this);
        }, _GUI_ACTION_PRESSED, this);
        mWindowMoveButton_.setVisualsEnabled(false);
        //layoutLine.addCell(mWindowMoveButton_);

        mChildWindow_ = mWindow_.createWindow();

        setTitle(mTitle_);
        mWindow_.setClipBorders(0, 0, 0, 0);

        //layoutLine.layout();
    }

    function getWin(){
        return mChildWindow_;
    }

    function shutdown(){
        _gui.destroy(mWindow_);
    }

    function setTitle(title){
        mTitle_ = title;

        mTitleLabel_.setText(mTitle_);
        mTitleLabel_.setTextColour(0.0, 0.0, 0.0, 1.0);
    }

    function setPosition(x, y=null){
        mWindowManager_.setWindowParam_(this, EditorGUIFramework_WindowParam.POSITION, ::EditorGUIFramework.float2_(x, y));
    }

    function setSize(x, y=null){
        mWindowManager_.setWindowParam_(this, EditorGUIFramework_WindowParam.SIZE, ::EditorGUIFramework.float2_(x, y));
    }

    function focus(){
        mWindowManager_.bringWindowToFront(this);
    }

    function setParamImpl_(param, val){
        switch(param){
            case EditorGUIFramework_WindowParam.POSITION:{
                mPos_ = val;
                mPosWithBorders_ = val - RESIZE_BORDER;
                mWindow_.setPosition(mPosWithBorders_);
                break;
            }
            case EditorGUIFramework_WindowParam.SIZE:{
                mSize_ = val;
                mSizeWithBorders_ = val + RESIZE_BORDER*2;
                mWindow_.setSize(mSizeWithBorders_);
                mWindowCloseButton_.setText("X");

                mWindowTitlePanel_.setSize(val.x, mTitleLabel_.getSize().y);
                mWindowTitlePanel_.setPosition(RESIZE_BORDER, RESIZE_BORDER);

                mTitleLabel_.setPosition(RESIZE_BORDER+5, RESIZE_BORDER);
                mWindowCloseButton_.setSize(mWindowCloseButton_.getSize().x*2, mTitleLabel_.getSize().y);
                mWindowCloseButton_.setPosition(RESIZE_BORDER + val.x - mWindowCloseButton_.getSize().x, RESIZE_BORDER);
                mWindowMoveButton_.setPosition(RESIZE_BORDER, RESIZE_BORDER);
                mWindowMoveButton_.setSize(val.x - mWindowCloseButton_.getSize().x, mTitleLabel_.getSize().y);
                mChildWindow_.setPosition(RESIZE_BORDER, RESIZE_BORDER + mTitleLabel_.getSize().y);
                mChildWindow_.setSize(val.x, val.y - mTitleLabel_.getSize().y);
                mResizeButton_.setPosition(0, 0);
                mResizeButton_.setSize(mWindow_.getSize());

                break;
            }
            case EditorGUIFramework_WindowParam.Z_ORDER:{
                mZ_ = val;
                mWindow_.setZOrder(val);
                break;
            }
            case EditorGUIFramework_WindowParam.FOCUS:{
                mFocused_ = val;
                mWindowTitlePanel_.setDatablock(mFocused_ ? "EditorGUIFramework_FrameBgActive" : "EditorGUIFramework_FrameBg");
                break;
            }
        }
    }
}