//
//  GameScene.m
//  BeatBack
//
//  Created by STEVEN on 11-12-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "MapLayer.h"
#import "EntityMoveLayer.h"
#import "SelectColorLayer.h"
#import "Hero.h"

#define HERO 1

@implementation GameScene
@synthesize hero;

static GameScene* instanceOfGameScene;

-(void)dealloc
{
    [super dealloc];
}

//创建一个gamescence
+(id)sceneWithHero:(int)HID map:(int)MID
{
    CCScene* scene=[CCScene node];
    
    MapLayer* map=[[[MapLayer alloc]initWithId:MID]autorelease];
    [scene addChild:map z:0];
    
    GameScene* entity=[[[GameScene alloc]initWithHero:HID]autorelease];
    [scene addChild:entity z:1];
    
    EntityMoveLayer* move=[EntityMoveLayer node];
    [scene addChild:move z:2];
    
    SelectColorLayer* color=[SelectColorLayer node];
    [scene addChild:color z:3];
    
    return  scene;
}
-(id)initWithHero:(int)HID
{
        if (self=[super init]) 
        {
              
            
            instanceOfGameScene=self;
            CGSize s=[[CCDirector sharedDirector]winSize];
            
            hero=[[[Hero alloc]initWithHeroID:HID]autorelease];
            hero.position=ccp( s.width/2, s.height/5);
            
            [self addChild:hero z:1 tag:HERO];
            
        }
        
        return self;
        
}

+(GameScene *)sharedGameScene
{
    return instanceOfGameScene;
}
@end
