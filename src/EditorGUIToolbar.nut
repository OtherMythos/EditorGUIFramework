::EditorGUIFramework.Toolbar <- class{

    mData_ = null;
    mWindow_ = null;
    mBus_ = null;

    mBarItems_ = null;

    mActiveToolbar_ = null;

    constructor(data){
        mData_ = data;
        mBarItems_ = [];
    }

    function setup_(bus){
        mBus_ = bus;
        mWindow_ = _gui.createWindow();

        mWindow_.setPosition(0, 0);
        mWindow_.setSize(_window.getWidth(), 100);

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
            button.attachListener(function(widget, action){
                if(action == _GUI_ACTION_PRESSED){
                    notifyMenuItemPress_(widget.getUserId());
                }
                else if(action == _GUI_ACTION_HIGHLIGHTED){
                    notifyMenuItemHighlight_(widget.getUserId());
                }
            }, this);
            button.setUserId(i);
            mBarItems_.append(button);
            totalX += button.getSize().x;
        }

        mWindow_.setClipBorders(0, 0, 0, 0);
        mWindow_.setSize(_window.getWidth(), mBarItems_[0].getSize().y);
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

    function notifyMenuItemHighlight_(idx){
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
        mActiveToolbar_ = ToolbarMenu(this, mData_[idx][1], pos);

        mBus_.transmitEvent(EditorGUIFramework_BusEvent.TOOLBAR_OPENED);
    }

    function notifyToolbarDestroyed_(){
        assert(mActiveToolbar_ != null);
        mActiveToolbar_ = null;
        mBus_.transmitEvent(EditorGUIFramework_BusEvent.TOOLBAR_CLOSED);
    }

};

::EditorGUIFramework.Toolbar.ToolbarMenu <- class{

    mWindow_ = null;
    mEntries_ = null;
    mData_ = null;
    mHoverPanel_ = null;
    mCreator_ = null;

    constructor(creator, data, pos){
        mCreator_ = creator;
        mEntries_ = array(data.len(), null);
        mWindow_ = _gui.createWindow();
        mHoverPanel_ = mWindow_.createPanel();
        mHoverPanel_.setVisible(false);
        mHoverPanel_.setDatablock("EditorGUIFramework_FrameBg");
        mData_ = data;

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