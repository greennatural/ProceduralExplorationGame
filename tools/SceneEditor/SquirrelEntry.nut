enum KeyScancode{
    LCTRL = 224,
    LCOMMAND = 231,
    LSHIFT = 225,

    Z = 29
};

enum KeyCommand{
    UNDO,
    REDO,

    MAX
}

function start(){
    _doFile("res://editorGUIFramework/src/EditorGUIFramework.nut");
    _doFile("res://sceneEditorFramework/SceneEditorFramework.nut");
    _gui.setDefaultFontSize26d6((_gui.getOriginalDefaultFontSize26d6()).tointeger());

    _doFile("res://SceneEditorFPSCamera.nut");
    _doFile("res://../../src/Constants.nut");
    _doFile("res://../../src/Helpers.nut");
    _doFile("res://../../src/Logic/World/TerrainChunkManager.nut");
    _doFile("res://../../src/Logic/World/TileGridPlacer.nut");

    _doFile("res://SceneEditorTerrainChunkManager.nut");
    _doFile("res://SceneEditorVoxelSelectionPopup.nut");
    _doFile("res://SceneEditorTileGridResizePopup.nut");
    _doFile("res://SceneEditor.nut");
    _doFile("res://SceneEditorDataPointWriter.nut");
    _doFile("res://TileDataWriter.nut");
    _doFile("res://SceneEditorGUITerrainToolProperties.nut");
    _doFile("res://SceneEditorGUITileGridProperties.nut");
    _doFile("res://actions/TerrainValueChangeAction.nut");
    _doFile("res://actions/TileGridChangeAction.nut");

    ::Base.setup();
}

function update(){
    ::Base.update();
}

function sceneSafeUpdate(){
    ::Base.sceneSafeUpdate();
}

function end(){
    ::Base.shutdown();
}
