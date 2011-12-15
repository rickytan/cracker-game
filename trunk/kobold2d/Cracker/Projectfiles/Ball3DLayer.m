//
//  Ball3DWorld.m
//  Cracker
//
//  Created by  on 11-12-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "Ball3DLayer.h"
#import "CC3PODResourceNode.h"
#import "CC3ActionInterval.h"
#import "CC3MeshNode.h"
#import "CC3ParametricMeshNodes.h"
#import "CC3Camera.h"
#import "CC3Light.h"
#import "CC3VertexArrays.h"
#import "CC3VertexArrayMesh.h"
#import "CC3GLMatrix.h"



@interface Ball3DWorld : CC3World {
    CC3Camera *                 _cam;    // Weak assign
    CC3PlaneNode *              _ball;   // Weak assign
    CC3BoxNode *                _box;    // Weak assign
    CC3BoxNode *                _floor;  // Weak assign
    CC3Node *                   _floorNode;  // Weak assign
    CGFloat                     _ballRadius;
    CGSize                      boxBound;
    CC3BoundingBox              bounds;
}

- (void)setBallLocation:(CGPoint)ballLocation;
- (void)setBallRotation:(CGFloat)ballRotation;
- (CGPoint)getBallLocation;
- (CGFloat)getBallRadius;
- (CGPoint)toBoxPoint:(CGPoint)screen;
- (CGPoint)toScreenPoint:(CGPoint)box;
- (CC3BoxNode*)createScreenBox:(CC3BoundingBox)bounds;
- (void)tiltBox:(CC3BoxNode*)boxNode 
        inBound:(CC3BoundingBox)box 
          withX:(CGFloat)radiansX 
           andY:(CGFloat)radiansY;
- (void)addChildToFloor:(CC3Node*)child;
@end

@implementation Ball3DWorld


#pragma mark - Overrided Methods

-(void) initializeWorld
{
	// Create the camera, place it back a bit
	_cam = [CC3Camera nodeWithName: @"Camera"];
	_cam.location = cc3v(0.0, 0.0, 10.0);
    _ballRadius = 0.3f;
    
	[self addChild:_cam];
    
	// Create a light, place it and make it shine in all directions (not directional)
	CC3Light* lamp = [CC3Light nodeWithName: @"Lamp"];
	//lamp.location = cc3v(0.0, 0.0, 0.0);
	lamp.isDirectionalOnly = NO;
    //lamp.color = ccc3(0xff, 0xff, 0xff);
    lamp.specularColor = kCCC4FWhite;
    lamp.ambientColor = kCCC4FWhite;
    lamp.diffuseColor = kCCC4FWhite;
	[_cam addChild:lamp];
    
    const CGFloat ratio = 60;
    CGSize s = [CCDirector sharedDirector].winSize;
    boxBound.width = s.width / ratio;
    boxBound.height = s.height / ratio;
    
    bounds = CC3BoundingBoxMake(-boxBound.width/2, -boxBound.height/2, -.5, 
                                               boxBound.width/2,  boxBound.height/2, 0.0);
    
    _box = [self createScreenBox:bounds];
    
    _box.specularColor = kCCC4FWhite;
    _box.diffuseColor = kCCC4FWhite;
    _box.ambientColor = kCCC4FWhite;
    _box.texture = [CC3Texture textureFromFile:@"wood2.jpg"];
    
    [self addChild:_box];
    
    _floorNode = [CC3Node nodeWithName:@"floornode"];
    _floorNode.location = cc3v(0, 0, bounds.minimum.z);
    [_box addChild:_floorNode];
    
    _floor = [CC3PlaneNode nodeWithName:@"floor"];
    [_floor populateAsTexturedRectangleWithSize:CGSizeMake(2*_ballRadius, 2*_ballRadius) 
                                       andPivot:ccp(_ballRadius, _ballRadius)];
    _floor.texture = [CC3Texture textureFromFile:@"ball.png"];
    [_floor shouldUseLighting];
    [_floor alignInvertedTextures];
    _floor.material.isOpaque = YES;
    _floor.material.sourceBlend = GL_SRC_ALPHA;
    _floor.material.destinationBlend = GL_ONE_MINUS_SRC_ALPHA;
    _floor.shouldCullBackFaces = NO;
    [self addChildToFloor:_floor];

    
    _ball = [CC3PlaneNode nodeWithName:@"ball"];
    [_ball populateAsTexturedRectangleWithSize:CGSizeMake(2*_ballRadius, 2*_ballRadius) 
                                      andPivot:ccp(_ballRadius, _ballRadius)];
    _ball.texture = [CC3Texture textureFromFile:@"ball.png"];
    [_ball shouldUseLighting];
    [_ball alignInvertedTextures];
    _ball.material.isOpaque = YES;
    _ball.material.sourceBlend = GL_SRC_ALPHA;
    _ball.material.destinationBlend = GL_ONE_MINUS_SRC_ALPHA;
    _ball.shouldCullBackFaces = NO;
    
    //[_ball retainVertexLocations];
    
    _ball.location = cc3v(0, 0, bounds.minimum.z+_ballRadius);
    [_box addChild:_ball];
    
	
	// Create OpenGL ES buffers for the vertex arrays to keep things fast and efficient,
	// and to save memory, release the vertex data in main memory because it is now redundant.
	[self createGLBuffers];
    [self releaseRedundantData];
}

