//
//  StoreScene.m
//  BeatBack
//
//  Created by STEVEN on 11-12-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "StoreScene.h"


@implementation StoreScene
-(void)dealloc
{
    [super dealloc];
}


+(id)scene
{
    CCScene* scene=[CCScene node];
    StoreScene* layer=[StoreScene node];
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
