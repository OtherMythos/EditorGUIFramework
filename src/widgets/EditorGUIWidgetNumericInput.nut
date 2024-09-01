::EditorGUIFramework.Widget.NumericInput <- class{

    mWidget_ = null;

    constructor(parent, allowFloat=false){

        local editbox = parent.createEditbox();
        editbox.setMinSize(200, 30);
        editbox.setMargin(0, 10);
        local targetCallback = allowFloat ? editboxFloatCallback : editboxIntCallback;
        editbox.attachListenerForEvent(targetCallback, _GUI_ACTION_VALUE_CHANGED);
        mWidget_ = editbox;
    }

    function editboxIntCallback(widget, action){
        ::EditorGUIFramework.Widget.NumericInput.callback_(widget, action, ::EditorGUIFramework.Widget.NumericInput.intRegex);
    }
    function editboxFloatCallback(widget, action){
        ::EditorGUIFramework.Widget.NumericInput.callback_(widget, action, ::EditorGUIFramework.Widget.NumericInput.floatRegex);
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
    }

    function addToLayout(layout){
        layout.addCell(mWidget_);
    }

};

::EditorGUIFramework.Widget.NumericInput.floatRegex <-
regexp("^(\\d*(\\.\\d*)?)$");

::EditorGUIFramework.Widget.NumericInput.intRegex <-
regexp("^(\\d*)$");
