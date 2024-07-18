#pragma once

#include "MapGenStep.h"

#include "GamePrerequisites.h"
#include "System/EnginePrerequisites.h"

namespace ProceduralExplorationGameCore{

    struct ExplorationMapInputData;
    struct ExplorationMapData;

    class ReduceNoiseMapGenStep : public MapGenStep{
    public:
        ReduceNoiseMapGenStep();
        ~ReduceNoiseMapGenStep();

        void processStep(const ExplorationMapInputData* input, ExplorationMapData* mapData, ExplorationMapGenWorkspace* workspace) override;
    };

    class ReduceNoiseMapGenJob{
    public:
        ReduceNoiseMapGenJob();
        ~ReduceNoiseMapGenJob();

        void processJob(ExplorationMapData* mapData, WorldCoord xa, WorldCoord ya, WorldCoord xb, WorldCoord yb);

    };

}
