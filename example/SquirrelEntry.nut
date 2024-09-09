
function start(){

    local saveFunction = function(){
        print("saving");
    }
    local undoFunction = function(){
        print("undo");
    }
    local redoFunction = function(){
        print("redo");
    }

    ::guiFrameworkBase <- ::EditorGUIFramework.Base();
    ::guiFrameworkBase.setToolbar(::EditorGUIFramework.Toolbar([
        ["File", [
            ["Save", saveFunction]
        ]],
        [ "Edit", [
            ["Undo", undoFunction],
            ["Redo", redoFunction],
        ]]
    ]));

    local width = _window.getWidth();
    local height = _window.getHeight();
    for(local i = 0; i < 50; i++){
        local win = guiFrameworkBase.createWindow(i, "win-" + i.tostring());
        win.setPosition(_random.randInt(width), _random.randInt(height));
        win.setSize(100 + _random.randInt(50), 100 + _random.randInt(50));
    }

    local winSecond = guiFrameworkBase.createWindow(10000, "example window");
    winSecond.setPosition(150, 150);
    winSecond.setSize(400, 400);
    winSecond.focus();

    {
        local exampleWin = winSecond.getWin();
        local layout = _gui.createLayoutLine();

        local exampleText = exampleWin.createLabel();
        exampleText.setText("Hello from the GUI framework!");
        layout.addCell(exampleText);

        local exampleButton = exampleWin.createButton();
        exampleButton.setText("button");
        layout.addCell(exampleButton);

        local numericSpinner = ::EditorGUIFramework.Widget.NumericInput(exampleWin, false, "numeric");
        numericSpinner.addToLayout(layout);
        numericSpinner.attachListener(::EditorGUIFramework.Listener(function(widget, action){
            local val = widget.getValue();
            print(val);
        }));

        local numericFloatSpinner = ::EditorGUIFramework.Widget.NumericInput(exampleWin, true, "numeric float");
        numericFloatSpinner.addToLayout(layout);
        numericFloatSpinner.attachListener(::EditorGUIFramework.Listener(function(widget, action){
            local val = widget.getValue();
            print(val);
        }));

        ::vector3Input <- ::EditorGUIFramework.Widget.Vector3Input(exampleWin, "vector3");
        vector3Input.addToLayout(layout);
        vector3Input.attachListener(::EditorGUIFramework.Listener(function(widget, action){
            local val = widget.getValue();
            print(val);
        }));
        vector3Input.setValue(Vec3(10, 20, 30));
        /*
        vector3Input.attachListener(function(widget, action){
            if(action == EditorGUIFramework_WidgetCallbackEvent.VALUE_CHANGED){
                local val = widget.getValue();
                print(val);
            }
        });
        */

        local createPopup = exampleWin.createButton();
        createPopup.setText("Show popup");
        createPopup.attachListenerForEvent(function(widget, action){
            local constructionData = [
                [EditorGUIFramework_PopupConstructionData.DESCRIPTION, "This is a popup"],
                [EditorGUIFramework_PopupConstructionData.CLOSE_BUTTON, "Close"],
                [EditorGUIFramework_PopupConstructionData.ACCEPT_BUTTON, "Accept"]
            ];
            guiFrameworkBase.createPopup(123, "test popup", constructionData);
        }, _GUI_ACTION_PRESSED, this);
        layout.addCell(createPopup);

        layout.layout();
    }

}

function update(){
    ::guiFrameworkBase.update();

    ::guiFrameworkBase.setMousePosition(_input.getMouseX(), _input.getMouseY());
    ::guiFrameworkBase.setMouseButton(EditorGUIFramework_MouseButton.LEFT, _input.getMouseButton(_MB_LEFT));
    ::guiFrameworkBase.setMouseButton(EditorGUIFramework_MouseButton.RIGHT, _input.getMouseButton(_MB_RIGHT));
}

function end(){
    ::guiFrameworkBase.shutdown();
}