//EditorGUIFramework

::EditorGUIFramework <- {};

::EditorGUIFramework.float2_ <- function(x, y){
    local pos = null;
    if(y == null){
        pos = x;
    }else{
        pos = Vec2(x, y);
    }
    return pos;
}

_doFile("script://EditorGUIConstants.nut");
_doFile("script://EditorGUIInterface.nut");
_doFile("script://EditorGUISettings.nut");

_doFile("script://EditorGUIObject.nut");
_doFile("script://EditorGUIBase.nut");
_doFile("script://EditorGUIBus.nut");
_doFile("script://EditorGUIWindowManager.nut");
_doFile("script://EditorGUIWindow.nut");
_doFile("script://EditorGUIToolbar.nut");

::EditorGUIFramework.Widget <- {};

_doFile("script://widgets/EditorGUIWidgetNumericInput.nut");