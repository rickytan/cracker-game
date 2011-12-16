//
//  PlayLayer.m
//  Cracker
//
//  Created by  on 11-12-6.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "PlayLayer.h"
#import "Ball3DLayer.h"
#import "Hello3DLayer.h"
#import "Hello3DWorld.h"
#import "SimpleAudioEngine.h"



@interface PlayLayer (PrivateMethods)
- (void)CreateScreenBound;
- (b2Body*)CreateBallAtScreenLocation:(CGPoint)p withScreenRadius:(CGFloat)r;
- (void)Ad:(NSTimer*)timer;
@end

@implementation PlayLayer

const float PTM_RATIO = 96.0f;

- (void)dealloc
{
#ifndef KK_ARC_ENABLED
    [super dealloc];
#endif
    delete world;
    delete contact;
    [wind release];
}

- (id)init
{
    if ((self = [super init])){
        
        world = new b2World(b2Vec2(0.0f,0.0f));
        world->SetAllowSleeping(NO);
        
        contact = new ContactListener;
        world->SetContactListener(contact);
        
        
        ball3DLayer = [Ball3DLayer node];
        [self addChild:ball3DLayer];
        
        
        [self CreateScreenBound];
        CGPoint p = [ball3DLayer getBallLocation];
        CGFloat r = [ball3DLayer getBallRadius];
        theBall = [self CreateBallAtScreenLocation:p withScreenRadius:r];
        wind = [[Wind alloc] initWithForce:0.1
                                  andAngle:0
                                    repeat:YES];
        [wind blow:theBall];
        [wind startBlow];
        
        [self scheduleUpdate];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0f
                                         target:self
                                       selector:@selector(Ad:)
                                       userInfo:nil 
                                        repeats:YES];
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"Pow.caf"];
        
        [KKInput sharedInput].deviceMotionActive = YES;
    }
    return self;
}

#pragma mark - Private Methods
- (void)Ad:(NSTimer *)timer
{
    static BOOL shown = NO;
    if (shown)
        [ball3DLayer hideAd];
    else
        [ball3DLayer showAd];
    shown = !shown;
}
- (void)CreateScreenBound
{
    // for the screenBorder body we'll need these values
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    const CGFloat boundFriction = 0.8;
    
    float widthInMeters = screenSize.width / PTM_RATIO;
    float heightInMeters = screenSize.height / PTM_RATIO;
    b2Vec2 lowerLeftCorner = b2Vec2(0, 0);
    b2Vec2 lowerRightCorner = b2Vec2(widthInMeters, 0);
    b2Vec2 upperLeftCorner = b2Vec2(0, heightInMeters);
    b2Vec2 upperRightCorner = b2Vec2(widthInMeters, heightInMeters);
    
    // Define the static container body, which will provide the collisions at screen borders.
    b2BodyDef screenBorderDef;
    screenBorderDef.position.Set(0, 0);
    b2Body* screenBorderBody = world->CreateBody(&screenBorderDef);
    b2EdgeShape screenBorderShape;
    
    // Create fixtures for the four borders (the border shape is re-used)
    screenBorderShape.Set(lowerLeftCorner, lowerRightCorner);
    screenBorderBody->CreateFixture(&screenBorderShape, 0)->SetRestitution(boundFriction);
    screenBorderShape.Set(lowerRightCorner, upperRightCorner);
    screenBorderBody->CreateFixture(&screenBorderShape, 0)->SetRestitution(boundFriction);
    screenBorderShape.Set(upperRightCorner, upperLeftCorner);
    screenBorderBody->CreateFixture(&screenBorderShape, 0)->SetRestitution(boundFriction);
    screenBorderShape.Set(upperLeftCorner, lowerLeftCorner);
    screenBorderBody->CreateFixture(&screenBorderShape, 0)->SetRestitution(boundFriction);
}

- (b2Body*)CreateBallAtScreenLocation:(CGPoint)p withScreenRadius:(CGFloat)r
{
    p = ccpMult(p, 1 / PTM_RATIO);
    
    b2BodyDef body;
    body.type = b2_dynamicBody;
    body.position = b2Vec2(p.x, p.y);
    body.userData = (void*)0x1;
    
    b2Body *ball = world->CreateBody(&body);
    b2CircleShape circle;
    circle.m_radius = r / PTM_RATIO;
    
    b2FixtureDef fix;
    fix.shape = &circle;
    fix.friction = 0.5;
    fix.restitution = 0.8;
    fix.density = 0.3;
    
    ball->CreateFixture(&fix);
    return ball;
}

// convenience method to convert a CGPoint to a b2Vec2
-(b2Vec2) toMeters:(CGPoint)point
{
	return b2Vec2(point.x / PTM_RATIO, point.y / PTM_RATIO);
}

// convenience method to convert a b2Vec2 to a CGPoint
-(CGPoint) toPixels:(b2Vec2)vec
{
	return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}

#pragma mark - Overrided Methods

- (void)update:(ccTime)delta
{
	CCDirector* director = [CCDirector sharedDirector];
    
    KKInput* input = [KKInput sharedInput];
    if (director.currentDeviceIsSimulator == NO)
    {
        KKAcceleration* acceleration = input.deviceMotion.gravity;
        b2Vec2 gravity = 10.0f * b2Vec2(acceleration.smoothedX, acceleration.smoothedY);
        world->SetGravity(gravity);
    }
    
	// The number of iterations influence the accuracy of the physics simulation. With higher values the
	// body's velocity and position are more accurately tracked but at the cost of speed.
	// Usually for games only 1 position iteration is necessary to achieve good results.
    
    int32 velocityIterations = 2;
    int32 positionIterations = 1;
    world->Step(delta, velocityIterations, positionIterations);
    
    
    CGPoint p = [self toPixels:theBall->GetPosition()];
    CGFloat a = theBall->GetAngle();
    
    [ball3DLayer updateBallLocation:p andRotation:CC_RADIANS_TO_DEGREES(a)];
    
    /*
    // for each body, get its assigned sprite and update the sprite's position
    for (b2Body* body = world->GetBodyList(); body != nil; body = body->GetNext())
    {
        if (body->GetUserData()){
            CGPoint p = [self toPixels:body->GetPosition()];
            CGFloat a = body->GetAngle();
            
            [ball3DLayer updateBallLocation:p andRotation:CC_RADIANS_TO_DEGREES(a)];
        }
    }
     */
}

@end
