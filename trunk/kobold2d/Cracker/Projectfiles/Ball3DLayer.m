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
    
    CGFloat                     _ballRadius;
    CGSize                      boxBound;
}

- (void)setBallLocation:(CGPoint)ballLocation;
- (void)setBallRotation:(CGFloat)ballRotation;
- (CGPoint)getBallLocation;
- (CGFloat)getBallRadius;
- (CGPoint)toBoxPoint:(CGPoint)screen;
- (CGPoint)toScreenPoint:(CGPoint)box;
- (CC3BoxNode*)createScreenBox:(CC3BoundingBox)bounds;
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
	lamp.location = cc3v(-4.0, 1.0, 10.0);
	lamp.isDirectionalOnly = YES;
    lamp.color = ccc3(0xff, 0xff, 0xff);
    lamp.specularColor = kCCC4FWhite;
    lamp.ambientColor = kCCC4FLightGray;
    lamp.diffuseColor = kCCC4FWhite;
	[self addChild:lamp];
    
    const CGFloat ratio = 60;
    CGSize s = [CCDirector sharedDirector].winSize;
    boxBound.width = s.width / ratio;
    boxBound.height = s.height / ratio;
    
    CC3BoundingBox bounds = CC3BoundingBoxMake(-boxBound.width/2, -boxBound.height/2, -1, 
                                               boxBound.width/2,  boxBound.height/2, 0);
    
    _box = [CC3BoxNode nodeWithName:@"Box"];
    //[_box populateAsSolidBox:bounds];
    [_box populateAsTexturedBox:bounds withCorner:(CGPoint){1,1}];
    
    _box = [self createScreenBox:bounds];
    
    _box.specularColor = kCCC4FWhite;
    _box.diffuseColor = kCCC4FLightGray;
    _box.ambientColor = kCCC4FDarkGray;
    _box.texture = [CC3Texture textureFromFile:@"wood2.jpg"];
    
    /*
     [_box setVertexTexCoord2F:(ccTex2F){0,0} at:0];
     [_box setVertexTexCoord2F:(ccTex2F){0,1} at:2];
     [_box setVertexTexCoord2F:(ccTex2F){1,0} at:4];
     [_box setVertexTexCoord2F:(ccTex2F){1,1} at:6];
     [_box updateVertexTextureCoordinatesGLBuffer];
     */
    [self addChild:_box];
    
    
    CC3PlaneNode *floor = [CC3PlaneNode nodeWithName:@"floor"];
    [floor populateAsTexturedRectangleWithSize:boxBound
                                      andPivot:ccp(boxBound.width/2 , boxBound.height/2)];
    floor.texture = [CC3Texture textureFromFile:@"wood2.jpg"];
    floor.location = cc3v(0, 0, -1);
    //[_box addChild:floor];
    
    _ball = [CC3PlaneNode nodeWithName:@"Ball"];
    [_ball populateAsTexturedRectangleWithSize:CGSizeMake(2*_ballRadius, 2*_ballRadius) 
                                      andPivot:ccp(_ballRadius, _ballRadius)];
    _ball.texture = [CC3Texture textureFromFile:@"ball.png"];
    [_ball shouldUseLighting];
    [_ball alignInvertedTextures];
    _ball.material.isOpaque = YES;
    _ball.material.sourceBlend = GL_SRC_ALPHA;
    _ball.material.destinationBlend = GL_ONE_MINUS_SRC_ALPHA;
    _ball.shouldCullBackFaces = NO;
    
    [_ball retainVertexLocations];
    
    [_box addChild:_ball];
    
	
	// Create OpenGL ES buffers for the vertex arrays to keep things fast and efficient,
	// and to save memory, release the vertex data in main memory because it is now redundant.
	[self createGLBuffers];
    //	[self releaseRedundantData];
}

-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {}

-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {}

