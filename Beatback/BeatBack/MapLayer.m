//
//  MapLayer.m
//  BeatBack
//
//  Created by STEVEN on 11-12-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "MapLayer.h"


static NSString* MAP_NAME[3][6]={{@"map_AiJi_1.png",@"map_AiJi_2.png",@"map_AiJi_3.png",@"map_AiJi_4.png",@"map_AiJi_5.png",@"map_AiJi_5.png"},{},{}};

@implementation MapLayer
-(void)dealloc
{
    [maps release];
    [super dealloc];
}
-(id)initWithId:(int)MID
{
    self=[super init];
    if (self!=nil) 
    {
        screenSize=[[CCDirector sharedDirector] winSize];
        maps= [[NSMutableArray alloc]init];
        
        
        for (int i=0; i<6; i++) 
        {
            CCSprite* tmp=[CCSprite spriteWithFile:MAP_NAME[MID][i]];
            tmp.visible=NO;
            [self addChild:tmp z:i tag:i];
            [maps addObject:tmp];
        }
        
        CCSprite* tmp2=[maps objectAtIndex:0];
        tmp2.visible=YES;
        tmp2.position= CGPointMake(screenSize.width/2, screenSize.height/2);
    
        tmp2=[maps objectAtIndex:1];
        tmp2.position= CGPointMake(screenSize.width/2, screenSize.height/2*3-1);
        tmp2.visible=YES;
        
        speed=3.0f;
        fmap=0;
        smap=1;
       
       [self schedule:@selector( update:) interval:0.03];
       // [self scheduleUpdate];
    }
    
    return self;
}

-(void)update:(ccTime) dt
{
    CCSprite *currentMap=[maps objectAtIndex:fmap];
    CCSprite *nextMap=[maps objectAtIndex:smap];
    
    
    if (currentMap.position.y < (-screenSize.height/2)) 
    {
        currentMap.visible=NO;
        fmap=smap;
        smap=smap+1;
        if (smap>5) 
        {
            [self unscheduleAllSelectors];
            return;
        }
        currentMap=[maps objectAtIndex:fmap];
        nextMap=[maps objectAtIndex:smap];
        
        nextMap.position = ccpAdd(currentMap.position, CGPointMake(0, screenSize.height-1));
    }   
    currentMap.visible=YES;
    nextMap.visible=YES;
    currentMap.position= ccpSub(currentMap.position, ccp(0, speed));
    nextMap.position= ccpSub(nextMap.position, ccp(0, speed));
    
    NSLog(@"%f %f  %d, %d",currentMap.position.y,nextMap.position.y, fmap,smap);
}

@end
