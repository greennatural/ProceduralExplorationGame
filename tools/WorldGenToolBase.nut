::WorldGenTool <- {

    mControlsWindow_ = null
    mCompositorDatablock_ = null
    mCompositorWorkspace_ = null
    mCompositorCamera_ = null
    mCompositorTexture_ = null
    mSeedLabel_ = null
    mSeedEditbox_ = null
    mVariationSeedEditbox_ = null

    mMapViewer_ = null

    mSeed_ = 0
    mVariation_ = 0

    mWinWidth_ = 1920
    mWinHeight_ = 1080

    function setup(){
        setupGui();

        setRandomSeed();
        setVariation(0);
        generate();
    }

    function update(){

    }

    function setupGui(){
        mMapViewer_ = ::MapViewer();

        local winWidth = 0.4;

        mControlsWindow_ = _gui.createWindow();
        mControlsWindow_.setSize(mWinWidth_ * winWidth, mWinHeight_);

        local layout = _gui.createLayoutLine();

        local title = mControlsWindow_.createLabel();
        title.setText("World Gen Tool");
        layout.addCell(title);

        local seedLabel = mControlsWindow_.createLabel();
        seedLabel.setText("Seed");
        layout.addCell(seedLabel);
        mSeedLabel_ = seedLabel;

        local seedEditbox = mControlsWindow_.createEditbox();
        seedEditbox.setSize(300, 50);
        layout.addCell(seedEditbox);
        mSeedEditbox_ = seedEditbox;

        local variationSeedEditbox = mControlsWindow_.createEditbox();
        variationSeedEditbox.setSize(300, 50);
        layout.addCell(variationSeedEditbox);
        mVariationSeedEditbox_ = variationSeedEditbox;

        local generateButton = mControlsWindow_.createButton();
        generateButton.setText("Generate")
        generateButton.attachListenerForEvent(function(widget, action){
            local text = mSeedEditbox_.getText();
            print("Input text: " + text.tostring());
            local intText = text.tointeger();
            ::WorldGenTool.setSeed(intText);

            local variationText = mVariationSeedEditbox_.getText();
            print("Variation text: " + variationText.tostring());
            local varIntText = variationText.tointeger();
            ::WorldGenTool.setVariation(varIntText);

            ::WorldGenTool.generate();
        }, _GUI_ACTION_PRESSED, this);
        layout.addCell(generateButton);

        local newGenButton = mControlsWindow_.createButton();
        newGenButton.setText("Random Seed")
        newGenButton.attachListenerForEvent(function(widget, action){
            ::WorldGenTool.setRandomSeed();
            ::WorldGenTool.generate();
        }, _GUI_ACTION_PRESSED);
        layout.addCell(newGenButton);

        local checkboxes = [
            "Draw water",
            "Draw ground voxels",
            "Show water group",
            "Show river data",
            "Show land group",
            "Show edge vals",
        ];
        local checkboxListener = function(widget, action){
            mMapViewer_.setDrawOption(widget.getUserId(), widget.getValue());
        };
        foreach(c,i in checkboxes){
            local checkbox = mControlsWindow_.createCheckbox();
            checkbox.setText(i);
            checkbox.setValue(mMapViewer_.getDrawOption(c));
            checkbox.setUserId(c);
            checkbox.attachListenerForEvent(checkboxListener, _GUI_ACTION_RELEASED, this);
            layout.addCell(checkbox);
        }

        layout.layout();

        local renderWindow = _gui.createWindow();
        renderWindow.setSize(mWinWidth_ * (1.0 - winWidth), mWinHeight_);
        renderWindow.setPosition(mWinWidth_ * winWidth, 0);
        renderWindow.setClipBorders(0, 0, 0, 0);
        local renderPanel = renderWindow.createPanel();
        renderPanel.setPosition(0, 0);
        renderPanel.setSize(renderWindow.getSize());
        renderPanel.setDatablock(mMapViewer_.getDatablock());
        mMapViewer_.setLabelWindow(renderWindow);
    }

    function setRandomSeed(){
        local seed = _random.randInt(0, 100000);
        setSeed(seed);
    }

    function setSeed(seedValue){
        mSeedLabel_.setText("Seed: " + seedValue.tostring());
        mSeedEditbox_.setText(seedValue.tostring());
        mSeed_ = seedValue;
    }

    function setVariation(variation){
        mVariationSeedEditbox_.setText(variation.tostring());
        mVariation_ = variation;
    }

    function generate(){
        local gen = ::MapGen();
        local data = {
            "seed": mSeed_,
            "variation": mVariation_,
            "width": 400,
            "height": 400,
            "numRivers": 24,
            "seaLevel": 100,
            "altitudeBiomes": [10, 100],
            "placeFrequency": [1, 4, 4, 10]
        };
        local outData = gen.generate(data);

        mMapViewer_.displayMapData(outData);
    }
};