::EditorGUIFramework.InputStealer <- class{

    mWindow_ = null;
    mButton_ = null;

    constructor(){
        local win = _gui.createWindow("EditorGUIInputStealer");

        mButton_ = win.createButton();

        mWindow_ = win;
        mWindow_.setVisible(false);
    }

    function steal(){
        mButton_.setFocus();
    }

};