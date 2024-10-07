::EditorGUIFramework.Toolbar <- class{

    mData_ = null;
    mWindow_ = null;
    mBus_ = null;
    mZOrderManager_ = null;
    mButtonHighlightPanel_ = null;

    mBarItems_ = null;

    mActiveToolbar_ = null;

    constructor(data){
        mData_ = data;
        mBarItems_ = [];
    }

    function setup_(bus, zManager){
        mBus_ = bus;
        mWindow_ = _gui.createWindow();
        mZOrderManager_ = zManager;

        //Create a button to claim the keyboard navigation.
        local testButton = mWindow_.createButton();
        testButton.setPosition(0, 0);
        testButton.setSize(1, 1);
        testButton.setVisualsEnabled(false);

        mWindow_.setPosition(0, 0);
        mWindow_.setSize(_window.getWidth(), 100);
        mWindow_.setZOrder(mZOrderManager_.getZForWindowObject(EditorGUIFramework_WindowManagerObjectType.TOOLBAR));

        mButtonHighlightPanel_ = mWindow_.createPanel();
        mButtonHighlightPanel_.setVisible(false);
        mButtonHighlightPanel_.setDatablock("EditorGUIFramework_FrameBg");

        //Draw the initial bar
        local totalX = 0;
        for(local i = 0; i < mData_.len(); i++){
            totalX += 5;
            local v = mData_[i];

            local name = v[0];
            local children = v[1];

            local button = mWindow_.createButton();
            button.setText(name);
            button.setPosition(totalX, 0);
            button.setVisualsEnabled(false);
            button.setKeyboardNavigable(false);
            button.attachListener(function(widget, action){
                if(action == _GUI_ACTION_PRESSED){
                    notifyMenuItemPress_(widget.getUserId());
                }
                else if(action == _GUI_ACTION_HIGHLIGHTED){
                    notifyMenuItemHighlight_(widget.getUserId());
                }
                else if(action == _GUI_ACTION_CANCEL){
                    notifyMenuItemHighlightEnd_();
                }
            }, this);
            button.setUserId(i);
            mBarItems_.append(button);
            totalX += button.getSize().x;
        }

        mWindow_.setSkin("EditorGUIFramework/WindowNoBorder");
        mWindow_.setSize(_window.getWidth(), mBarItems_[0].getSize().y);

        mBus_.subscribeObject(this);
    }

    function notifyBusEvent(event, data){
        if(event == EditorGUIFramework_BusEvent.INPUT_BLOCKER_CLICKED){
            shutdownActiveToolbar();
            notifyMenuItemHighlightEnd_();
        }
    }

    function shutdownActiveToolbar(){
        if(mActiveToolbar_ == null) return;
        mActiveToolbar_.shutdown();
    }

    function notifyMenuItemPress_(idx){
        if(mActiveToolbar_ == null){
            triggerMenuForIdx_(idx);
        }else{
            mActiveToolbar_.shutdown();
            mActiveToolbar_ = null;

            mBus_.transmitEvent(EditorGUIFramework_BusEvent.TOOLBAR_CLOSED);
        }
    }

    function notifyMenuItemHighlightEnd_(){
        if(mActiveToolbar_ == null){
            mButtonHighlightPanel_.setVisible(false);
        }
    }

    function notifyMenuItemHighlight_(idx){
        mButtonHighlightPanel_.setVisible(true);

        local item = mBarItems_[idx];
        mButtonHighlightPanel_.setPosition(item.getPosition());
        mButtonHighlightPanel_.setSize(item.getSize());
        if(mActiveToolbar_ == null) return;

        triggerMenuForIdx_(idx);
    }

    function triggerMenuForIdx_(idx){
        if(mActiveToolbar_ != null){
            mActiveToolbar_.shutdown();
            mActiveToolbar_ = null;
        }

        local barItem = mBarItems_[idx];
        local pos = barItem.getPosition();
        pos.y += barItem.getSize().y;
        mActiveToolbar_ = ToolbarMenu(this, mData_[idx][1], mZOrderManager_, pos);

        mZOrderManager_.generateBlockerWindowForObject(EditorGUIFramework_WindowManagerObjectType.TOOLBAR);

        mBus_.transmitEvent(EditorGUIFramework_BusEvent.TOOLBAR_OPENED);
    }

    function notifyToolbarDestroyed_(){
        assert(mActiveToolbar_ != null);
        mActiveToolbar_ = null;
        mZOrderManager_.releaseBlockerWindow();
        mBus_.transmitEvent(EditorGUIFramework_BusEvent.TOOLBAR_CLOSED);
    }

    function notifyToolbarClicked_(){
        mButtonHighlightPanel_.setVisible(false);
    }

};

