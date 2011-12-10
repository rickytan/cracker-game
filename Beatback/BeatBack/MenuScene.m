//
//  MenuScene.m
//  BeatBack
//
//  Created by STEVEN on 11-12-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "MenuScene.h"


@implementation MenuScene
-(void)dealloc
{
    [super dealloc];
}


+(id)scene
{
    CCScene* scene=[CCScene node];
    MenuScene* layer=[MenuScene node];
    [scene addChild:layer z:0];
    return  scene;
}

-(id)init
{
    if (self=[super init]) {
        
    }
    
    return self;
    
}

@end
