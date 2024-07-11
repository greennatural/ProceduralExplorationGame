#pragma once

#include "System/EnginePrerequisites.h"
#include "GamePrerequisites.h"

#include <vector>

namespace ProceduralExplorationGameCore{

    enum class MapVoxelTypes{
        SAND,
        DIRT,
        SNOW,
        TREES,
        TREES_CHERRY_BLOSSOM,

        DIRT_EXP_FIELD,
        SAND_EXP_FIELD,

        EDGE = 0x40,
        RIVER = 0x20,
    };

    static const AV::uint8 MapVoxelColour[] = {
        2, 112, 0, 147, 6, 198, 199,
    };

    enum class BiomeId{
        NONE,

        GRASS_LAND,
        GRASS_FOREST,
        CHERRY_BLOSSOM_FOREST,
        EXP_FIELD,

        SHALLOW_OCEAN,
        DEEP_OCEAN,

        MAX
    };

    enum class RegionType{
        NONE,

        GRASSLAND,
        CHERRY_BLOSSOM_FOREST,
        EXP_FIELDS,
        GATEWAY_DOMAIN,
        PLAYER_START,

        MAX
    };

    //The mask is used to include the edge and river flags.
    static const AV::uint32 MAP_VOXEL_MASK = 0x1F;

    struct RegionData{
        RegionId id;
        AV::uint32 total;
        AV::uint16 seedX;
        AV::uint16 seedY;
        RegionType type;
        std::vector<WorldPoint> coords;
    };

    struct FloodFillEntry{
        AV::uint32 id;
        AV::uint32 total;
        AV::uint32 seedX;
        AV::uint32 seedY;
        //AV::uint32 startingVal; //TODO figure out
        bool nextToWorldEdge = false;
        std::vector<WorldPoint> edges;
        std::vector<WorldPoint> coords;
    };

    struct ExplorationMapInputData{
        AV::uint32 width;
        AV::uint32 height;

        AV::uint32 seed;
        AV::uint32 moistureSeed;
        AV::uint32 variationSeed;

        AV::uint32 numRivers;
        AV::uint32 numRegions;
        AV::uint8 seaLevel;

        //TODO properly define how many place types are available.
        AV::uint32 placeFrequency[10];
    };

    struct ExplorationMapData{
        AV::uint32 width;
        AV::uint32 height;

        AV::uint32 seed;
        AV::uint32 moistureSeed;
        AV::uint32 variationSeed;

        AV::uint32 seaLevel;

        WorldPoint playerStart;
        WorldPoint gatewayPosition;

        void* voxelBuffer;
        void* secondaryVoxelBuffer;
        void* blueNoiseBuffer;
        size_t voxelBufferSize;
        size_t secondaryVoxelBufferSize;
        size_t blueNoiseBufferSize;
        void* riverBuffer;

        std::vector<RegionData> regionData;
        std::vector<FloodFillEntry*> waterData;
        std::vector<FloodFillEntry*> landData;

        struct BufferData{
            size_t size;
            size_t voxel;
            size_t secondaryVoxel;
            size_t blueNoise;
            size_t river;
        };
        void calculateBuffer(BufferData* buf){
            size_t voxTotal = width * height;
            buf->voxel = 0;
            buf->size += voxTotal * sizeof(AV::uint32);
            buf->secondaryVoxel = buf->size;
            buf->size += voxTotal * sizeof(AV::uint32);
            buf->blueNoise = buf->size;
        }
    };

    struct ExplorationMapGenWorkspace{
        std::vector<LandId> landWeighted;
    };

    static inline WorldPoint WRAP_WORLD_POINT(AV::uint32 x, AV::uint32 y){
        return ((x & 0xFFFF) << 16) | (y & 0xFFFF);
    }

    static inline void READ_WORLD_POINT(WorldPoint point, AV::uint32& xx, AV::uint32& yy){
        xx = (point >> 16) & 0xFFFF;
        yy = point & 0xFFFF;
    }

