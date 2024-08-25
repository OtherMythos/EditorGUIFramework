
function start(){
    _doFile("script://../src/EditorGUIFramework.nut");

    ::guiFrameworkBase <- ::EditorGUIFramework.Base();

    local width = _window.getWidth();
    local height = _window.getHeight();
    for(local i = 0; i < 50; i++){
        local win = guiFrameworkBase.createWindow("win-" + i.tostring());
        win.setPosition(_random.randInt(width), _random.randInt(height));
        win.setSize(100 + _random.randInt(50), 100 + _random.randInt(50));
    }

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