//
//  GameScene.m
//  Cracker
//
//  Created by  on 11-12-5.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "MenuScene.h"
#import "PlayLayer.h"
#import "SimpleAudioEngine.h"
#import "PauseScene.h"

@implementation GameScene

- (id)init
{
    if ((self = [super init])){
        [[CCDirector sharedDirector] enableRetinaDisplay:YES];
        [self addChild:[PlayLayer node]];
        
        [self scheduleUpdate];
        
    }
    return self;
}


#pragma mark - Overrided Methods

- (void)update:(ccTime)delta
{
    KKInput *input = [KKInput sharedInput];
    
    if (input.anyTouchEndedThisFrame){
        [[CCDirector sharedDirector] pushScene:[PauseScene node]];
    }
}

@end
