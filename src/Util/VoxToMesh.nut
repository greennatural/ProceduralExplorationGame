/**
 * A helper class to generate a triangulated mesh from voxel data.
 */
::VoxToMesh <- class{

    MASKS = null;
    FACES_VERTICES = null;
    VERTICES_POSITIONS = null;

    mVertexElemVec_ = null;

    constructor(){

        MASKS = array(6);
        local M = function(x, y, z){
            return (1 << ((x + 1) + (y + 1) * 3 + (z + 1) * 9))
        }
        MASKS[0] = M(0, -1, 0);
        MASKS[1] = M(0, 1, 0);
        MASKS[2] = M(0, 0, -1);
        MASKS[3] = M(0, 0, 1);
        MASKS[4] = M(1, 0, 0);
        MASKS[5] = M(-1, 0, 0);

        FACES_VERTICES = [
            0, 1, 2, 3,
            5, 4, 7, 6,
            0, 4, 5, 1,
            2, 6, 7, 3,
            1, 5, 6, 2,
            0, 3, 7, 4
        ];
        VERTICES_POSITIONS = [
            0.0, 0.0, 0.0,
            1.0, 0.0, 0.0,
            1.0, 0.0, 1.0,
            0.0, 0.0, 1.0,
            0.0, 1.0, 0.0,
            1.0, 1.0, 0.0,
            1.0, 1.0, 1.0,
            0.0, 1.0, 1.0
        ];


        mVertexElemVec_ = _graphics.createVertexElemVec();
        mVertexElemVec_.pushVertexElement(_VET_FLOAT3, _VES_POSITION);
        //vertexElemVec.pushVertexElement(_VET_FLOAT2, _VES_TEXTURE_COORDINATES);

    }


    /**
     * Generate a mesh object from the provided voxel data.
     * @param voxData A three dimensional blob containing voxel definitions from top to bottom, left to right. A single voxel is a byte and the size must match up with the provided dimensions.
     */
    function createMeshForVoxelData(meshName, voxData, width, height, depth){
        assert(voxData.len() == width * height * depth);
        local outMesh = _graphics.createManualMesh(meshName);
        local subMesh = outMesh.createSubMesh();

        local verts = [];
        local indices = [];

        local index = 0;
        local numVerts = 0;
        for(local z = 0; z < depth; z++)
        for(local y = 0; y < height; y++)
        for(local x = 0; x < width; x++){
            local v = readVoxelFromData_(voxData, x, y, z, width, height);
            if(v == 0) continue;
            local neighbourMask = getNeighbourMask(voxData, x, y, z, width, height, depth);
            //printf("drawing voxel %i %i %i", x, y, z);
            //printf("Neighbour mask %i", neighbourMask);
            for(local f = 0; f < 6; f++){
                if(!blockIsFaceVisible(neighbourMask, f)) continue;
                //printf("Drawing face %i", f);
                for(local i = 0; i < 4; i++){
                    verts.append(VERTICES_POSITIONS[FACES_VERTICES[f * 4 + i]*3] + x);
                    verts.append(VERTICES_POSITIONS[FACES_VERTICES[f * 4 + i]*3 + 1] + y);
                    verts.append(VERTICES_POSITIONS[FACES_VERTICES[f * 4 + i]*3 + 2] + z);
                    numVerts++;
                }
                indices.append(index + 0);
                indices.append(index + 1);
                indices.append(index + 2);
                indices.append(index + 2);
                indices.append(index + 3);
                indices.append(index + 0);
                index += 4;
            }
        }
        assert(numVerts == verts.len() / 3);

        local b = blob(verts.len() * 4);
        b.seek(0);
        foreach(i in verts){
            b.writen(i, 'f');
        }
        local bb = blob(indices.len() * 2);
        bb.seek(0);
        foreach(i in indices){
            bb.writen(i, 'w');
        }

        local buffer = _graphics.createVertexBuffer(mVertexElemVec_, numVerts, numVerts, b);
        local indexBuffer = _graphics.createIndexBuffer(_IT_16BIT, bb, indices.len());

        local vao = _graphics.createVertexArrayObject(buffer, indexBuffer, _OT_TRIANGLE_LIST);

        subMesh.pushMeshVAO(vao, _VP_NORMAL);

        local bounds = AABB(Vec3(), Vec3());
        outMesh.setBounds(bounds);
        outMesh.setBoundingSphereRadius(1.732);

        //TODO don't keep this here.
        local item = _scene.createItem(outMesh);
        //item.setDatablock("textureUnlit");
        local newNode = _scene.getRootSceneNode().createChildSceneNode();
        newNode.attachObject(item);

        return newNode;
    }

    function readVoxelFromData_(data, x, y, z, width, height){
        return data[x + (y * width) + (z*width*height)];
    }

    function getNeighbourMask(data, x, y, z, width, height, depth){
        local ret = 0;
        local i = 0;
        for(local zz = -1; zz <= 1; zz++){
            local zPos = z + zz;
            if(zPos < 0 || zPos >= depth) continue;
            for(local yy = -1; yy <= 1; yy++){
                local yPos = y + yy;
                if(yPos < 0 || yPos >= height) continue;
                for(local xx = -1; xx <= 1; xx++) {
                    local xPos = x + xx;
                    if(xPos < 0 || xPos >= width) continue;
                    local v = readVoxelFromData_(data, xPos, yPos, zPos, width, height);
                    if(v != 0) ret = ret | (1 << i)
                    i++;
                }
            }
        }
        return ret;
    }

    function blockIsFaceVisible(mask, f){
        return !(MASKS[f] & mask);
    }

};