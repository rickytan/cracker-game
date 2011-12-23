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
#import "GameScene.h"

void ContactListener::BeginContact(b2Contact* contact)
{
    if (![CCDirector sharedDirector].currentDeviceIsSimulator)
        [GameScene sharedGame].state = kGameStateOver;
}
void ContactListener::EndContact(b2Contact *contact)
{
    
}

@interface PlayLayer (PrivateMethods)
- (void)CreateScreenBound;
- (b2Body*)CreateBallAtScreenLocation:(CGPoint)p withScreenRadius:(CGFloat)r;
- (void)control:(NSTimer*)timer;
- (void)scoreAddByTime;
- (void)scoreAddByPixel:(CGFloat)pixels;
- (void)setWindDirection:(CGFloat)angle;
- (void)speedUpWind;
- (void)moveTopFace:(CGFloat)d pushDown:(BOOL)down;
- (void)stopMoveTopFace;
- (void)pushDown;
- (void)removeAd;
- (b2Vec2)toMeters:(CGPoint)point;
- (CGPoint)toPixels:(b2Vec2)vec;
- (void)pausePressed:(id)sender;
- (void)upPressed:(id)sender;
@end

@implementation PlayLayer
@synthesize score;
@synthesize isGamePlaying = _isGamePlaying;
@synthesize isAdshown = _isAdshown;

const static float PTM_RATIO = 80.0f;

CGPoint positions[] = {
    
};

- (void)dealloc
{
#ifndef KK_ARC_ENABLED
    [super dealloc];
#endif
    delete world;
    delete contact;
    if ([timer isValid])
        [timer invalidate];
    if ([scoreAddTimer isValid])
        [scoreAddTimer invalidate];
}

- (id)init
{
    if ((self = [super init])){
        
        world = new b2World(b2Vec2(0.0f,0.0f));
        world->SetAllowSleeping(NO);
        
        contact = new ContactListener;
        world->SetContactListener(contact);
        
        if ([CCDirector sharedDirector].currentDeviceIsSimulator)
            world->SetGravity(b2Vec2(0, -1));
        
        [self CreateScreenBound];
        
        ball3DLayer = [Ball3DLayer node];
        [self addChild:ball3DLayer z:-2];
        
        CGPoint p = [ball3DLayer getBallLocation];
        CGFloat r = [ball3DLayer getBallRadius];
        theBall = [self CreateBallAtScreenLocation:p withScreenRadius:r];
        
        CCMenuItemSprite *upItem = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"up_w.png"]
                                                           selectedSprite:[CCSprite spriteWithFile:@"up.png"]
                                                                   target:self
                                                                 selector:@selector(upPressed:)];
        CCEaseIn *ease = [CCEaseIn actionWithAction:[CCMoveBy actionWithDuration:0.35 position:ccp(0, 6)] rate:2.4f];

        [upItem runAction:[CCRepeatForever actionWithAction:[CCSequence actions:ease, [ease reverse], nil]]];
        
        upmenu = [CCMenu menuWithItems:upItem, nil];
        
        [self addChild:upmenu];
        
        [self scheduleUpdate];
        [self pauseSchedulerAndActions];
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"LOW C.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"C.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"D.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"E.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"F.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"G.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"A.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"B.caf"];
        
        [KKInput sharedInput].deviceMotionActive = YES;
    }
    return self;
}

#pragma mark - Private Methods

- (void)moveTopFace:(CGFloat)d pushDown:(BOOL)down
{
    CGPoint p = [self toPixels:topBoundBody->GetPosition()];
    
    if (-d - p.y == 0.0)
        return;
    topBoundBody->SetLinearVelocity([self toMeters:ccp(0, (-d - p.y) / 0.35)]);
    
    CCCallFunc *cb = nil;
    if (!down){
        cb = [CCCallFunc actionWithTarget:self
                                 selector:@selector(stopMoveTopFace)];
    }
    else
        cb = [CCCallFunc actionWithTarget:self
                                 selector:@selector(pushDown)];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:0.35];
    [self runAction:[CCSequence actions:delay, cb, nil]];
}

- (void)stopMoveTopFace
{
    topBoundBody->SetLinearVelocity(b2Vec2(0,0));
    topBoundBody->SetTransform(b2Vec2_zero, 0);
}

- (void)pushDown
{
    topBoundBody->SetLinearVelocity(b2Vec2(0,-4 / PTM_RATIO));
}

- (void)showAd
{
    if (_isAdshown)
        return;
    _isAdshown = YES;
    upmenu.visible = YES;
    [self moveTopFace:100 pushDown:YES];
}

- (void)hideAd
{
    if (!_isAdshown)
        return;
    _isAdshown = NO;
    [self moveTopFace:0 pushDown:NO];
}

