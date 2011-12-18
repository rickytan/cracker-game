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


#define iAd_Height      60.0f

typedef enum {
        AD_CUBE_TOP = 0,
        AD_CUBE_RIGHT,
        AD_CUBE_BOTTOM,
        AD_CUBE_LEFT,
        AD_CUBE_BACK,
        AD_CUBE_TOTAL
}AdCubeFace;

@interface Ball3DWorld : CC3World {
    CC3Camera *                 _cam;    // Weak assign
    CC3PlaneNode *              _ball;   // Weak assign
    CC3BoxNode *                _box;    // Weak assign
    CC3PlaneNode *              _floor;  // Weak assign
    CC3Node *                   _floorNode;  // Weak assign
    CC3Node *                   _arrowNode;  // Weak assign
    
    
    CC3BoxNode *                _adCube[AD_CUBE_TOTAL]; // Weak assign
    
    CGFloat                     _ballRadius;
    CGSize                      boxBound;
    CC3BoundingBox              bounds;
    float                       ratio;
    CGFloat                     topFaceOffset;
}
- (void)setArrowDirection:(CGFloat)angle;
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
- (void)shrink;
- (void)grow;
- (void)moveTopFace:(NSTimer*)timer;
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
    
    ratio = 60;
    CGSize s = [CCDirector sharedDirector].winSize;
    boxBound.width = s.width / ratio;
    boxBound.height = s.height / ratio;
    
    const CGFloat cube_height = 2.5;
    
    bounds = CC3BoundingBoxMake(-boxBound.width/2, -boxBound.height/2, -cube_height, 
                                boxBound.width/2,  boxBound.height/2, 0.0);
    
    _floorNode = [CC3Node node];
    [self addChild:_floorNode];
    
    
    CC3Vector cube_locations[AD_CUBE_TOTAL] = {
        {                0, boxBound.height/2,           0},
        { boxBound.width/2,                 0,           0},
        {                0,-boxBound.height/2,           0},
        {-boxBound.width/2,                 0,           0},
        {                0,                 0,-cube_height}
    };
    NSString *cube_texture[] = {
        @"wood2.jpg",
        @"wood2.jpg",
        @"wood2.jpg",
        @"wood2.jpg",
        @"wood2.jpg"
    };
    for (int i=0; i<AD_CUBE_TOTAL; ++i) {
        _adCube[i] = [CC3BoxNode node];
        [_adCube[i] populateAsTexturedBox:bounds withCorner:(CGPoint){1.0,1.0}];
        _adCube[i].shouldUseLighting = YES;
        _adCube[i].shouldCullBackFaces = NO;
        _adCube[i].texture = [CC3Texture textureFromFile:cube_texture[i]];
        _adCube[i].location = cube_locations[i];
        _adCube[i].specularColor = kCCC4FWhite;
        _adCube[i].ambientColor = kCCC4FWhite;
        _adCube[i].diffuseColor = kCCC4FWhite;
        
        [_floorNode addChild:_adCube[i]];
    }

    
    _floor = [CC3PlaneNode nodeWithName:@"floor"];
    [_floor populateAsTexturedRectangleWithSize:CGSizeMake(4, 4) 
                                       andPivot:ccp(2, 2)];
    //[_floor populateAsRectangleWithSize:CGSizeMake(2, 2) andPivot:ccp(1, 1)];
    _floor.texture = [[[CC3Texture alloc] init] autorelease];
    _floor.texture.texture = [[[CCTexture2D alloc] initWithString:@"Note: the arrow above indicate thw wind direction"
                                                       dimensions:CGSizeMake(48, 48) 
                                                        alignment:UITextAlignmentLeft
                                                         fontName:@"Marker Felt" 
                                                         fontSize:20] autorelease];
    //[self addContentFromPODResourceFile:@"wolegequ2.pod"];
    
    [_floor shouldUseLighting];
    [_floor alignInvertedTextures];
    _floor.material.isOpaque = YES;
    _floor.material.sourceBlend = GL_SRC_ALPHA;
    _floor.material.destinationBlend = GL_ONE_MINUS_SRC_ALPHA;
    _floor.shouldCullBackFaces = NO;
    [self addChildToFloor:_floor];
    
    CC3PlaneNode *_arrow = [CC3PlaneNode nodeWithName:@"arrow"];
    CC3Texture *tex = [CC3Texture textureFromFile:@"blackArrow.png"];
    
    [_arrow populateAsTexturedRectangleWithSize:CGSizeMake(0.6, 2.4) 
                                       andPivot:ccp(0.3, 1.2)];
    _arrow.texture = tex;
    [_arrow alignInvertedTextures];
    _arrow.material.isOpaque = YES;
    _arrow.material.sourceBlend = GL_SRC_ALPHA;
    _arrow.material.destinationBlend = GL_ONE_MINUS_SRC_ALPHA;
    _arrow.shouldCullBackFaces = NO;
    
    CC3MoveBy *move0 = [CC3MoveBy actionWithDuration:0.5 moveBy:cc3v( 0.35, 0, 0)];
    CC3MoveBy *move1 = [CC3MoveBy actionWithDuration:0.5 moveBy:cc3v(-0.35, 0, 0)];
    CCSequence *seq = [CCSequence actions:[CCEaseIn actionWithAction:move0 rate:1.8], [CCEaseOut actionWithAction:move1 rate:1.2], nil];
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:seq];
    [_arrow runAction:repeat];
    _arrow.rotationAxis = cc3v(0, 0, 1);
    _arrow.rotationAngle = 90;
    
    _arrowNode = [CC3Node nodeWithName:@"arrownode"];
    _arrowNode.location = cc3v(0.0, 1.8, 0.0);
    [_arrowNode addChild:_arrow];
    
    [self addChildToFloor:_arrowNode];
    
    
    
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
    [_floorNode addChild:_ball];
    
	
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
        
        const float tmaxx = M_PI / 180 * 8;
        const float tmaxy = M_PI / 180 * 12;
        //xd = xd<tmaxx?(xd>-tmaxx?xd:-tmaxx):tmaxx;
        //yd = yd<tmaxy?(yd>-tmaxy?yd:-tmaxy):tmaxy;
        
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
        //_floorNode.transformMatrix = matrix;
        //[_floorNode markTransformDirty];
        _floorNode.rotation = cc3v(CC_RADIANS_TO_DEGREES(-yd), CC_RADIANS_TO_DEGREES(xd), 0);
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