-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor 
{
    
}

-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor 
{

}

-(void) updateWorld:(ccTime)dt
{
    [super updateWorld:dt];
    
    CCDirector* director = [CCDirector sharedDirector];
    
    KKInput* input = [KKInput sharedInput];
    if (director.currentDeviceIsSimulator == NO)
    {
        KKDeviceMotion* m = input.deviceMotion;
        float xd = (-m.roll) ;
        float yd = (m.pitch) ;
        
        const float tmaxx =  M_PI / 180 * 8;
        const float tmaxy = M_PI / 180 * 12;
        xd = xd<tmaxx?(xd>-tmaxx?xd:-tmaxx):tmaxx;
        yd = yd<tmaxy?(yd>-tmaxy?yd:-tmaxy):tmaxy;
        
        //_box.rotation = cc3v(-xd, -yd,0.0);
        GLfloat glMat[] = {
            1,0,0,0,
            0,1,0,0,
            0,0,1,0,
            0,0,0,1
        };
        glMat[8] = -xd;
        glMat[9] = -yd;
        CC3GLMatrix *matrix = [CC3GLMatrix matrixFromGLMatrix:glMat];
        _box.transformMatrix = matrix;
        [_floorNode markTransformDirty];
        //[_box.transformMatrix multiplyByMatrix:matrix];
        /*
        [self tiltBox:_box
              inBound:bounds
                withX:xd
                 andY:yd];
         */

    }
}

#pragma mark - Methods
- (CGPoint)toBoxPoint:(CGPoint)screen
{
    CGPoint p;
    CGSize s = [CCDirector sharedDirector].winSize;
    screen = ccpSub(screen, ccp(s.width*0.5, s.height*0.5));
    p.x = screen.x / s.width * boxBound.width;
    p.y = screen.y / s.height * boxBound.height;
    return p;
}

- (CGPoint)toScreenPoint:(CGPoint)box
{
    CGPoint p;
    CGSize s = [CCDirector sharedDirector].winSize;
    box = ccpAdd(box, ccp(boxBound.width*0.5, boxBound.height*0.5));
    p.x = box.x / boxBound.width * s.width;
    p.y = box.y / boxBound.height * s.height;
    return p;
}

- (void)setBallLocation:(CGPoint)screenPoint
{
    CGPoint p = [self toBoxPoint:screenPoint];
    _ball.location = cc3v(p.x, p.y,  bounds.minimum.z+_ballRadius);
}

- (void)setBallRotation:(CGFloat)ballRotation
{
    _ball.rotationAxis = cc3v(0, 0, 1);
    //_ball.rotationAngle = ballRotation;
}

- (CGPoint)getBallLocation
{
    CGPoint p = ccp(_ball.location.x, _ball.location.y);
    return [self toScreenPoint:p];
}

- (CGFloat)getBallRadius
{
    CGSize s = [CCDirector sharedDirector].winSize;
    return _ballRadius / boxBound.width * s.width;
}

