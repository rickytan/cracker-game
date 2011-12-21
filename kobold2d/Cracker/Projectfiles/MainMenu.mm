//
//  MainMenu.m
//  Cracker
//
//  Created by  on 11-12-5.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "MainMenu.h"
#import "GameScene.h"
#import "Helper.h"


@interface MainMenu (PrivateMethods)

- (void)enableBox2dDebugDrawing;
- (void)activate;
- (b2Vec2) toMeters:(CGPoint)point;
- (CGPoint) toPixels:(b2Vec2)vec;
@end


@implementation MainMenu
@synthesize delegate;

- (void)dealloc
{
#ifndef KK_ARC
    [super dealloc];
#endif
    delete world;
    delete debugDraw;
    //[playScene release];
}
- (id)init
{
    if ((self = [super init])){
        
        world = new b2World(b2Vec2(0.0f, 0.0f));
        world->SetAllowSleeping(NO);
        //playScene = [GameScene new];
        
        
        worldStatic = YES;
        //[self enableBox2dDebugDrawing];
        
        // for the screenBorder body we'll need these values
		CGSize screenSize = [CCDirector sharedDirector].winSize;
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
		screenBorderBody->CreateFixture(&screenBorderShape, 0)->SetFriction(0.8);
		screenBorderShape.Set(lowerRightCorner, upperRightCorner);
		screenBorderBody->CreateFixture(&screenBorderShape, 0)->SetFriction(0.8);
		screenBorderShape.Set(upperRightCorner, upperLeftCorner);
		screenBorderBody->CreateFixture(&screenBorderShape, 0)->SetFriction(0.8);
		screenBorderShape.Set(upperLeftCorner, lowerLeftCorner);
		screenBorderBody->CreateFixture(&screenBorderShape, 0)->SetFriction(0.8);
        
		[CCMenuItemFont setFontSize:30];
		[CCMenuItemFont setFontName: @"Courier New"];
        
        
        CCMenuItemSprite *fb = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"facebook.png"]
                                                       selectedSprite:[CCSprite spriteWithFile:@"facebook.png"]
                                                                target:self
                                                             selector:@selector(onShareFacebook:)];
        CCMenuItemSprite *tw = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"twitter.png"]
                                                       selectedSprite:[CCSprite spriteWithFile:@"twitter.png"]
                                                                target:self
                                                             selector:@selector(onShareTwitter:)];
        //fb.scale = 0.5;
        //tw.scale = 0.5;

        CCMenuItemSprite *item0 = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"start.png"]
                                                          selectedSprite:[CCSprite spriteWithFile:@"start_grey.png"]
                                                                   target:self
                                                                selector:@selector(onStart:)];
        CCMenuItemSprite *item1 = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"tips.png"]
                                                          selectedSprite:[CCSprite spriteWithFile:@"tips_grey.png"]
                                                                   target:self
                                                                selector:@selector(onHelp:)];
        CCMenuItemSprite *item2 = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"credits_ch.png"]
                                                          selectedSprite:[CCSprite spriteWithFile:@"credits_ch_grey.png"]
                                                                   target:self
                                                                selector:@selector(onAbout:)];
        
		menu = [CCMenu menuWithItems:item0, item1, item2, fb, tw, nil];
        [menu alignItemsInColumns:
         [NSNumber numberWithInt:1],
         [NSNumber numberWithInt:1],
         [NSNumber numberWithInt:1],
         [NSNumber numberWithInt:2], nil];

		/*
        CGSize s = [[CCDirector sharedDirector] winSize];
        int i=0;
        for( CCNode *child in [menu children] ) {
            CGPoint dstPoint = child.position;
            
            int offset = s.width/2 + 20;
            if( i % 2 == 0)
                offset = -offset;
            
            child.position = ccp( dstPoint.x + offset, dstPoint.y);
            i++;
        }
        */
		[self addChild: menu];
        
        // elastic effect
        ccTime duration = 2.0f;

        for( CCNode *child in [menu children] ) {
            CGPoint dstPoint = child.position;
            //dstPoint.x = 0;
            /*
            [child runAction: 
             [CCEaseElasticOut actionWithAction: 
              [CCMoveTo actionWithDuration:duration
                                  position:dstPoint]
                                         period: 0.35f]];
            i++;
            */
            /*=============== Add Bodies =================*/
            b2Body *body;
            b2BodyDef bodyDef;
            bodyDef.position = [self toMeters:ccpAdd(dstPoint,menu.position)];
            bodyDef.type = b2_dynamicBody;
            bodyDef.userData = (__bridge void*)child;
            body = world->CreateBody(&bodyDef);
            
            // Define another box shape for our dynamic bodies.
            b2PolygonShape dynamicBox;
            CGSize bound = child.contentSize;
            dynamicBox.SetAsBox(bound.width / PTM_RATIO * 0.5f, bound.height / PTM_RATIO * 0.5f);
            
            // Define the dynamic body fixture.
            b2FixtureDef fixtureDef;
            fixtureDef.shape = &dynamicBox;	
            fixtureDef.density = 0.1f;
            fixtureDef.friction = 0.5f;
            fixtureDef.restitution = 0.6f;
            body->CreateFixture(&fixtureDef);
            
        }
        [self performSelector:@selector(activate) 
                   withObject:nil
                   afterDelay:duration];


        [self scheduleUpdate];

		[KKInput sharedInput].deviceMotionActive = YES;
    }
    return self;
}

