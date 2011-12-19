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
- (void)control:(NSTimer*)timer;
- (void)scoreAddByTime;
- (void)scoreAddByPixel:(CGFloat)pixels;
- (void)setWindDirection:(CGFloat)angle;
- (void)speedUpWind;
- (void)moveDownTopFace;
- (void)moveUpTopFace;
- (void)stopMoveTopFace;
- (void)removeAd;
- (b2Vec2)toMeters:(CGPoint)point;
- (CGPoint)toPixels:(b2Vec2)vec;

@end

@implementation PlayLayer
@synthesize score;
@synthesize isGamePlaying = _isGamePlaying;

const float PTM_RATIO = 64.0f;

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
        CGSize s = [CCDirector sharedDirector].winSize;
        CGPoint c = [CCDirector sharedDirector].screenCenter;
        
        world = new b2World(b2Vec2(0.0f,0.0f));
        world->SetAllowSleeping(NO);
        
        contact = new ContactListener;
        world->SetContactListener(contact);
        
        ball3DLayer = [Ball3DLayer node];
        [self addChild:ball3DLayer z:-1];
        
        menulayer = [MainMenu node];
        menulayer.delegate = self;
        [self addChild:menulayer z:0];
        
        score = 0;
        scoreLabel = [CCLabelBMFont labelWithString:@"        0" fntFile:@"bitmapFontTest.fnt"];
        
        scoreLabel.position = ccp(4 + scoreLabel.contentSize.width / 2,
                                  s.height - scoreLabel.contentSize.height/2);
        
        scoreLabel.color = ccBLUE;
        [self addChild:scoreLabel z:1];
        
        CCMenuItemSprite *pauseItem = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"back.png"]
                                                              selectedSprite:[CCSprite spriteWithFile:@"back.png"]
                                                                      target:self
                                                                    selector:@selector(pausePressed:)];
        pauseItem.position = ccpSub(c,ccp(26, 26));
        pauseItem.scale = 0.3;
        //pauseItem.contentSize = CGSizeMake(30,30);
        pausemenu = [CCMenu menuWithItems:pauseItem, nil];
        
        [self addChild:pausemenu];
        
        [self CreateScreenBound];
        CGPoint p = [ball3DLayer getBallLocation];
        CGFloat r = [ball3DLayer getBallRadius];
        theBall = [self CreateBallAtScreenLocation:p withScreenRadius:r];
        wind = [[Wind alloc] initWithForce:0.04
                                  andAngle:0
                                    repeat:YES];
        [wind blow:theBall];
        [self addChild:wind];
        [wind release];
        
        [self setWindDirection:0];
        
        [self scheduleUpdate];
        
        //[self runAction:[CCRepeatForever actionWithAction:[CCSequence actions:delay0, sad, delay1, had, nil]]];
        
        CCDelayTime *delay = [CCDelayTime actionWithDuration:1.0];
        CCCallFunc *cb = [CCCallFunc actionWithTarget:self selector:@selector(scoreAddByTime)];
        CCRepeatForever *repeat = [CCRepeatForever actionWithAction:[CCSequence actions:delay, cb, nil]];
        [self runAction:repeat];
        
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
- (void)control:(NSTimer *)timer
{
    static int counter = 0;
    counter++;
    
    if (counter % 2){
        if (isAdShown)
            [self hideAd];
        else
            [self showAd];
    }
}
- (void)moveDownTopFace
{
    topBoundBody->SetLinearVelocity([self toMeters:ccp(0, -50 / 0.35)]);
    CCCallFunc *cb = [CCCallFunc actionWithTarget:self
                                         selector:@selector(stopMoveTopFace)];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:0.35];
    [self runAction:[CCSequence actions:delay, cb, nil]];
}

- (void)moveUpTopFace
{
    topBoundBody->SetLinearVelocity([self toMeters:ccp(0, 50 / 0.35)]);
    CCCallFunc *cb = [CCCallFunc actionWithTarget:self
                                         selector:@selector(stopMoveTopFace)];
    CCDelayTime *delay = [CCDelayTime actionWithDuration:0.35];
    [self runAction:[CCSequence actions:delay, cb, nil]];
}
- (void)stopMoveTopFace
{
    topBoundBody->SetLinearVelocity(b2Vec2(0,0));
}
- (void)showAd
{
    if (isAdShown)
        return;
    isAdShown = YES;
    
    [self moveDownTopFace];
    [ball3DLayer showAd];
    
    CCMoveBy *move = [CCMoveBy actionWithDuration:0.35 position:ccp(0, -50)];
    [pausemenu runAction:move];
}

- (void)hideAd
{
    if (!isAdShown)
        return;
    isAdShown = NO;
    [self moveUpTopFace];
    [ball3DLayer hideAd];
    
    CCMoveBy *move = [CCMoveBy actionWithDuration:0.35 position:ccp(0, 50)];
    [pausemenu runAction:move];
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
    screenBorderDef.type = b2_kinematicBody;
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
    self.score += pixels;
}

- (void)speedUpWind
{
    [wind increase];
}

- (void)setWindDirection:(CGFloat)angle
{
    wind.angle = angle;
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

- (void)pauseGame
{
    _isGamePlaying = NO;
    [ball3DLayer pauseSchedulerAndActions];
    [self pauseSchedulerAndActions];
}

- (void)resumeGame
{
    _isGamePlaying = YES;
    [ball3DLayer resumeSchedulerAndActions];
    [self resumeSchedulerAndActions];
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
    
    CGPoint lastPosition = [self toPixels:theBall->GetPosition()];
    
	// The number of iterations influence the accuracy of the physics simulation. With higher values the
	// body's velocity and position are more accurately tracked but at the cost of speed.
	// Usually for games only 1 position iteration is necessary to achieve good results.
    int32 velocityIterations = 2;
    int32 positionIterations = 1;
    world->Step(delta, velocityIterations, positionIterations);
    
    
    CGPoint p = [self toPixels:theBall->GetPosition()];
    CGFloat a = theBall->GetAngle();
    
    [self scoreAddByPixel:ccpDistance(lastPosition, p)];
    [ball3DLayer setArrowDirection:CC_RADIANS_TO_DEGREES(wind.angle)];
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

- (void)onEnter
{
    [super onEnter];
    [self pauseGame];
}

- (void)pausePressed:(id)sender
{
    if (!pauselayer){
        pauselayer = [PauseScene node];
        pauselayer.visible = NO;
        pauselayer.delegate = self;
        [self addChild:pauselayer];
    }
    [self pauseGame];
    [pauselayer modal];
}

#pragma mark - MainMenuDelegate Methods

- (void)onShareTwitter:(id)sender
{
    
}

- (void)onShareFacebook:(id)sender
{
    
}

- (void)onStart:(id)sender
{
    [self resumeGame];
    CCFadeOut *fadeout = [CCFadeOut actionWithDuration:0.35];
    [menulayer runAction:[CCSequence actions:fadeout, [CCHide action], nil]];
}

- (void)onAbout:(id)sender
{
    
}

- (void)onHelp:(id)sender
{
    
}

#pragma mark - PauseDelegate Methods

- (void)onQuit:(id)sender
{
    
}

- (void)onResume:(id)sender
{
    [pauselayer dismiss];
    [self resumeGame];
}
@end
