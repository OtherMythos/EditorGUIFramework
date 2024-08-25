::EditorGUIFramework.Window <- class{
    mObj_ = null
    mWindowManager_ = null

    mTitle_ = null
    mPos_ = null
    mSize_ = null
    mZ_ = null;

    mWindow_ = null
    mTitleLabel_ = null
    mWindowMoveButton_ = null
    mWindowCloseButton_ = null
    mWindowTitlePanel_ = null

    constructor(obj, winMan, title){
        mObj_ = obj;
        mWindowManager_ = winMan;
        mTitle_ = title;

        setup();
    }

    function setup(){
        local layoutLine = _gui.createLayoutLine();
        mWindow_ = _gui.createWindow();

        mWindowTitlePanel_ = mWindow_.createPanel();
        mWindowTitlePanel_.setPosition(0, 0);

        mTitleLabel_ = mWindow_.createLabel();
        layoutLine.addCell(mTitleLabel_);

        mWindowCloseButton_ = mWindow_.createButton();
        mWindowCloseButton_.setText("X");
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

        setTitle(mTitle_);
        mWindow_.setClipBorders(0, 0, 0, 0);

        //layoutLine.layout();
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

    function setParamImpl_(param, val){
        switch(param){
            case EditorGUIFramework_WindowParam.POSITION:{
                mPos_ = val;
                mWindow_.setPosition(val);
                break;
            }
            case EditorGUIFramework_WindowParam.SIZE:{
                mSize_ = val;
                mWindow_.setSize(val);

                mWindowTitlePanel_.setSize(val.x, mTitleLabel_.getSize().y);
                mWindowMoveButton_.setPosition(0, 0);
                mWindowMoveButton_.setSize(val.x - mWindowCloseButton_.getSize().x, mTitleLabel_.getSize().y);
                mWindowCloseButton_.setPosition(val.x - mWindowCloseButton_.getSize().x, 0);
                mWindowCloseButton_.setSize(mWindowCloseButton_.getSize().x, mTitleLabel_.getSize().y);

                break;
            }
            case EditorGUIFramework_WindowParam.Z_ORDER:{
                mZ_ = val;
                mWindow_.setZOrder(val);
                break;
            }
        }
    }
}