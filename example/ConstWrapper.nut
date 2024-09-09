function start(){
    _doFile("script://../src/EditorGUIFramework.nut");

    ::contextTable <- {};
    _doFileWithContext("res://SquirrelEntry.nut", contextTable);
    ::contextTable.start();
}
function update(){
    ::contextTable.update();
}
function end(){
    ::contextTable.end();
}