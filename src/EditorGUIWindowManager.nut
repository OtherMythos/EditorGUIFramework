::EditorGUIFramework.WindowManager <- class{

    mBus_ = null;
    mActiveWindows_ = null
    mCurrentMousePos_ = null

    //Z indexes indexed by their internal Z.
    mZIndexes_ = null
    //Windows in order with the highest index at the end.
    //Indexes represent those give to _gui.
    mZIndexesOrdered_ = null

    MAX_WINDOWS = 100

    constructor(bus){
        mBus_ = bus;
        mActiveWindows_ = [];
        mCurrentMousePos_ = Vec2();

        mZIndexes_ = array(MAX_WINDOWS, null);
        mZIndexesOrdered_ = [];

        mBus_.subscribeObject(this);
    }

    function notifyBusEvent(event, data){
        if(event == EditorGUIFramework_BusEvent.MOUSE_BUTTON_PRESS){
            reprocessMousePosition_();
        }
    }

    function registerWindow(window){
        if(mActiveWindows_.len() + 1 >= MAX_WINDOWS){
            throw "MAX_WINDOWS has been reached.";
        }
        placeInitialZ_(window);
        //bringWindowToFront(window);
        mActiveWindows_.append(window);
    }

    function setMousePosition(pos){
        mCurrentMousePos_ = pos;
        //reprocessMousePosition_();
    }

    //Reorder the Z list so there is a space at the end.
    function freeUpperZIdx_(){
        //Head through the list backwards, until a hole is found.
        for(local i = MAX_WINDOWS-1; i >= 0; i--){
            if(mZIndexes_[i] != null) continue;
            mZIndexes_.remove(i);
            mZIndexes_.append(null);
            assert(mZIndexes_.len() == MAX_WINDOWS);
            return;
        }
        assert(false);
    }
    function placeInitialZ_(window){
        local idx = mZIndexes_.find(null);
        assert(idx != null);
        setZForWindow_(idx, window);
    }
    function setZForWindow_(z, window){
        //TODO OPTIMISATION don't 0N search it.
        local idx = mZIndexes_.find(window);
        if(idx != null){
            mZIndexes_[idx] = null;
        }
        mZIndexes_[z] = window;
        setWindowParam_(window, EditorGUIFramework_WindowParam.Z_ORDER, z);
    }

    function bringWindowToFront_(window){
        freeUpperZIdx_();
        setZForWindow_(MAX_WINDOWS-1, window);
    }
    function bringWindowToFront(window){
        bringWindowToFront_(window);
        reprocessWindowZOrder_();
    }

    function setWindowParam_(window, param, val){
        switch(param){
            case EditorGUIFramework_WindowParam.POSITION:{
                window.setParamImpl_(param, val);
                break;
            }
            case EditorGUIFramework_WindowParam.SIZE:{
                window.setParamImpl_(param, val);
                break;
            }
            case EditorGUIFramework_WindowParam.Z_ORDER:{
                window.setParamImpl_(param, val);
                break;
            }
        }
    }

    function reprocessWindowZOrder_(){
        mZIndexesOrdered_ = mZIndexes_.filter(function(index, val){
            return val != null;
        });
        assert(mZIndexesOrdered_.len() == mActiveWindows_.len());
        foreach(c,i in mZIndexesOrdered_){
            setWindowParam_(i, EditorGUIFramework_WindowParam.Z_ORDER, c);
        }
    }

    function reprocessMousePosition_(){
        local x = mCurrentMousePos_.x;
        local y = mCurrentMousePos_.y;
        foreach(c,i in mActiveWindows_){
            local p = i.mPos_;
            local s = i.mSize_;
            if(!checkIntersect_(x, y, p.x, p.y, s.x, s.y)) continue;
            //The mouse is intersecting this window.
            bringWindowToFront(i);
            return;
        }
    }
    function checkIntersect_(x, y, xx, yy, width, height){
        return (x >= xx && y >= yy && x <= xx+width && y <= yy+height);
    }

}