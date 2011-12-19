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
- (id)init
{
    if ((self = [super init])){
        
        CCMenuItemImage *resumeItem = [CCMenuItemImage itemFromNormalImage:@"continue.png"
                                                             selectedImage:@"continue.png"
                                                                    target:self
                                                                  selector:@selector(resumePressed:)];
        CCMenuItemImage *quit = [CCMenuItemImage itemFromNormalImage:@"blueArrow.png"
                                                       selectedImage:@"blackArrow.png"
                                                              target:self
                                                            selector:@selector(quitPressed:)];
        menu = [CCMenu menuWithItems:resumeItem, quit, nil];
        [menu alignItemsHorizontallyWithPadding:5];
        [self addChild:menu];
        
        self.contentSize = CGSizeMake(240, 320);
        
        //[self scheduleUpdate];
    }
    return self;
}

- (void)modal
{
    self.scale = 0.0f;
    CCScaleTo *scale = [CCScaleTo actionWithDuration:0.35 scale:1.0f];
    
    [self runAction:[CCEaseElasticIn actionWithAction:scale period:0.4]];
}

- (void)dismiss
{
    self.scale = 1.0f;
    CCScaleTo *scale = [CCScaleTo actionWithDuration:0.35 scale:0.0f];
    [self runAction:[CCEaseElasticOut actionWithAction:scale period:0.4]];
}

- (void)resumePressed:(id)sender
{
    [delegate onResume:sender];
}

- (void)quitPressed:(id)sender
{
    [delegate onQuit:sender];
}
@end
