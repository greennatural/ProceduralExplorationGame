function start(){
    _gui.setScrollSpeed(5.0);

    _doFile("res://src/Versions.nut");
    _doFile("res://src/Constants.nut");
    _doFile("res://src/Helpers.nut");
    _doFile("res://src/MapGen/Exploration/Generator/MapConstants.nut");

    _doFile("res://src/System/CompositorManager.nut");
    ::CompositorManager.setup();

    setupInitialCanvasSize();

    _doFile("res://src/Util/StateMachine.nut");
    _doFile("res://src/Util/CombatStateMachine.nut");

    _event.subscribe(_EVENT_SYSTEM_WINDOW_RESIZE, recieveWindowResize, this);

    _doFile("res://src/Base.nut");
    ::Base.setup();
}

function update(){
    ::Base.update();
}

function end(){
    ::Base.shutdown();
}

function sceneSafeUpdate(){
    if(::Base.mExplorationLogic != null){
        //::Base.mExplorationLogic.sceneSafeUpdate();
        //::Base.mExplorationLogic.mCurrentWorld_.sceneSafeUpdate();
        ::Base.mExplorationLogic.sceneSafeUpdate();
    }
}

function recieveWindowResize(id, data){
    print("window resized");
    //_gui.setCanvasSize(canvasSize, _window.getActualSize());
    _gui.setCanvasSize(_window.getSize(), _window.getActualSize());
    canvasSize = _window.getSize();
    ::ScreenManager.processResize();
}

function setupInitialCanvasSize(){
    ::canvasSize <- Vec2(1920, 1080);
    ::drawable <- canvasSize.copy();
    //::canvasSize <- Vec2(1, 1);
    ::resolutionMult <- _window.getActualSize() / _window.getSize();
    _gui.setCanvasSize(_window.getSize(), _window.getActualSize());
    _gui.setDefaultFontSize26d6((_gui.getOriginalDefaultFontSize26d6() * ::resolutionMult.x).tointeger());
}