/**
 * Interface to abstract aspects of the editor interface.
 * Users can override this provided interface to modify functionality.
 */
::EditorGUIFramework.Interface <- class{

    function print(msg){
        ::print(msg);
    }

    function setCursor(cursor){
        _window.setCursor(cursor);
    }

};
