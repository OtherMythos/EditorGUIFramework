::EditorGUIFramework.Popup <- class extends ::EditorGUIFramework.Window{

    constructor(id, obj, winMan, title, constructionData){
        base.constructor(id, obj, winMan, title);

        local startSize = Vec2(500, 200);
        setSize(startSize);
        setPosition(_window.getWidth() / 2 - startSize.x / 2, _window.getHeight() / 2 - startSize.y / 2);
        mWindowCloseButton_.attachListenerForEvent(function(widget, action){
            closePopup();
        }, _GUI_ACTION_PRESSED, this);
        if(constructionData != null){
            constructWithBasicData_(constructionData);
        }
    }

    #Override
    function getWindowObjectType(){
        return EditorGUIFramework_WindowManagerObjectType.POPUP;
    }

    function closePopup(){
        mWindowManager_.closePopup_(this);
    }

    function constructWithBasicData_(constructionData){
        local win = getWin();

        local closeButton = null;
        local acceptButton = null;
        foreach(i in constructionData){
            switch(i[0]){
                case EditorGUIFramework_PopupConstructionData.DESCRIPTION:{
                    local label = win.createLabel();
                    label.setText(i[1]);
                    break;
                }
                case EditorGUIFramework_PopupConstructionData.CLOSE_BUTTON:{
                    closeButton = win.createButton();
                    closeButton.setText(i[1]);
                    closeButton.attachListenerForEvent(function(widget, action){
                        closePopup();
                    }, _GUI_ACTION_PRESSED, this);
                    break;
                }
                case EditorGUIFramework_PopupConstructionData.ACCEPT_BUTTON:{
                    acceptButton = win.createButton();
                    acceptButton.setText(i[1]);
                    acceptButton.attachListenerForEvent(function(widget, action){
                        closePopup();
                    }, _GUI_ACTION_PRESSED, this);
                    break;
                }
            }
        }
        local layoutLine = _gui.createLayoutLine(_LAYOUT_HORIZONTAL);
        local maxSize = 0;
        local width = 0;
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

};