    static inline WorldPoint findRandomPointInLandmass(const FloodFillEntry* e){
        //NOTE Build this in with proper isolated random functions in future to prevent differentiators on the seeds.
        size_t idx = 0 + (rand() % static_cast<int>(e->coords.size() - 0 + 1));

        return e->coords[idx];
    }

    template<typename T, typename D>
    static inline T FULL_PTR_FOR_COORD(D mapData, WorldPoint p){
        AV::uint32 xx;
        AV::uint32 yy;
        READ_WORLD_POINT(p, xx, yy);
        return (reinterpret_cast<AV::uint32*>(mapData->voxelBuffer) + xx + yy * mapData->height);
    }

    template<typename T, typename D, int N>
    static inline T UINT8_PTR_FOR_COORD(D mapData, WorldPoint p){
        return reinterpret_cast<AV::uint8*>(FULL_PTR_FOR_COORD<AV::uint32*, D>(mapData, p)) + N;
    }

    static inline AV::uint8* VOX_PTR_FOR_COORD(ExplorationMapData* mapData, WorldPoint p){
        return UINT8_PTR_FOR_COORD<AV::uint8*, ExplorationMapData*, 0>(mapData, p);
    }
    static inline AV::uint8* WATER_GROUP_PTR_FOR_COORD(ExplorationMapData* mapData, WorldPoint p){
        return UINT8_PTR_FOR_COORD<AV::uint8*, ExplorationMapData*, 2>(mapData, p);
    }
    static inline AV::uint8* LAND_GROUP_PTR_FOR_COORD(ExplorationMapData* mapData, WorldPoint p){
        return UINT8_PTR_FOR_COORD<AV::uint8*, ExplorationMapData*, 3>(mapData, p);
    }
    //Const
    static inline const AV::uint8* VOX_PTR_FOR_COORD_CONST(const ExplorationMapData* mapData, WorldPoint p){
        return UINT8_PTR_FOR_COORD<const AV::uint8*, const ExplorationMapData*, 0>(mapData, p);
    }
    static inline const AV::uint8* WATER_GROUP_PTR_FOR_COORD_CONST(const ExplorationMapData* mapData, WorldPoint p){
        return UINT8_PTR_FOR_COORD<const AV::uint8*, const ExplorationMapData*, 2>(mapData, p);
    }
    static inline const AV::uint8* LAND_GROUP_PTR_FOR_COORD_CONST(const ExplorationMapData* mapData, WorldPoint p){
        return UINT8_PTR_FOR_COORD<const AV::uint8*, const ExplorationMapData*, 3>(mapData, p);
    }

    static inline AV::uint8* REGION_PTR_FOR_COORD(ExplorationMapData* mapData, WorldPoint p){
        return UINT8_PTR_FOR_COORD<AV::uint8*, ExplorationMapData*, 1>(mapData, p);
    }
    static inline const AV::uint8* REGION_PTR_FOR_COORD_CONST(ExplorationMapData* mapData, WorldPoint p){
        return UINT8_PTR_FOR_COORD<const AV::uint8*, const ExplorationMapData*, 1>(mapData, p);
    }

    static size_t mapGenRandomIntMinMax(size_t min, size_t max){
        return min + (rand() % static_cast<size_t>(max - min + 1));
    }
    template<typename T>
    static size_t mapGenRandomIndex(const std::vector<T>& list){
        return mapGenRandomIntMinMax(0, list.size());
    }
    static LandId findRandomLandmassForSize(const std::vector<FloodFillEntry*>& landData, const std::vector<LandId>& landWeighted, AV::uint32 size){
        //To avoid infinite loops.
        for(int i = 0; i < 100; i++){
            size_t randIndex = mapGenRandomIndex<LandId>(landWeighted);
            LandId idx = landWeighted[randIndex];
            if(landData[idx]->total >= size){
                return idx;
            }
        }
        return INVALID_LAND_ID;
    }

}
