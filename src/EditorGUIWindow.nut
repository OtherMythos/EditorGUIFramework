::EditorGUIFramework.Window <- class{
    mObj_ = null
    mWindowManager_ = null

    mTitle_ = null
    mPos_ = null
    mSize_ = null
    mZ_ = null;

    mWindow_ = null
    mTitleLabel_ = null

    constructor(obj, winMan, title){
        mObj_ = obj;
        mWindowManager_ = winMan;
        mTitle_ = title;

        setup();
    }

    function setup(){
        local layoutLine = _gui.createLayoutLine();
        mWindow_ = _gui.createWindow();

        mTitleLabel_ = mWindow_.createLabel();
        layoutLine.addCell(mTitleLabel_);

        local windowMoveButton = mWindow_.createButton();
        windowMoveButton.setText("move");
        windowMoveButton.attachListenerForEvent(function(widget, action){
            mObj_.transmitEvent(EditorGUIFramework_BusEvent.WINDOW_MOVE_DRAG_BEGAN, this);
        }, _GUI_ACTION_PRESSED, this);
        layoutLine.addCell(windowMoveButton);

        setTitle(mTitle_);

        layoutLine.layout();
    }

    function setTitle(title){
        mTitle_ = title;

        mTitleLabel_.setText(mTitle_);
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