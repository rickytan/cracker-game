//
//  GameController.m
//  BeatBack
//
//  Created by STEVEN on 11-12-4.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "GameController.h"
#import "SynthesizeSingleton.h"

@implementation GameController
@synthesize screenSize;
@synthesize sharedDirector;
@synthesize playerInfo;

SYNTHESIZE_SINGLETON_FOR_CLASS(GameController);

-(void)dealloc
{
    [playerInfo release];
    [super dealloc];
}

-(id)init
{
    if (self=[super init]) {
        CCLOG(@"INFO - GameController: Starting game initialization.");

        playerInfo= [[PlayerInfo alloc] init];
        
        sharedDirector=[CCDirector sharedDirector];
        
 
        
    }

    return  self;

}



@end