- (CC3BoxNode*)createScreenBox:(CC3BoundingBox)box
{
    CGPoint corner = {1.0,1.0};
    NSString* itemName;
    CC3TexturedVertex* vertices;		// Array of custom structures to hold the interleaved vertex data
    CC3Vector boxMin = box.minimum;
    CC3Vector boxMax = box.maximum;
    GLuint vertexCount = 20;
    
    // Create vertexLocation array.
    itemName = [NSString stringWithFormat: @"%@-Locations", self.name];
    CC3VertexLocations* locArray = [CC3VertexLocations vertexArrayWithName: itemName];
    locArray.elementStride = sizeof(CC3TexturedVertex);	// Set stride before allocating elements.
    locArray.elementOffset = 0;							// Offset to location element in vertex structure
    vertices = [locArray allocateElements: vertexCount];
    
    // Create the normal array interleaved on the same element array
    itemName = [NSString stringWithFormat: @"%@-Normals", self.name];
    CC3VertexNormals* normArray = [CC3VertexNormals vertexArrayWithName: itemName];
    normArray.elements = vertices;
    normArray.elementStride = locArray.elementStride;	// Interleaved...so same stride
    normArray.elementCount = vertexCount;
    normArray.elementOffset = sizeof(CC3Vector);		// Offset to normal element in vertex structure
    
    // Create the tex coord array interleaved on the same element array as the vertex locations
    CC3VertexTextureCoordinates* tcArray = nil;
    itemName = [NSString stringWithFormat: @"%@-Texture", self.name];
    tcArray = [CC3VertexTextureCoordinates vertexArrayWithName: itemName];
    tcArray.elements = vertices;
    tcArray.elementStride = locArray.elementStride;		// Interleaved...so same stride
    tcArray.elementCount = vertexCount;
    tcArray.elementOffset = 2 * sizeof(CC3Vector);		// Offset to texCoord element in vertex structure
    
    /*
    // Front face, CCW winding:
    vertices[0].location = cc3v(boxMin.x, boxMin.y, boxMax.z);
    vertices[0].normal = kCC3VectorUnitZPositive;
    vertices[0].texCoord = (ccTex2F){corner.x, corner.y};
    
    vertices[1].location = cc3v(boxMax.x, boxMin.y, boxMax.z);
    vertices[1].normal = kCC3VectorUnitZPositive;
    vertices[1].texCoord = (ccTex2F){0.5f, corner.y};
    
    vertices[2].location = cc3v(boxMax.x, boxMax.y, boxMax.z);
    vertices[2].normal = kCC3VectorUnitZPositive;
    vertices[2].texCoord = (ccTex2F){0.5f, (1.0f - corner.y)};
    
    vertices[3].location = cc3v(boxMin.x, boxMax.y, boxMax.z);
    vertices[3].normal = kCC3VectorUnitZPositive;
    vertices[3].texCoord = (ccTex2F){corner.x, (1.0f - corner.y)};
     */
    
    // Right face, CCW winding:
    vertices[0].location = cc3v(boxMax.x, boxMin.y, boxMax.z);
    vertices[0].normal = kCC3VectorUnitXNegative;
    vertices[0].texCoord = (ccTex2F){0.5f, corner.y};
    
    vertices[3].location = cc3v(boxMax.x, boxMin.y, boxMin.z);
    vertices[3].normal = kCC3VectorUnitXNegative;
    vertices[3].texCoord = (ccTex2F){(0.5f + corner.x), corner.y};
    
    vertices[2].location = cc3v(boxMax.x, boxMax.y, boxMin.z);
    vertices[2].normal = kCC3VectorUnitXNegative;
    vertices[2].texCoord = (ccTex2F){(0.5f + corner.x), (1.0f - corner.y)};
    
    vertices[1].location = cc3v(boxMax.x, boxMax.y, boxMax.z);
    vertices[1].normal = kCC3VectorUnitXNegative;
    vertices[1].texCoord = (ccTex2F){0.5f, (1.0f - corner.y)};
    
    // Back face, CCW winding:
    vertices[4].location = cc3v(boxMin.x, boxMax.y, boxMin.z);
    vertices[4].normal = kCC3VectorUnitZPositive;
    vertices[4].texCoord = (ccTex2F){1.0f, (1.0f - corner.y)};
    
    vertices[6].location = cc3v(boxMax.x, boxMin.y, boxMin.z);
    vertices[6].normal = kCC3VectorUnitZPositive;
    vertices[6].texCoord = (ccTex2F){(0.5f + corner.x), corner.y};
    
    vertices[5].location = cc3v(boxMin.x, boxMin.y, boxMin.z);
    vertices[5].normal = kCC3VectorUnitZPositive;
    vertices[5].texCoord = (ccTex2F){1.0f, corner.y};

    vertices[7].location = cc3v(boxMax.x, boxMax.y, boxMin.z);
    vertices[7].normal = kCC3VectorUnitZPositive;
    vertices[7].texCoord = (ccTex2F){(0.5f + corner.x), (1.0f - corner.y)};
    
    // Left face, CCW winding:
    vertices[8].location = cc3v(boxMin.x, boxMin.y, boxMin.z);
    vertices[8].normal = kCC3VectorUnitXPositive;
    vertices[8].texCoord = (ccTex2F){0.0f, corner.y};
    
    vertices[11].location = cc3v(boxMin.x, boxMin.y, boxMax.z);
    vertices[11].normal = kCC3VectorUnitXPositive;
    vertices[11].texCoord = (ccTex2F){corner.x, corner.y};
    
    vertices[10].location = cc3v(boxMin.x, boxMax.y, boxMax.z);
    vertices[10].normal = kCC3VectorUnitXPositive;
    vertices[10].texCoord = (ccTex2F){corner.x, (1.0f - corner.y)};
    
    vertices[9].location = cc3v(boxMin.x, boxMax.y, boxMin.z);
    vertices[9].normal = kCC3VectorUnitXPositive;
    vertices[9].texCoord = (ccTex2F){0.0f, (1.0f - corner.y)};
    
    // Top face, CCW winding:
    vertices[12].location = cc3v(boxMin.x, boxMax.y, boxMin.z);
    vertices[12].normal = kCC3VectorUnitXNegative;
    vertices[12].texCoord = (ccTex2F){corner.x, 1.0f};
    
    vertices[15].location = cc3v(boxMin.x, boxMax.y, boxMax.z);
    vertices[15].normal = kCC3VectorUnitXNegative;
    vertices[15].texCoord = (ccTex2F){corner.x, (1.0f - corner.y)};
    
    vertices[14].location = cc3v(boxMax.x, boxMax.y, boxMax.z);
    vertices[14].normal = kCC3VectorUnitXNegative;
    vertices[14].texCoord = (ccTex2F){0.5f, (1.0f - corner.y)};
    
    vertices[13].location = cc3v(boxMax.x, boxMax.y, boxMin.z);
    vertices[13].normal = kCC3VectorUnitXNegative;
    vertices[13].texCoord = (ccTex2F){0.5f, 1.0f};
    
    // Bottom face, CCW winding:
    vertices[16].location = cc3v(boxMin.x, boxMin.y, boxMax.z);
    vertices[16].normal = kCC3VectorUnitYPositive;
    vertices[16].texCoord = (ccTex2F){corner.x, corner.y};
    
    vertices[19].location = cc3v(boxMin.x, boxMin.y, boxMin.z);
    vertices[19].normal = kCC3VectorUnitYPositive;
    vertices[19].texCoord = (ccTex2F){0.5f, corner.y};
    
    vertices[18].location = cc3v(boxMax.x, boxMin.y, boxMin.z);
    vertices[18].normal = kCC3VectorUnitYPositive;
    vertices[18].texCoord = (ccTex2F){0.5f, 0.0f};
    
    vertices[17].location = cc3v(boxMax.x, boxMin.y, boxMax.z);
    vertices[17].normal = kCC3VectorUnitYPositive;
    vertices[17].texCoord = (ccTex2F){corner.x, 0.0f};
    
    // Construct the vertex indices that will draw the triangles that make up each
    // face of the box. Indices are ordered for each of the six faces starting in
    // the lower left corner and proceeding counter-clockwise.
    GLuint triangleCount = 10;
    GLuint indexCount = triangleCount * 3;
    itemName = [NSString stringWithFormat: @"%@-Indices", self.name];
    CC3VertexIndices* indexArray = [CC3VertexIndices vertexArrayWithName: itemName];
    indexArray.drawingMode = GL_TRIANGLES;
    indexArray.elementType = GL_UNSIGNED_BYTE;
    GLubyte* indices = [indexArray allocateElements: indexCount];
    
    GLubyte indxIndx = 0;
    GLubyte vtxIndx = 0;
    for (int side = 0; side < 5; side++) {
        // First trangle of side - CCW from bottom left
        indices[indxIndx++] = vtxIndx++;		// vertex 0
        indices[indxIndx++] = vtxIndx++;		// vertex 1
        indices[indxIndx++] = vtxIndx;			// vertex 2
        
        // Second triangle of side - CCW from bottom left
        indices[indxIndx++] = vtxIndx++;		// vertex 2
        indices[indxIndx++] = vtxIndx++;		// vertex 3
        indices[indxIndx++] = (vtxIndx - 4);	// vertex 0
    }
    
    // Create mesh with interleaved vertex arrays
    itemName = [NSString stringWithFormat: @"%@-Mesh", self.name];
    CC3VertexArrayMesh* aMesh = [CC3VertexArrayMesh meshWithName: itemName];
    aMesh.interleaveVertices = YES;
    aMesh.vertexLocations = locArray;
    aMesh.vertexNormals = normArray;
    aMesh.vertexTextureCoordinates = tcArray;
    aMesh.vertexIndices = indexArray;
    
    CC3BoxNode *meshBox = [CC3BoxNode node];
    meshBox.mesh = aMesh;
    return meshBox;
    //self.mesh = aMesh;
}