#pragma mark - Methods

- (void)onStart:(id)sender
{
    [delegate onStart:sender];
}
- (void)onHelp:(id)sender
{
    [delegate onHelp:sender];
}
- (void)onAbout:(id)sender
{
    [delegate onAbout:sender];
}
- (void)onShareFacebook:(id)sender
{
    [delegate onShareFacebook:sender];
}
- (void)onShareTwitter:(id)sender
{
    [delegate onShareTwitter:sender];
}


// convenience method to convert a CGPoint to a 
-(b2Vec2) toMeters:(CGPoint)point
{
	return b2Vec2(point.x / PTM_RATIO, point.y / PTM_RATIO);
}

// convenience method to convert a b2Vec2 to a CGPoint
-(CGPoint) toPixels:(b2Vec2)vec
{
	return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}

-(void) enableBox2dDebugDrawing
{
	float debugDrawScaleFactor = 1.0f;
#if KK_PLATFORM_IOS
	debugDrawScaleFactor = [[CCDirector sharedDirector] contentScaleFactor];
#endif
	debugDrawScaleFactor *= PTM_RATIO;
	
	debugDraw = new GLESDebugDraw(debugDrawScaleFactor);
	
	if (debugDraw)
	{
		UInt32 debugDrawFlags = 0;
		debugDrawFlags += b2Draw::e_shapeBit;
		debugDrawFlags += b2Draw::e_jointBit;
		//debugDrawFlags += b2Draw::e_aabbBit;
		//debugDrawFlags += b2Draw::e_pairBit;
		//debugDrawFlags += b2Draw::e_centerOfMassBit;
		
		debugDraw->SetFlags(debugDrawFlags);
		world->SetDebugDraw(debugDraw);
	}
}

- (void)activate
{
    worldStatic = NO;
}

#pragma mark - Overrided Methods

- (void)update:(ccTime)delta
{
	CCDirector* director = [CCDirector sharedDirector];
    
    KKInput* input = [KKInput sharedInput];
    if (director.currentDeviceIsSimulator == NO)
    {
        KKAcceleration* acceleration = input.deviceMotion.gravity;
        b2Vec2 gravity = 20.0f * b2Vec2(acceleration.rawX, acceleration.rawY);
        world->SetGravity(gravity);
    }
    
	
	// The number of iterations influence the accuracy of the physics simulation. With higher values the
	// body's velocity and position are more accurately tracked but at the cost of speed.
	// Usually for games only 1 position iteration is necessary to achieve good results.
    if (!worldStatic){
        
        int32 velocityIterations = 2;
        int32 positionIterations = 1;
        world->Step(delta, velocityIterations, positionIterations);
        
        // for each body, get its assigned sprite and update the sprite's position
        for (b2Body* body = world->GetBodyList(); body != nil; body = body->GetNext())
        {
            CCSprite* sprite = (__bridge CCSprite*)body->GetUserData();
            if (sprite != NULL)
            {
                // update the sprite's position to where their physics bodies are
                sprite.position = ccpSub([self toPixels:body->GetPosition()],menu.position);;
                float angle = body->GetAngle();
                sprite.rotation = CC_RADIANS_TO_DEGREES(angle) * -1;
            }
        }
    }
}

#if DEBUG
-(void) draw
{
	[super draw];
    
	if (debugDraw)
	{
		// these GL states must be disabled/enabled otherwise drawing debug data will not render and may even crash
		glDisable(GL_TEXTURE_2D);
		glDisableClientState(GL_COLOR_ARRAY);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
		glEnableClientState(GL_VERTEX_ARRAY);
		
		world->DrawDebugData();
		
		glDisableClientState(GL_VERTEX_ARRAY);   
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glEnableClientState(GL_COLOR_ARRAY);
		glEnable(GL_TEXTURE_2D);	
	}
}
#endif

@end