- (void)CreateScreenBound
{
    // for the screenBorder body we'll need these values
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    const CGFloat boundFriction = 0.3;
    
    float widthInMeters = screenSize.width / PTM_RATIO;
    float heightInMeters = screenSize.height / PTM_RATIO;
    b2Vec2 lowerLeftCorner = b2Vec2(0, 0);
    b2Vec2 lowerRightCorner = b2Vec2(widthInMeters, 0);
    b2Vec2 upperLeftCorner = b2Vec2(0, heightInMeters);
    b2Vec2 upperRightCorner = b2Vec2(widthInMeters, heightInMeters);
    
    b2EdgeShape screenBorderShape;
    
    
    // Define the static container body, which will provide the collisions at screen borders.
    b2BodyDef screenBorderDef;
    screenBorderDef.type = b2_staticBody;
    screenBorderDef.position.Set(0, 0);
    b2Body* screenBorderBody = world->CreateBody(&screenBorderDef);
    
    // Create fixtures for the four borders (the border shape is re-used)
    screenBorderShape.Set(lowerLeftCorner, lowerRightCorner);
    screenBorderBody->CreateFixture(&screenBorderShape, 0)->SetRestitution(boundFriction);
    
    screenBorderBody = world->CreateBody(&screenBorderDef);
    screenBorderShape.Set(lowerRightCorner, upperRightCorner);
    screenBorderBody->CreateFixture(&screenBorderShape, 0)->SetRestitution(boundFriction);
    
    screenBorderBody = world->CreateBody(&screenBorderDef);
    screenBorderShape.Set(upperLeftCorner, lowerLeftCorner);
    screenBorderBody->CreateFixture(&screenBorderShape, 0)->SetRestitution(boundFriction);
    
    screenBorderDef.type = b2_kinematicBody;
    topBoundBody = world->CreateBody(&screenBorderDef);
    screenBorderShape.Set(upperRightCorner, upperLeftCorner);
    topBoundBody->CreateFixture(&screenBorderShape,0)->SetRestitution(boundFriction);
}

- (b2Body*)CreateBallAtScreenLocation:(CGPoint)p withScreenRadius:(CGFloat)r
{
    p = ccpMult(p, 1 / PTM_RATIO);
    
    b2BodyDef body;
    body.type = b2_dynamicBody;
    body.position = b2Vec2(p.x, p.y);
    //body.userData = (void*)0x1;
    
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

- (void)scoreAddByTime
{
    self.score += 10;
}

- (void)scoreAddByPixel:(CGFloat)pixels
{
    static CGFloat total = 0.0f;
    static uint _o = 0, _n = 0;
    total += pixels;
    _n = total;
    if (_n != _o){
        self.score += _n - _o;
        _o = 0;
        total = total - _n;
    }
}

- (void)speedUpWind
{
    [wind increase];
}

- (void)setWindDirection:(CGFloat)angle
{
    [ball3DLayer setArrowDirection:CC_RADIANS_TO_DEGREES(angle)];
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

- (void)setScore:(uint)_score
{
    score = _score;
    scoreLabel.string = [NSNumber numberWithInt:score].stringValue;
}

- (void)startGame
{
    CGSize s = [CCDirector sharedDirector].winSize;
    CGPoint c = [CCDirector sharedDirector].screenCenter;
    score = 0;
    
    if (!scoreLabel){
        scoreLabel = [CCLabelBMFont labelWithString:@"        0" fntFile:@"bitmapFontTest.fnt"];
        
        scoreLabel.position = ccp(s.width - scoreLabel.contentSize.width / 2 - 10,
                                  scoreLabel.contentSize.height/2 + 4);
        
        [self addChild:scoreLabel];
    }
    scoreLabel.string = [NSString stringWithFormat:@"%d",score];
    
    theBall->SetTransform([self toMeters:c], 0);
    theBall->SetLinearVelocity(b2Vec2(0,0));
    theBall->SetAngularVelocity(0);
    
    [wind removeFromParentAndCleanup:YES];
    
    wind = [[Wind alloc] initWithForce:0.02
                              andAngle:CCRANDOM_MINUS1_1()*M_PI
                                repeat:YES];
    [wind blow:theBall];
    [self addChild:wind];
    [wind release];
    
    wind.force = 0.02;
    [wind startBlow];
    [self setWindDirection:wind.angle];
    
    if (!pausemenu){
        CCMenuItemSprite *pauseItem = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"pause.png"]
                                                              selectedSprite:[CCSprite spriteWithFile:@"pause.png"]
                                                                      target:self
                                                                    selector:@selector(pausePressed:)];
        pauseItem.position = ccp(-130, -210);
        pauseItem.scale = 0.6;
        
        pausemenu = [CCMenu menuWithItems:pauseItem, nil];
        [self addChild:pausemenu];
    }
    
    if (!motionStreak){
        motionStreak = [CCMotionStreak streakWithFade:1.0
                                               minSeg:0.0
                                                image:@"streak.png"
                                                width:20.0 
                                               length:40.0
                                                color:ccc4(0x0, 0x80, 0xff, 0xc0)];
        [self addChild:motionStreak];
    }
    
    CCDelayTime *delay = [CCDelayTime actionWithDuration:1.0];
    CCCallFunc *cb = [CCCallFunc actionWithTarget:self selector:@selector(scoreAddByTime)];
    CCRepeatForever *repeat = [CCRepeatForever actionWithAction:[CCSequence actions:delay, cb, nil]];
    [self runAction:repeat];
    
    [self resumeGame];
}

