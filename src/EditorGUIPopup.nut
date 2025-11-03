::EditorGUIFramework.Popup <- class extends ::EditorGUIFramework.Window{

    constructor(id, obj, winMan, title){
        base.constructor(id, obj, winMan, title);

        setSize(500, 200);
        centrePopup();
        mWindowCloseButton_.attachListenerForEvent(function(widget, action){
            closePopup();
        }, _GUI_ACTION_PRESSED, this);
    }

    function centrePopup(){
        setPosition(_window.getWidth() / 2 - mSize_.x / 2, _window.getHeight() / 2 - mSize_.y / 2);
    }

    #Override
    function getWindowObjectType(){
        return EditorGUIFramework_WindowManagerObjectType.POPUP;
    }

    function closePopup(){
        mWindowManager_.closePopup_(this);
    }

};

::EditorGUIFramework.PopupWithBasicData <- class extends ::EditorGUIFramework.Popup{

    mCallbackFunction_ = null;

    mInputText_ = null;

    function constructor(id, obj, winMan, title, constructionData, callbackFunction){
        base.constructor(id, obj, winMan, title);

        mCallbackFunction_ = callbackFunction;
        constructWithBasicData_(constructionData);
    }

    function closeButtonCallback(widget, action){
        if(mCallbackFunction_ != null){
            mCallbackFunction_(this, EditorGUIFramework_PopupConstructionData.CLOSE_BUTTON);
        }
        closePopup();
    }

    function acceptButtonCallback(widget, action){
        if(mCallbackFunction_ != null){
            mCallbackFunction_(this, EditorGUIFramework_PopupConstructionData.ACCEPT_BUTTON);
        }
        closePopup();
    }

    function constructWithBasicData_(constructionData){
        local win = getWin();

        local descriptionLabel = null;
        local closeButton = null;
        local acceptButton = null;
        local inputText = null;
        foreach(i in constructionData){
            switch(i[0]){
                case EditorGUIFramework_PopupConstructionData.DESCRIPTION:{
                    local label = win.createLabel();
                    label.setText(i[1]);
                    descriptionLabel = label;
                    break;
                }
                case EditorGUIFramework_PopupConstructionData.INPUT_TEXT:{
                    local editbox = win.createEditbox();
                    editbox.setMinSize(400, 100);
                    inputText = editbox;
                    mInputText_ = inputText;
                    break;
                }
                case EditorGUIFramework_PopupConstructionData.CLOSE_BUTTON:{
                    closeButton = win.createButton();
                    closeButton.setText(i[1]);
                    closeButton.attachListenerForEvent(closeButtonCallback, _GUI_ACTION_PRESSED, this);
                    break;
                }
                case EditorGUIFramework_PopupConstructionData.ACCEPT_BUTTON:{
                    acceptButton = win.createButton();
                    acceptButton.setText(i[1]);
                    acceptButton.attachListenerForEvent(acceptButtonCallback, _GUI_ACTION_PRESSED, this);
                    break;
                }
            }
        }
        local layoutLine = _gui.createLayoutLine(_LAYOUT_HORIZONTAL);
        local maxSize = 0;
        local width = 0;
        if(inputText != null){
            inputText.setSize(400, 40);
            local targetPos = Vec2();
            if(descriptionLabel != null){
                targetPos.y += descriptionLabel.getSize().y;
            }
            inputText.setPosition(targetPos);
        }
        if(closeButton != null){
            local s = closeButton.getSize();
            local height = s.y;
            width += s.x;
            if(height > maxSize) maxSize = height;
            layoutLine.addCell(closeButton);
        }
        if(acceptButton != null){
            local s = acceptButton.getSize();
            local height = s.y;
            if(height > maxSize) maxSize = height;
            width += s.x;
            layoutLine.addCell(acceptButton);
        }

        if(closeButton){
            closeButton.setSize(closeButton.getSize().x, maxSize);
        }
        if(acceptButton){
            acceptButton.setSize(acceptButton.getSize().x, maxSize);
        }
        layoutLine.setMarginForAllCells(10, 0);
        width += 10;
        layoutLine.setSize(win.getSizeAfterClipping().x, maxSize);
        layoutLine.setPosition(win.getSizeAfterClipping().x - width - 10, win.getSizeAfterClipping().y - maxSize);
        layoutLine.layout();

    }
}