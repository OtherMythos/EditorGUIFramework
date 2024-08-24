
function start(){
    _doFile("script://../src/EditorGUIFramework.nut");

    ::guiFrameworkBase <- ::EditorGUIFramework.Base();

    local win = guiFrameworkBase.createWindow("first");
    win.setPosition(100, 100);
    win.setSize(100, 100);

    local winSecond = guiFrameworkBase.createWindow("second");
    winSecond.setPosition(150, 150);
    winSecond.setSize(100, 100);
}

function update(){
    ::guiFrameworkBase.update();

    ::guiFrameworkBase.setMousePosition(_input.getMouseX(), _input.getMouseY());
    ::guiFrameworkBase.setMouseButton(0, _input.getMouseButton(_MB_LEFT));
    ::guiFrameworkBase.setMouseButton(1, _input.getMouseButton(_MB_RIGHT));
}

function end(){
    ::guiFrameworkBase.shutdown();
}