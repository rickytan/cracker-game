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
    CC3PlaneNode *              _floor;  // Weak assign
    CC3Node *                   _floorNode;  // Weak assign
    CC3Node *                   _arrowNode;  // Weak assign
    
    
    CC3BoxNode *                _adCube[AD_CUBE_TOTAL]; // Weak assign
    
    CGFloat                     _ballRadius;
    CGSize                      boxBound;
    CC3BoundingBox              bounds;
    float                       ratio;
}
- (void)setArrowDirection:(CGFloat)angle;
- (void)setBallLocation:(CGPoint)ballLocation;
- (void)setBallRotation:(CGFloat)ballRotation;
- (CGPoint)getBallLocation;
- (CGFloat)getBallRadius;
- (CGPoint)toBoxPoint:(CGPoint)screen;
- (CGPoint)toScreenPoint:(CGPoint)box;
- (void)addChildToFloor:(CC3Node*)child;
- (void)reset;
- (void)moveTo:(CGFloat)offset;
- (void)moveTo:(CGFloat)offset inSeconds:(ccTime)time;
- (void)setTo:(CGFloat)offset;
@end

@implementation Ball3DWorld

#pragma mark - Overrided Methods

-(void) initializeWorld
{
	// Create the camera, place it back a bit
	_cam = [CC3Camera nodeWithName: @"Camera"];
	_cam.location = cc3v(0.0, 0.0, 9.6);
    _ballRadius = 0.22f;
    
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
    
    const CGFloat cube_height = .8;
    
    bounds = CC3BoundingBoxMake(-boxBound.width/2, -boxBound.height/2, -cube_height, 
                                boxBound.width/2,  boxBound.height/2, 0.0);
    
    _floorNode = [CC3Node node];
    [self addChild:_floorNode];
    
    
    CC3Vector cube_locations[AD_CUBE_TOTAL] = {
        {              0, boxBound.height,           0},
        { boxBound.width,               0,           0},
        {              0,-boxBound.height,           0},
        {-boxBound.width,               0,           0},
        {              0,               0,-cube_height}
    };
    NSString *cube_texture[] = {
        @"wall_r.png",
        @"wall.png",
        @"wall_r.png",
        @"wall.png",
        @"bg.png"
    };
    for (int i=AD_CUBE_TOTAL -1 ; i >= 0; --i) {
        _adCube[i] = [CC3BoxNode node];
        [_adCube[i] populateAsTexturedBox:bounds withCorner:(CGPoint){1.0,1.0}];
        _adCube[i].texture = [CC3Texture textureFromFile:cube_texture[i]];
        _adCube[i].location = cube_locations[i];
        _adCube[i].specularColor = kCCC4FWhite;
        _adCube[i].ambientColor = kCCC4FWhite;
        _adCube[i].diffuseColor = kCCC4FWhite;
        
        [_floorNode addChild:_adCube[i]];
        //[_floorNode addAndLocalizeChild:_adCube[i]];
    }


    _floor = [CC3PlaneNode nodeWithName:@"floor"];
    [_floor populateAsTexturedRectangleWithSize:CGSizeMake(4, 4) 
                                       andPivot:ccp(2, 2)];
    //[_floor populateAsRectangleWithSize:CGSizeMake(2, 2) andPivot:ccp(1, 1)];
    _floor.texture = [[[CC3Texture alloc] init] autorelease];
    _floor.texture.texture = [[[CCTexture2D alloc] initWithString:@"Note: the arrow above indicate thw wind direction"
                                                       dimensions:CGSizeMake(64, 64) 
                                                        alignment:UITextAlignmentLeft
                                                         fontName:@"Marker Felt" 
                                                         fontSize:20] autorelease];
    //[self addContentFromPODResourceFile:@"wolegequ2.pod"];
    
    [_floor alignInvertedTextures];
    _floor.material.isOpaque = YES;
    _floor.material.sourceBlend = GL_SRC_ALPHA;
    _floor.material.destinationBlend = GL_ONE_MINUS_SRC_ALPHA;
    //[self addChildToFloor:_floor];
    
    CC3PlaneNode *_arrow = [CC3PlaneNode nodeWithName:@"arrow"];
    
    CC3Texture *tex = [CC3Texture textureFromFile:@"wind.png"];
    
    [_arrow populateAsTexturedRectangleWithSize:CGSizeMake(0.6, 2.4) 
                                       andPivot:ccp(0.3, 1.2)];
    _arrow.texture = tex;
    [_arrow alignInvertedTextures];
    _arrow.material.isOpaque = YES;
    _arrow.material.sourceBlend = GL_SRC_ALPHA;
    _arrow.material.destinationBlend = GL_ONE_MINUS_SRC_ALPHA;
    
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
    _ball.texture = [CC3Texture textureFromFile:@"qiu.png"];
    [_ball shouldUseLighting];
    [_ball alignInvertedTextures];
    _ball.material.isOpaque = YES;
    _ball.material.sourceBlend = GL_SRC_ALPHA;
    _ball.material.destinationBlend = GL_ONE_MINUS_SRC_ALPHA;
    
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
        _floorNode.transformMatrix = matrix;
        
        [_ball markTransformDirty];
        for (int i=0; i<AD_CUBE_TOTAL; ++i) {
            [_adCube[i] markTransformDirty];
        }
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

- (void)moveTo:(CGFloat)offset
{
    [self moveTo:offset inSeconds:0.35];
}

- (void)moveTo:(CGFloat)offset inSeconds:(ccTime)time
{
    static BOOL _first = YES;
    static CC3Vector orgiLocation;
    if (_first){
        _first = NO;
        orgiLocation = _adCube[AD_CUBE_TOP].location;
    }
    
    CC3MoveTo *move = [CC3MoveTo actionWithDuration:time moveTo:CC3VectorAdd(orgiLocation, cc3v(0, -offset/ratio, 0))];
    
    [_adCube[AD_CUBE_TOP] runAction:move];
}

- (void)setTo:(CGFloat)offset
{
    static BOOL _first = YES;
    static CC3Vector orgiLocation;
    if (_first){
        _first = NO;
        orgiLocation = _adCube[AD_CUBE_TOP].location;
    }
    CC3Vector l = orgiLocation;
    l.y -= offset/ratio;
    _adCube[AD_CUBE_TOP].location = l;
}

- (void)reset
{
    [self moveTo:0];
}

- (void)setArrowDirection:(CGFloat)angle
{
    _arrowNode.rotationAxis = cc3v(0, 0, 1);
    _arrowNode.rotationAngle = angle;
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

- (void)moveTo:(CGFloat)d
{
    Ball3DWorld *w = (Ball3DWorld*)self.cc3World;
    [w moveTo:d];
}

- (void)moveTo:(CGFloat)d inSeconds:(ccTime)time
{
    Ball3DWorld *w = (Ball3DWorld*)self.cc3World;
    [w moveTo:d inSeconds:time];
}

- (void)setTo:(CGFloat)d
{
    Ball3DWorld *w = (Ball3DWorld*)self.cc3World;
    [w setTo:d];
}

#pragma mark - Overrided Methods

- (void)initializeControls
{
    [KKInput sharedInput].deviceMotionActive = YES;
}

@end