- (void)shrink
{
    topFaceOffset = -iAd_Height / ratio;
    CC3MoveBy *move = [CC3MoveBy actionWithDuration:0.35 moveBy:cc3v(0, topFaceOffset, 0)];
    
    [_adCube[AD_CUBE_TOP] runAction:move];
}
- (void)moveTopFace:(NSTimer *)timer
{
    const CGFloat rate = 0.4;

    if (fabsf(topFaceOffset) <= 1e-3)
        return;
    
    CC3TexturedVertex *vertices = ((CC3VertexArrayMesh*)_box.mesh).vertexTextureCoordinates.elements;
    
    // Only move donw the top face!!!
    vertices[12].location = CC3VectorAdd(vertices[12].location, cc3v(0, topFaceOffset * rate , 0));
    vertices[15].location = CC3VectorAdd(vertices[15].location, cc3v(0, topFaceOffset * rate , 0));
    vertices[14].location = CC3VectorAdd(vertices[14].location, cc3v(0, topFaceOffset * rate , 0));
    vertices[13].location = CC3VectorAdd(vertices[13].location, cc3v(0, topFaceOffset * rate , 0));
    [_box rebuildBoundingVolume];
    [_box updateVertexLocationsGLBuffer];
    [_box updateVertexTextureCoordinatesGLBuffer];
    
    topFaceOffset *= (1.0-rate);
    
    [NSTimer scheduledTimerWithTimeInterval:1.0/30.0
                                     target:self
                                   selector:@selector(moveTopFace:)
                                   userInfo:nil
                                    repeats:NO];
}
- (void)grow
{
    topFaceOffset = iAd_Height / ratio;
    CC3MoveBy *move = [CC3MoveBy actionWithDuration:0.35 moveBy:cc3v(0, topFaceOffset, 0)];
    
    [_adCube[AD_CUBE_TOP] runAction:move];
    return;
    
    CC3TexturedVertex *vertices = ((CC3VertexArrayMesh*)_box.mesh).vertexTextureCoordinates.elements;
    CC3Vector boxMin = bounds.minimum;
    CC3Vector boxMax = bounds.maximum;
    
    // Only move donw the top face!!!
    vertices[12].location = cc3v(boxMin.x, boxMax.y, boxMin.z);
    vertices[15].location = cc3v(boxMin.x, boxMax.y, boxMax.z);
    vertices[14].location = cc3v(boxMax.x, boxMax.y, boxMax.z); 
    vertices[13].location = cc3v(boxMax.x, boxMax.y, boxMin.z);
    [_box rebuildBoundingVolume];
    [_box updateVertexLocationsGLBuffer];
    [_box updateVertexTextureCoordinatesGLBuffer];
}

- (void)setArrowDirection:(CGFloat)angle
{
    _arrowNode.rotationAxis = cc3v(0, 0, 1);
    _arrowNode.rotationAngle = angle;
}
- (void)updateBox:(CC3BoundingBox)box animated:(BOOL)animated
{

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
    CC3VertexLocations* locArray = [CC3VertexLocations vertexArray];
    locArray.elementStride = sizeof(CC3TexturedVertex);	// Set stride before allocating elements.
    locArray.elementOffset = 0;							// Offset to location element in vertex structure
    vertices = [locArray allocateElements: vertexCount];
    
    // Create the normal array interleaved on the same element array
    CC3VertexNormals* normArray = [CC3VertexNormals vertexArray];
    normArray.elements = vertices;
    normArray.elementStride = locArray.elementStride;	// Interleaved...so same stride
    normArray.elementCount = vertexCount;
    normArray.elementOffset = sizeof(CC3Vector);		// Offset to normal element in vertex structure
    
    // Create the tex coord array interleaved on the same element array as the vertex locations
    CC3VertexTextureCoordinates* tcArray = nil;
    tcArray = [CC3VertexTextureCoordinates vertexArray];
    tcArray.elements = vertices;
    tcArray.elementStride = locArray.elementStride;		// Interleaved...so same stride
    tcArray.elementCount = vertexCount;
    tcArray.elementOffset = 2 * sizeof(CC3Vector);		// Offset to texCoord element in vertex structure
    
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
    [_adCube[AD_CUBE_BACK] addChild:child];
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

- (void)setArrowDirection:(CGFloat)angle
{
    Ball3DWorld *w = (Ball3DWorld*)self.cc3World;
    [w setArrowDirection:angle];
}

- (void)showAd
{
    Ball3DWorld *w = (Ball3DWorld*)self.cc3World;
    [w shrink];
}
- (void)hideAd
{
    Ball3DWorld *w = (Ball3DWorld*)self.cc3World;
    [w grow];
}
#pragma mark - Overrided Methods

- (void)initializeControls
{
    [KKInput sharedInput].deviceMotionActive = YES;
}

@end