-(void) updateWorld:(ccTime)dt
{
    [super updateWorld:dt];
    
    CCDirector* director = [CCDirector sharedDirector];
    
    KKInput* input = [KKInput sharedInput];
    if (director.currentDeviceIsSimulator == NO)
    {
        KKDeviceMotion* m = input.deviceMotion;
        float xd = CC_RADIANS_TO_DEGREES(m.pitch) ;
        float yd = CC_RADIANS_TO_DEGREES(m.roll) ;
        
        const float tmax = 90;
        xd = xd<tmax?(xd>-tmax?xd:-tmax):tmax;
        yd = yd<tmax?(yd>-tmax?yd:-tmax):tmax;
        
        _box.rotation = cc3v(-xd, -yd,0.0);
        
        /*
        [_box setVertexLocation:cc3v(-boxBound.width/2 - yd, -boxBound.height/2 + xd, -1) at:0];
        [_box setVertexLocation:cc3v(-boxBound.width/2 - yd,  boxBound.height/2 + xd, -1) at:2];
        [_box setVertexLocation:cc3v( boxBound.width/2 - yd, -boxBound.height/2 + xd, -1) at:4];
        [_box setVertexLocation:cc3v( boxBound.width/2 - yd,  boxBound.height/2 + xd, -1) at:6];
        [_box rebuildBoundingVolume];
        [_box updateVertexLocationsGLBuffer];
        [_box updateVertexTextureCoordinatesGLBuffer];
         */
        //CC3GLMatrix *matrix = _box.transformMatrix;
        
        
        /*
         CC3PlaneNode *floor = [_box getNodeNamed:@"floor"];
         [floor setVertexLocation:cc3v(-boxBound.width/2 + m.roll*2, -boxBound.height/2 + m.pitch*2, 0) at:0];
         [floor setVertexLocation:cc3v(-boxBound.width/2 + m.roll*2,  boxBound.height/2 + m.pitch*2, 0) at:1];
         [floor setVertexLocation:cc3v( boxBound.width/2 + m.roll*2, -boxBound.height/2 + m.pitch*2, 0) at:2];
         [floor setVertexLocation:cc3v( boxBound.width/2 + m.roll*2,  boxBound.height/2 + m.pitch*2, 0) at:3];
         [floor rebuildBoundingVolume];
         [floor updateVertexLocationsGLBuffer];
         [floor updateVertexTextureCoordinatesGLBuffer];
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
    _ball.location = cc3v(p.x, p.y, 0);
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
    vertices[0].normal = kCC3VectorUnitXPositive;
    vertices[0].texCoord = (ccTex2F){0.5f, corner.y};
    
    vertices[1].location = cc3v(boxMax.x, boxMin.y, boxMin.z);
    vertices[1].normal = kCC3VectorUnitXPositive;
    vertices[1].texCoord = (ccTex2F){(0.5f + corner.x), corner.y};
    
    vertices[2].location = cc3v(boxMax.x, boxMax.y, boxMin.z);
    vertices[2].normal = kCC3VectorUnitXPositive;
    vertices[2].texCoord = (ccTex2F){(0.5f + corner.x), (1.0f - corner.y)};
    
    vertices[3].location = cc3v(boxMax.x, boxMax.y, boxMax.z);
    vertices[3].normal = kCC3VectorUnitXPositive;
    vertices[3].texCoord = (ccTex2F){0.5f, (1.0f - corner.y)};
    
    // Back face, CCW winding:
    vertices[4].location = cc3v(boxMax.x, boxMin.y, boxMin.z);
    vertices[4].normal = kCC3VectorUnitZPositive;
    vertices[4].texCoord = (ccTex2F){(0.5f + corner.x), corner.y};
    
    vertices[5].location = cc3v(boxMin.x, boxMin.y, boxMin.z);
    vertices[5].normal = kCC3VectorUnitZPositive;
    vertices[5].texCoord = (ccTex2F){1.0f, corner.y};
    
    vertices[6].location = cc3v(boxMin.x, boxMax.y, boxMin.z);
    vertices[6].normal = kCC3VectorUnitZPositive;
    vertices[6].texCoord = (ccTex2F){1.0f, (1.0f - corner.y)};
    
    vertices[7].location = cc3v(boxMax.x, boxMax.y, boxMin.z);
    vertices[7].normal = kCC3VectorUnitZPositive;
    vertices[7].texCoord = (ccTex2F){(0.5f + corner.x), (1.0f - corner.y)};
    
    // Left face, CCW winding:
    vertices[8].location = cc3v(boxMin.x, boxMin.y, boxMin.z);
    vertices[8].normal = kCC3VectorUnitXNegative;
    vertices[8].texCoord = (ccTex2F){0.0f, corner.y};
    
    vertices[9].location = cc3v(boxMin.x, boxMin.y, boxMax.z);
    vertices[9].normal = kCC3VectorUnitXNegative;
    vertices[9].texCoord = (ccTex2F){corner.x, corner.y};
    
    vertices[10].location = cc3v(boxMin.x, boxMax.y, boxMax.z);
    vertices[10].normal = kCC3VectorUnitXNegative;
    vertices[10].texCoord = (ccTex2F){corner.x, (1.0f - corner.y)};
    
    vertices[11].location = cc3v(boxMin.x, boxMax.y, boxMin.z);
    vertices[11].normal = kCC3VectorUnitXNegative;
    vertices[11].texCoord = (ccTex2F){0.0f, (1.0f - corner.y)};
    
    // Top face, CCW winding:
    vertices[12].location = cc3v(boxMin.x, boxMax.y, boxMin.z);
    vertices[12].normal = kCC3VectorUnitYPositive;
    vertices[12].texCoord = (ccTex2F){corner.x, 1.0f};
    
    vertices[13].location = cc3v(boxMin.x, boxMax.y, boxMax.z);
    vertices[13].normal = kCC3VectorUnitYPositive;
    vertices[13].texCoord = (ccTex2F){corner.x, (1.0f - corner.y)};
    
    vertices[14].location = cc3v(boxMax.x, boxMax.y, boxMax.z);
    vertices[14].normal = kCC3VectorUnitYPositive;
    vertices[14].texCoord = (ccTex2F){0.5f, (1.0f - corner.y)};
    
    vertices[15].location = cc3v(boxMax.x, boxMax.y, boxMin.z);
    vertices[15].normal = kCC3VectorUnitYPositive;
    vertices[15].texCoord = (ccTex2F){0.5f, 1.0f};
    
    // Bottom face, CCW winding:
    vertices[16].location = cc3v(boxMin.x, boxMin.y, boxMax.z);
    vertices[16].normal = kCC3VectorUnitYNegative;
    vertices[16].texCoord = (ccTex2F){corner.x, corner.y};
    
    vertices[17].location = cc3v(boxMin.x, boxMin.y, boxMin.z);
    vertices[17].normal = kCC3VectorUnitYNegative;
    vertices[17].texCoord = (ccTex2F){corner.x, 0.0f};
    
    vertices[18].location = cc3v(boxMax.x, boxMin.y, boxMin.z);
    vertices[18].normal = kCC3VectorUnitYNegative;
    vertices[18].texCoord = (ccTex2F){0.5f, 0.0f};
    
    vertices[19].location = cc3v(boxMax.x, boxMin.y, boxMax.z);
    vertices[19].normal = kCC3VectorUnitYNegative;
    vertices[19].texCoord = (ccTex2F){0.5f, corner.y};
    
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
