enum DrawOptions{
    WATER,
    GROUND_TYPE,
    WATER_GROUPS,
    MOISTURE_MAP,
    REGIONS,
    BLUE_NOISE,
    RIVER_DATA,
    LAND_GROUPS,
    EDGE_VALS,
    VISIBLE_REGIONS, //NOTE: Generally only used during gameplay.
    REGION_SEEDS,
    PLACE_LOCATIONS,
    VISIBLE_PLACES_MASK,

    MAX
};

enum MapViewerColours{
    VOXEL_GROUP_GROUND,
    VOXEL_GROUP_GRASS,
    VOXEL_GROUP_ICE,
    VOXEL_GROUP_TREES,
    VOXEL_GROUP_CHERRY_BLOSSOM_TREE,

    OCEAN,
    FRESH_WATER,
    WATER_GROUPS,

    COLOUR_BLACK,
    COLOUR_MAGENTA,

    UNDISCOVRED_REGION,

    MAX
};

::ExplorationMapViewer <- class extends ::MapViewer{

    mMapData_ = null;

    mColours_ = null;
    mOpacity_ = 0.4;

    mDrawOptions_ = null;
    mDrawLocationOptions_ = null;

    mCompositorDatablock_ = null
    mCompositorTexture_ = null

    mFragmentParams_ = null

    mPlaceMarkers_ = null;
    mFoundPlaces_ = null;
    mLabelWindow_ = null;
    mFoundRegions_ = null;

    constructor(){
        mDrawOptions_ = array(DrawOptions.MAX, false);
        mDrawOptions_[DrawOptions.WATER] = true;
        mDrawOptions_[DrawOptions.GROUND_TYPE] = true;
        mDrawOptions_[DrawOptions.VISIBLE_PLACES_MASK] = false;
        mDrawLocationOptions_ = array(PlaceType.MAX, true);
        mDrawLocationOptions_[PlaceType.CITY] = true;
        mDrawLocationOptions_[PlaceType.TOWN] = true;
        mDrawLocationOptions_[PlaceType.NONE] = false;

        mPlaceMarkers_ = [];
        mFoundPlaces_ = [];
        mFoundRegions_ = {};

        setupBlendblock();
        setupColours();
    }

    function shutdown(){
        base.shutdown();

        foreach(i in mFoundPlaces_){
            i.shutdown();
        }
    }

    function displayMapData(outData, showPlaceMarkers=true){
        base.displayMapData(outData, showPlaceMarkers);

        if(showPlaceMarkers){
            setupPlaceMarkers(outData);
        }
    }

    function setupPlaceMarkers(outData){
        if(mLabelWindow_ == null) return;
        for(local i = 0; i < mPlaceMarkers_.len(); i++){
            mPlaceMarkers_[i].shutdown();
        }

        mPlaceMarkers_.clear();
        foreach(c,i in outData.placeData){
            local placeMarker = PlaceMarker(mLabelWindow_, i.originX, i.originY, outData.width, outData.height, i.placeId);
            mPlaceMarkers_.append(placeMarker);
        }
    }

    function setDrawOption(option, value){
        mDrawOptions_[option] = value;
        uploadToTexture();
    }

    function setLocationDrawOption(option, value){
        mDrawLocationOptions_[option] = value;

        local f = 0;
        for(local i = 0; i < PlaceType.MAX; i++){
            if(mDrawLocationOptions_[i]){
                f = f | (1 << i);
            }
        }


        foreach(i in mPlaceMarkers_){
            i.updateForLocationFlags(f);
        }
    }

    function getDrawOption(option){
        return mDrawOptions_[option];
    }

    function getLocationDrawOption(option){
        return mDrawLocationOptions_[option];
    }

    function setupColours(){
        local colVals = array(MapViewerColours.MAX);
        local baseVal = ColourValue(0, 0, 0, 1);
        colVals[MapViewerColours.VOXEL_GROUP_GROUND] = ColourValue(0.84, 0.87, 0.29, 1);
        colVals[MapViewerColours.VOXEL_GROUP_GRASS] = ColourValue(0.33, 0.92, 0.27, 1);
        colVals[MapViewerColours.VOXEL_GROUP_ICE] = ColourValue(0.84, 0.88, 0.84, 1);
        colVals[MapViewerColours.VOXEL_GROUP_TREES] = ColourValue(0.33, 0.66, 0.005, 1);
        colVals[MapViewerColours.VOXEL_GROUP_CHERRY_BLOSSOM_TREE] = ColourValue(0.94, 0.44, 0.91, 1);
        colVals[MapViewerColours.OCEAN] = ColourValue(0, 0, 1.0, mOpacity_);
        colVals[MapViewerColours.FRESH_WATER] = ColourValue(0.15, 0.15, 1.0, mOpacity_);
        colVals[MapViewerColours.FRESH_WATER] = ColourValue(0.15, 0.15, 1.0, mOpacity_);
        colVals[MapViewerColours.WATER_GROUPS] = baseVal;
        colVals[MapViewerColours.COLOUR_BLACK] = baseVal;
        colVals[MapViewerColours.COLOUR_MAGENTA] = ColourValue(1, 0, 1, 1);
        colVals[MapViewerColours.UNDISCOVRED_REGION] = ColourValue(0.1, 0.1, 0.1, 1);

        for(local i = 0; i < colVals.len(); i++){
            colVals[i] = colVals[i].getAsABGR();
        }
        mColours_ = colVals;
    }

    function fillBufferWithMap(textureBox){
        mMapData_.voxelBuffer.seek(0);
        mMapData_.secondaryVoxBuffer.seek(0);
        for(local y = 0; y < mMapData_.height; y++){
            local yVal = (y.tofloat() / mMapData_.height) * 0x80;
            for(local x = 0; x < mMapData_.width; x++){
                local colour = _getColourForVox(x, y);
                textureBox.writen(colour, 'i');
            }
        }

        //Now determine some of the individual pixels
        foreach(i in mMapData_.placedItems){
            textureBox.seek((i.originX + i.originY * mMapData_.width) * 4);
            textureBox.writen(mColours_[MapViewerColours.COLOUR_BLACK], 'i');
        }
        if(mDrawOptions_[DrawOptions.REGION_SEEDS]){
            foreach(i in mMapData_.regionData){
                textureBox.seek((i.seedX + i.seedY * mMapData_.width) * 4);
                textureBox.writen(mColours_[MapViewerColours.COLOUR_MAGENTA], 'i');
            }
        }
    }

    function _getColourForVox(xVox, yVox){
        local voxVal = mMapData_.voxelBuffer.readn('i');
        local altitude = voxVal & 0xFF;
        local voxelMeta = (voxVal >> 8) & MAP_VOXEL_MASK;
        local waterGroup = (voxVal >> 16) & 0xFF;

        local drawVal = 0x0;

        if(mDrawOptions_[DrawOptions.GROUND_TYPE]){
            if((voxVal >> 8) & MapVoxelTypes.RIVER){
                drawVal = mColours_[MapViewerColours.FRESH_WATER];
            }else{
                drawVal = mColours_[voxelMeta];
            }
        }else{
            //NOTE: Slight optimisation.
            //Most cases will have ground type enabled, so no point doing this check unless needed.
            local val = altitude.tofloat() / 0xFF;
            drawVal = ColourValue(val, val, val, 1).getAsABGR();
        }
        if(mDrawOptions_[DrawOptions.WATER]){
            if(altitude < mMapData_.seaLevel){
                if(waterGroup == 0){
                    drawVal = mColours_[MapViewerColours.OCEAN];
                }else{
                    drawVal = mColours_[MapViewerColours.FRESH_WATER];
                }
            }
        }
        if(mDrawOptions_[DrawOptions.WATER_GROUPS]){
            local valGroup = waterGroup.tofloat() / mMapData_.waterData.len();
            drawVal = ColourValue(valGroup, valGroup, valGroup, mOpacity_).getAsABGR();
        }
        if(mDrawOptions_[DrawOptions.MOISTURE_MAP]){
            mMapData_.secondaryVoxBuffer.seek((xVox + yVox * mMapData_.width) * 4);
            local moistureVal = mMapData_.secondaryVoxBuffer.readn('i');

            local val = moistureVal.tofloat() / 0xFF;
            drawVal = ColourValue(val, val, val, 1).getAsABGR();
        }
        if(mDrawOptions_[DrawOptions.REGIONS]){
            mMapData_.secondaryVoxBuffer.seek((xVox + yVox * mMapData_.width) * 4);
            local regionVal = (mMapData_.secondaryVoxBuffer.readn('i') >> 8) & 0xFF;

            local val = regionVal.tofloat() / mMapData_.regionData.len();
            drawVal = ColourValue(val, val, val, 1).getAsABGR();
        }
        if(mDrawOptions_[DrawOptions.BLUE_NOISE]){
            mMapData_.blueNoiseBuffer.seek((xVox + yVox * mMapData_.width) * 4);
            local val = mMapData_.blueNoiseBuffer.readn('f');

            drawVal = ColourValue(val, val, val, 1).getAsABGR();
        }
        if(mDrawOptions_[DrawOptions.RIVER_DATA]){
            //local i = 0;
            mMapData_.riverBuffer.seek(0);
            local first = true;
            while(true){
                //local riverVal = mMapData_.riverBuffer[i];
                local riverVal = mMapData_.riverBuffer.readn('i');
                if(first && riverVal < 0){
                    break;
                }
                local x = (riverVal >> 16) & 0xFFFF;
                local y = riverVal & 0xFFFF;
                if(xVox == x && yVox == y){
                    drawVal = first ? mColours_[MapViewerColours.COLOUR_MAGENTA] : mColours_[MapViewerColours.COLOUR_BLACK];
                }
                first = false;
                //i++;
                if(riverVal < 0){
                    first = true;
                }
            }
        }
        if(mDrawOptions_[DrawOptions.LAND_GROUPS]){
            local landGroup = (voxVal >> 24) & 0xFF;
            local valGroup = landGroup.tofloat() / mMapData_.landData.len();
            drawVal = ColourValue(valGroup, valGroup, valGroup, mOpacity_).getAsABGR();
        }
        if(mDrawOptions_[DrawOptions.EDGE_VALS]){
            local edgeVox = (voxVal >> 8) & 0x80;
            if(edgeVox){
                drawVal = mColours_[MapViewerColours.COLOUR_BLACK];
            }
        }
        if(mDrawOptions_[DrawOptions.PLACE_LOCATIONS]){
            foreach(i in mMapData_.placeData){
                if(xVox == i.originX && yVox == i.originY){
                    drawVal = mColours_[MapViewerColours.COLOUR_BLACK];
                    break;
                }
            }
        }
        if(mDrawOptions_[DrawOptions.VISIBLE_PLACES_MASK]){
            local idx = (xVox + yVox * p.width) * 2;
            local byteIdx = int(idx / 32);
            local bitIdx = idx % 32;
            local val = (p.visiblePlaceBuffer[byteIdx] >> (bitIdx)) & 0x3;

            local col = float4(0, 0, 0, mOpacity_);
            if(val & 0x2) col = drawVal;
            else if(val & 0x1) col = float4(0.4, 0.4, 0.4, mOpacity_);

            drawVal = col;
        }
        if(mDrawOptions_[DrawOptions.VISIBLE_REGIONS]){
            local voxVal = mMapData_.secondaryVoxBuffer.readn('i');
            if(altitude >= mMapData_.seaLevel){
                local region = (voxVal >> 8) & 0xFF;
                //local valColour = region.tofloat() / mMapData_.numRegions.tofloat();
                if(!mFoundRegions_.rawin(region)){
                    drawVal = mColours_[MapViewerColours.UNDISCOVRED_REGION];
                }
            }
        }

        return drawVal;
    }

    function notifyRegionFound(regionId){
        mFoundRegions_.rawset(regionId, true);
        uploadToTexture();
    }

    function notifyNewPlaceFound(id, pos){
        if(mMapData_ == null) return;
        local placeMarker = null;
        if(id == PlaceId.GATEWAY){
            placeMarker = PlaceMarkerIcon(mLabelWindow_, mMapData_, 5);
            placeMarker.setDatablock("placeMapGateway");
            placeMarker.setZOrder(100);
        }else{
            placeMarker = PlaceMarkerIcon(mLabelWindow_, mMapData_, 3);
        }
        placeMarker.setCentre(pos.x, pos.z);

        mFoundPlaces_.append(placeMarker);
    }

}