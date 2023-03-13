#include <metal_stdlib>
using namespace metal;

struct PS_INPUT
{
	float2 uv0;
};

struct Params
{
   //Make it a bit bigger than needed to test things.
   unsigned int intBuffer[1000*1000];
   int width;
   int height;
   unsigned int drawFlags;
   unsigned int numWaterSeeds;
};

fragment float4 main_metal
(
	PS_INPUT inPs [[stage_in]],

	constant Params &p [[buffer(PARAMETER_SLOT)]]
)
{

   int WATER_MASK = 1 << 0;
   int GROUND_MASK = 1 << 1;
   int WATER_GROUPS = 1 << 2;

   float4 voxelColours[] = {
      float4(0.84, 0.87, 0.29, 1),
      float4(0.33, 0.92, 0.27, 1),
      float4(0.84, 0.88, 0.84, 1),
   };

   float2 uv = inPs.uv0;
   int xVox = (int)(uv.x * p.width);
   int yVox = (int)(uv.y * p.height);

   int voxVal = p.intBuffer[xVox + yVox * p.width];
   short altitude = voxVal & 0xFF;
   short voxelMeta = (voxVal >> 8) & 0xFF;
   short waterGroup = (voxVal >> 16) & 0xFF;

   float4 drawVal(0, 0, 0, 1);

   //Just draw the altitude.
   float val = (float)altitude / 255;
   drawVal = float4(val, val, val, 1);

   if(p.drawFlags & GROUND_MASK){
      drawVal = voxelColours[voxelMeta];
   }
   if(p.drawFlags & WATER_MASK){
      if(altitude < 100){
         if(waterGroup == 0){
            drawVal = float4(0, 0, 1.0, 1.0);
         }else{
            drawVal = float4(0.15, 0.15, 1.0, 1.0);
         }
      }
   }
   if(p.drawFlags & WATER_GROUPS){
      float valGroup = (float)waterGroup / p.numWaterSeeds;
      drawVal = float4(valGroup, valGroup, valGroup, 1);
   }

   return drawVal;
}
