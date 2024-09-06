::EditorGUIFramework.Widget.NumericInput <- class extends ::EditorGUIFramework.Object{

    mWidget_ = null;
    mCallback_ = null;
    mParentCallback_ = null;
    mAllowFloat_ = false;

    constructor(parent, allowFloat=false){
        mAllowFloat_ = allowFloat;

        local editbox = parent.createEditbox();
        editbox.setMinSize(100, 30);
        editbox.setMargin(0, 0);
        local targetCallback = allowFloat ? editboxFloatCallback : editboxIntCallback;
        editbox.attachListenerForEvent(targetCallback, _GUI_ACTION_VALUE_CHANGED, this);
        mWidget_ = editbox;

        //guiFrameworkBase.mObjectManager_.getObjectTest(this);
        //mWidget_.setUserId(mId_);
    }

    function editboxIntCallback(widget, action){
        //::EditorGUIFramework.Widget.NumericInput.callback_(widget, action, ::EditorGUIFramework.Widget.NumericInput.intRegex);
        callback_(widget, action, ::EditorGUIFramework.Widget.NumericInput.intRegex);
    }
    function editboxFloatCallback(widget, action){
        //::EditorGUIFramework.Widget.NumericInput.callback_(widget, action, ::EditorGUIFramework.Widget.NumericInput.floatRegex);
        callback_(widget, action, ::EditorGUIFramework.Widget.NumericInput.floatRegex);
    }

    function attachListener(callback){
        mCallback_ = callback;
    }
    function attachParentListener(parentCallback){
        mParentCallback_ = parentCallback;
    }

    function callback_(widget, action, regex){
        local enterPressed = false;
        local changed = false;
        local value = widget.getText();
        local newlineLocation = value.find("\n");
        if(newlineLocation != null){
            value = value.slice(0, newlineLocation);
            changed = true;
            enterPressed = true;
        }
        //Check against the regex.
        local match = regex.match(value);
        if(!match){
            value = value.slice(0, value.len()-1);
            changed = true;
        }
        if(changed){
            widget.setText(value);
        }
        if(enterPressed){
            notifyCallback_(EditorGUIFramework_WidgetCallbackEvent.VALUE_CHANGED);
        }

        //Obtain the 'this'.
        //local widgetObj = guiFrameworkBase.mObjectManager_.getWidgetForTest(widget.getUserId());
        //if(widgetObj.mCallback_ != null){
        //    widgetObj.mCallback_(widgetObj, EditorGUIFramework_WidgetCallbackEvent.VALUE_CHANGED);
        //}
    }

    function notifyCallback_(event){
        if(mCallback_ != null){
            mCallback_.call(this, event);
        }
        if(mParentCallback_ != null){
            mParentCallback_.call(this, event);
        }
    }

    function addToLayout(layout){
        layout.addCell(mWidget_);
    }

    function getValue(){
        local value = mWidget_.getText();
        if(value == ""){
            return mAllowFloat_ ? 0.0 : 0;
        }
        if(mAllowFloat_){
            return value.tofloat();
        }else{
            return value.tointeger();
        }
    }

    function setValue(value){
        local v = null;
        local targetRegex = mAllowFloat_ ? floatRegex : intRegex;
        local strVal = (mAllowFloat_ ? value.tofloat() : value.tointeger()).tostring();
        local match = targetRegex.match(strVal);
        if(!match){
            return;
        }
        mWidget_.setText(strVal);
    }

};

::EditorGUIFramework.Widget.NumericInput.floatRegex <-
regexp("^(\\d*(\\.\\d*)?)$");

::EditorGUIFramework.Widget.NumericInput.intRegex <-
regexp("^(\\d*)$");
