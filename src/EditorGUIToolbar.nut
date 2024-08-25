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
        mActiveToolbar_ = ToolbarMenu(mData_[idx][1], pos);

        mBus_.transmitEvent(EditorGUIFramework_BusEvent.TOOLBAR_OPENED);
    }

};

::EditorGUIFramework.Toolbar.ToolbarMenu <- class{

    mWindow_ = null;

    constructor(data, pos){
        mWindow_ = _gui.createWindow();

        local posY = 0;
        print(_prettyPrint(data));
        for(local i = 0; i < data.len(); i++){
            local d = data[i];
            local name = d[0];
            local func = d[1];

            local label = this.mWindow_.createLabel();
            label.setText(name);
            label.setPosition(0, posY);
            posY += label.getSize().y;
        }

        local childSize = mWindow_.calculateChildrenSize();
        mWindow_.setSize(childSize.x * 1.5, childSize.y + 10);
        mWindow_.setPosition(pos);
    }

    function shutdown(){
        _gui.destroy(mWindow_);
    }

};