- (void)tiltBox:(CC3BoxNode *)boxNode
        inBound:(CC3BoundingBox)box 
          withX:(CGFloat)radiansX 
           andY:(CGFloat)radiansY
{
    CC3TexturedVertex* vertices = ((CC3VertexArrayMesh*)boxNode.mesh).vertexTextureCoordinates.elements;		// Array of custom structures to hold the interleaved vertex data
    CC3Vector boxMin = box.minimum;
    CC3Vector boxMax = box.maximum;
    
    CGFloat height = boxMax.z - boxMin.z;

    // Right face, CCW winding:
    //vertices[0].location = cc3v(boxMax.x, boxMin.y, boxMax.z);
    vertices[3].location = cc3v(boxMax.x + radiansX*height, boxMin.y + radiansY*height, boxMin.z);
    vertices[2].location = cc3v(boxMax.x + radiansX*height, boxMax.y + radiansY*height, boxMin.z);
    //vertices[1].location = cc3v(boxMax.x, boxMax.y, boxMax.z);
    
    // Back face, CCW winding:
    vertices[4].location = cc3v(boxMin.x + radiansX*height, boxMax.y + radiansY*height, boxMin.z);
    vertices[6].location = cc3v(boxMax.x + radiansX*height, boxMin.y + radiansY*height, boxMin.z);
    vertices[5].location = cc3v(boxMin.x + radiansX*height, boxMin.y + radiansY*height, boxMin.z);
    vertices[7].location = cc3v(boxMax.x + radiansX*height, boxMax.y + radiansY*height, boxMin.z);
    
    // Left face, CCW winding:
    vertices[8].location = cc3v(boxMin.x + radiansX*height, boxMin.y + radiansY*height, boxMin.z);
    //vertices[11].location = cc3v(boxMin.x, boxMin.y, boxMax.z);  
    //vertices[10].location = cc3v(boxMin.x, boxMax.y, boxMax.z);
    vertices[9].location = cc3v(boxMin.x + radiansX*height, boxMax.y + radiansY*height, boxMin.z);
   
    // Top face, CCW winding:
    vertices[12].location = cc3v(boxMin.x + radiansX*height, boxMax.y + radiansY*height, boxMin.z);  
    //vertices[15].location = cc3v(boxMin.x, boxMax.y, boxMax.z); 
    //vertices[14].location = cc3v(boxMax.x, boxMax.y, boxMax.z);
    vertices[13].location = cc3v(boxMax.x + radiansX*height, boxMax.y + radiansY*height, boxMin.z);
  
    // Bottom face, CCW winding:
    //vertices[16].location = cc3v(boxMin.x, boxMin.y, boxMax.z);
    vertices[19].location = cc3v(boxMin.x + radiansX*height, boxMin.y + radiansY*height, boxMin.z);
    vertices[18].location = cc3v(boxMax.x + radiansX*height, boxMin.y + radiansY*height, boxMin.z);
    //vertices[17].location = cc3v(boxMax.x, boxMin.y, boxMax.z);

    [boxNode rebuildBoundingVolume];
    [boxNode updateVertexLocationsGLBuffer];
    [boxNode updateVertexTextureCoordinatesGLBuffer];
}
- (void)addChildToFloor:(CC3Node *)child
{
    [_floorNode addChild:_floor];
}
@end



@implementation Ball3DLayer

- (id)init
{
    if ((self = [super init])){
        Ball3DWorld *world = [Ball3DWorld world];
        self.cc3World = world;
        [world play];
        
        /*
         CGSize s = [CCDirector sharedDirector].winSize;
         self.contentSize = CGSizeMake(s.width/2, s.height/2);
         self.position = CGPointMake(s.width/4, s.height/4);
         */

        [self scheduleUpdate];
    }
    return self;
}

#pragma mark - Methods

- (void)updateBallLocation:(CGPoint)l andRotation:(CGFloat)a
{
    Ball3DWorld *w = (Ball3DWorld*)self.cc3World;
    [w setBallLocation:l];
    [w setBallRotation:a];
}

- (CGPoint)getBallLocation
{
    Ball3DWorld *w = (Ball3DWorld*)self.cc3World;
    return [w getBallLocation];
}

- (CGFloat)getBallRadius
{
    Ball3DWorld *w = (Ball3DWorld*)self.cc3World;
    return [w getBallRadius];
}

#pragma mark - Overrided Methods

- (void)initializeControls
{
    [KKInput sharedInput].deviceMotionActive = YES;
}

@end
