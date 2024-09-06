::EditorGUIFramework.Widget.Vector3Input <- class extends ::EditorGUIFramework.Object{

    axisEntries_ = null;
    axisLayout_ = null;
    labelString_ = null;

    mVecListener_ = null;

    constructor(parent, label=null){
        axisEntries_ = [];
        axisLayout_ = _gui.createLayoutLine(_LAYOUT_HORIZONTAL);
        labelString_ = label;

        local listenerObj = ::EditorGUIFramework.Listener(axisCallback, this);
        for(local i = 0; i < 3; i++){
            local axis = ::EditorGUIFramework.Widget.NumericInput(parent, true);
            axis.setValue(0);
            axis.attachParentListener(listenerObj);
            axisEntries_.append(axis);
            axis.addToLayout(axisLayout_);
        }

        if(labelString_ != null){
            local labelWidget = parent.createLabel();
            labelWidget.setText(labelString_);
            axisLayout_.addCell(labelWidget);
        }

        axisLayout_.setMarginForAllCells(0, 0);
        axisEntries_[0].mWidget_.setMargin(0, 0);
        axisLayout_.layout();
    }

    function addToLayout(layout){
        layout.addCell(axisLayout_);
    }

    #Override
    function attachListener(listener){
        mVecListener_ = listener;
    }

    function axisCallback(widget, action){
        if(mVecListener_ != null){
            mVecListener_.call(this, action);
        }
    }

    function getValue(){
        local outVec = Vec3(
            axisEntries_[0].getValue(),
            axisEntries_[1].getValue(),
            axisEntries_[2].getValue()
        );
        return outVec;
    }

    function setValue(val){
        axisEntries_[0].setValue(val.x);
        axisEntries_[1].setValue(val.y);
        axisEntries_[2].setValue(val.z);
    }

};