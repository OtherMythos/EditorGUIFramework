enum EditorGUIFramework_BusEvent{
    NONE,

    MOUSE_BUTTON_PRESS,
    MOUSE_BUTTON_RELEASE,
    MOUSE_POS_CHANGE,

    WINDOW_MOVE_DRAG_BEGAN,

    TOOLBAR_OPENED,
    TOOLBAR_CLOSED,

    INPUT_BLOCKER_CLICKED,
};
enum EditorGUIFramework_BusRequest{
    NONE,

    SET_CURSOR,
    RESET_CURSOR,
};

enum EditorGUIFramework_WindowParam{
    NONE,

    POSITION,
    SIZE,
    Z_ORDER,
    FOCUS,

    MAX
};

enum EditorGUIFramework_MouseButton{
    LEFT,
    RIGHT,
    MIDDLE,

    MAX
};

enum EditorGUIFramework_WindowManagerState{
    NONE,

    WINDOW_DRAG,
    WINDOW_RESIZE,

    TOOLBAR_OPEN,

    MAX
};


enum EditorGUIFramework_WindowManagerStateEvent{
    NONE,

    WINDOW_DRAG,
    WINDOW_RESIZE,
    MOUSE_LEFT_CHANGE,
    MOUSE_RIGHT_CHANGE,

    WINDOW_CLOSED,

    TOOLBAR_OPENED,
    TOOLBAR_CLOSED,

    MAX
};

enum EditorGUIFramework_WindowManagerObjectType{
    NONE,

    WINDOW,
    INPUT_BLOCKER,
    TOOLBAR,
    TOOLBAR_MENU
};

enum EditorGUIFramework_WidgetCallbackEvent{
    VALUE_CHANGED
};