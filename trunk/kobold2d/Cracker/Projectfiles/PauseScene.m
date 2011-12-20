//
//  PauseScene.m
//  Cracker
//
//  Created by Liu Pok on 11-12-17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "PauseScene.h"

@implementation PauseScene
@synthesize delegate;

+ (id)scene
{
    return [PauseScene nodeWithScene];
}

- (void)dealloc
{
    [super dealloc];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}
- (id)init
{
    if ((self = [super initWithColor:ccc4(0x0, 0x0, 0x0, 0xc0)])){
        CCMenuItemImage *resumeItem = [CCMenuItemImage itemFromNormalImage:@"continue.png"
                                                             selectedImage:@"continue.png"
                                                                    target:self
                                                                  selector:@selector(resumePressed:)];
        CCScaleBy *scale = [CCScaleBy actionWithDuration:0.5 scale:1.1];
        
        CCSequence *seq = [CCSequence actions:
                           [CCEaseIn actionWithAction:scale rate:3.0],
                           [CCEaseOut actionWithAction:[scale reverse] rate:1.8], nil];
        [resumeItem runAction:[CCRepeatForever actionWithAction:seq]];
        
        CCMenuItemImage *quit = [CCMenuItemImage itemFromNormalImage:@"blueArrow.png"
                                                       selectedImage:@"blackArrow.png"
                                                              target:self
                                                            selector:@selector(quitPressed:)];
        menu = [CCMenu menuWithItems:resumeItem, quit, nil];
        [menu alignItemsHorizontallyWithPadding:5];
        [self addChild:menu];
        
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self
                                                         priority:-1
                                                  swallowsTouches:YES];
        //[self scheduleUpdate];
    }
    return self;
}

- (void)modal
{
    self.scale = 0.0f;
    CCScaleTo *scale = [CCScaleTo actionWithDuration:1.2 scale:1.0f];
    
    [self runAction:[CCSequence actions:[CCShow action], [CCEaseElasticOut actionWithAction:scale], nil]];
}

- (void)dismiss
{
    self.scale = 1.0f;
    CCScaleTo *scale = [CCScaleTo actionWithDuration:1.2 scale:0.0f];
    [self runAction:[CCSequence actions:
                     [CCEaseElasticIn actionWithAction:scale], 
                     [CCHide action], nil]];
}

- (void)resumePressed:(id)sender
{
    self.scale = 1.0f;
    CCScaleTo *scale = [CCScaleTo actionWithDuration:0.6 scale:0.0f];
    [self runAction:[CCSequence actions:
                     [CCEaseIn actionWithAction:scale rate:5.0], 
                     [CCHide action],
                     [CCCallBlock actionWithBlock:^(){
        [delegate onResume:sender];
    }], nil]];
}

- (void)quitPressed:(id)sender
{
    self.scale = 1.0f;
    CCScaleTo *scale = [CCScaleTo actionWithDuration:0.6 scale:0.0f];
    [self runAction:[CCSequence actions:
                     [CCEaseIn actionWithAction:scale rate:5.0], 
                     [CCHide action],
                     [CCCallBlock actionWithBlock:^(){
        [delegate onQuit:sender];
    }], nil]];
}

#pragma mark - Touch Delegate

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}
@end
