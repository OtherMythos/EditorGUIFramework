::EditorGUIFramework.Widget.NumericInput <- class extends ::EditorGUIFramework.Object{

    mWidget_ = null;
    mCallback_ = null;
    mAllowFloat_ = false;

    constructor(parent, allowFloat=false){
        mAllowFloat_ = allowFloat;

        local editbox = parent.createEditbox();
        editbox.setMinSize(100, 30);
        editbox.setMargin(0, 0);
        local targetCallback = allowFloat ? editboxFloatCallback : editboxIntCallback;
        editbox.attachListenerForEvent(targetCallback, _GUI_ACTION_VALUE_CHANGED, this);
        mWidget_ = editbox;

        guiFrameworkBase.mObjectManager_.getObjectTest(this);
        mWidget_.setUserId(mId_);
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
            //Do something
        }

        //Obtain the 'this'.
        //local widgetObj = guiFrameworkBase.mObjectManager_.getWidgetForTest(widget.getUserId());
        //if(widgetObj.mCallback_ != null){
        //    widgetObj.mCallback_(widgetObj, EditorGUIFramework_WidgetCallbackEvent.VALUE_CHANGED);
        //}
        if(mCallback_ != null){
            mCallback_(this, EditorGUIFramework_WidgetCallbackEvent.VALUE_CHANGED);
        }
    }

    function addToLayout(layout){
        layout.addCell(mWidget_);
    }

    function getValue(){
        local value = mWidget_.getText();
        if(mAllowFloat_){
            return value.tofloat();
        }else{
            return value.tointeger();
        }
    }

};

::EditorGUIFramework.Widget.NumericInput.floatRegex <-
regexp("^(\\d*(\\.\\d*)?)$");

::EditorGUIFramework.Widget.NumericInput.intRegex <-
regexp("^(\\d*)$");
