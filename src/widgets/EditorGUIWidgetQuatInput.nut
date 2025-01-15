::EditorGUIFramework.Widget.QuatInput <- class extends ::EditorGUIFramework.Widget.Vector3Input{

    numWidgets = 4;

    constructor(parent, label=null){
        base.constructor(parent, label);
    }

    function getValue(){
        local outQuat = Quat(
            axisEntries_[0].getValue(),
            axisEntries_[1].getValue(),
            axisEntries_[2].getValue(),
            axisEntries_[3].getValue()
        );
        return outQuat;
    }

    function setValue(val){
        axisEntries_[0].setValue(val.x);
        axisEntries_[1].setValue(val.y);
        axisEntries_[2].setValue(val.z);
        axisEntries_[3].setValue(val.w);
    }

    function _tostring(){
        return ::wrapToString(this, "QuatInput", getValue().tostring());
    }

};