::EditorGUIFramework.Toolbar.ToolbarMenu <- class{

    mWindow_ = null;
    mEntries_ = null;
    mData_ = null;
    mHoverPanel_ = null;
    mCreator_ = null;
    mZOrderManager_ = null;
    mOwnedByToolbar_ = false;

    constructor(creator, data, zOrderManager, pos, ownedByToolbar=true){
        mCreator_ = creator;
        mEntries_ = array(data.len(), null);
        mWindow_ = _gui.createWindow();
        mHoverPanel_ = mWindow_.createPanel();
        mHoverPanel_.setVisible(false);
        mHoverPanel_.setDatablock("EditorGUIFramework_FrameBg");
        mData_ = data;
        mZOrderManager_ = zOrderManager;
        mOwnedByToolbar_ = ownedByToolbar;

        local posY = 0;
        print(_prettyPrint(data));
        for(local i = 0; i < data.len(); i++){
            local d = data[i];
            local name = d[0];

            local label = mWindow_.createLabel();
            label.setText(name);
            label.setPosition(0, posY);
            local button = mWindow_.createButton();
            button.setVisualsEnabled(false);
            local labelSize = label.getSize();
            button.setSize(labelSize);
            button.setPosition(0, posY);
            button.setUserId(i);
            button.attachListener(function(widget, action){
                if(action == _GUI_ACTION_PRESSED){
                    local id = widget.getUserId();
                    notifyButtonPressed_(id);
                }
                else if(action == _GUI_ACTION_HIGHLIGHTED){
                    local id = widget.getUserId();
                    notifyButtonHoverChange_(id, true);
                }
                else if(action == _GUI_ACTION_CANCEL){
                    local id = widget.getUserId();
                    notifyButtonHoverChange_(id, false);
                }
            }, this);
            posY += labelSize.y;

            mEntries_[i] = button;
        }

        local childSize = mWindow_.calculateChildrenSize();
        mWindow_.setSize(childSize.x * 1.5, childSize.y + 10);
        mWindow_.setPosition(pos);
        mWindow_.setZOrder(mZOrderManager_.getZForWindowObject(
            mOwnedByToolbar_ ?
            EditorGUIFramework_WindowManagerObjectType.TOOLBAR_MENU :
            EditorGUIFramework_WindowManagerObjectType.TOOLBAR_MENU_SOLO
        , 0));

        for(local i = 0; i < mEntries_.len(); i++){
            local e = mEntries_[i];
            e.setSize(mWindow_.getSize().x, e.getSize().y);
        }
    }

    function notifyButtonPressed_(idx){
        local targetFunc = mData_[idx][1];
        if(targetFunc != null){
            targetFunc();
        }
        mCreator_.notifyToolbarClicked_();
        shutdown();
    }

    function notifyButtonHoverChange_(idx, hovered){
        if(hovered){
            mHoverPanel_.setPosition(mEntries_[idx].getPosition());
            mHoverPanel_.setSize(mEntries_[idx].getSize());
        }
        mHoverPanel_.setVisible(hovered);
    }

    function shutdown(){
        _gui.destroy(mWindow_);
        mCreator_.notifyToolbarDestroyed_();
    }

};