- (void)endGame
{
    _isGamePlaying = NO;
    
    [wind stopBlow];
    [self pauseSchedulerAndActions];
    pausemenu.visible = NO;
}

- (void)pauseGame
{
    _isGamePlaying = NO;
    //[ball3DLayer pauseSchedulerAndActions];
    [wind stopBlow];
    [self pauseSchedulerAndActions];
    pausemenu.visible = NO;
    
}

- (void)resumeGame
{
    _isGamePlaying = YES;
    //[ball3DLayer resumeSchedulerAndActions];
    [wind startBlow];
    [self resumeSchedulerAndActions];
    
    [pausemenu runAction:[CCSequence actions:
                          [CCShow action], 
                          [CCFadeIn actionWithDuration:0.4], nil]];
    
}

#pragma mark - Overrided Methods

- (void)update:(ccTime)delta
{
	CCDirector* director = [CCDirector sharedDirector];
    CGPoint center = director.screenCenter;
    
    
    KKInput* input = [KKInput sharedInput];
    if (director.currentDeviceIsSimulator == NO)
    {
        KKAcceleration* acceleration = input.deviceMotion.gravity;
        b2Vec2 gravity = 10.0f * b2Vec2(acceleration.smoothedX, acceleration.smoothedY);
        world->SetGravity(gravity);
    }
    
    static NSString *soundTable[] = {@"C.caf",@"D.caf",@"E.caf",@"F.caf",@"G.caf",@"A.caf",@"B.caf"};
    const static int soundCount = sizeof(soundTable) / sizeof(NSString*);
    static int lastSound = 0;
    
    CGPoint lastPosition = [self toPixels:theBall->GetPosition()];
    
	// The number of iterations influence the accuracy of the physics simulation. With higher values the
	// body's velocity and position are more accurately tracked but at the cost of speed.
	// Usually for games only 1 position iteration is necessary to achieve good results.
    int32 velocityIterations = 2;
    int32 positionIterations = 1;
    world->Step(delta, velocityIterations, positionIterations);
    
    if (self.isGamePlaying){
        CGPoint p = [self toPixels:theBall->GetPosition()];
        CGFloat a = theBall->GetAngle();
        
        [self scoreAddByPixel:ccpDistance(lastPosition, p)];
        [ball3DLayer setArrowDirection:CC_RADIANS_TO_DEGREES(wind.angle)];
        [ball3DLayer updateBallLocation:p andRotation:CC_RADIANS_TO_DEGREES(a)];
        
        motionStreak.position = p;
        int currentSound = MAX(fabsf(p.x - center.x) * soundCount / center.x, 
                               fabsf(p.y - center.y) * soundCount / center.y);
        if (currentSound != lastSound){
            lastSound = currentSound;
            [[SimpleAudioEngine sharedEngine] playEffect:soundTable[lastSound]];
        }
        
        CGPoint ptmp = [self toPixels:topBoundBody->GetPosition()];
        [ball3DLayer setTo:-ptmp.y];
        upmenu.position = ccpAdd(ptmp, ccp(center.x, center.y * 2 + 20));
        
        
    }
    else {
        ((GameScene*)self.parent).state = kGameStateOver;
        [[SimpleAudioEngine sharedEngine] playEffect:@"LOW C.caf"];
    }
}

- (void)onEnter
{
    [super onEnter];
    [self pauseSchedulerAndActions];
}

- (void)pausePressed:(id)sender
{
    GameScene *game = (GameScene*)self.parent;
    game.state = kGameStatePausing;
}

- (void)upPressed:(id)sender
{
    
    CGPoint p = [self toPixels:topBoundBody->GetPosition()];
    p.y += 16;
    topBoundBody->SetTransform([self toMeters:p], 0);
    
}

@end
