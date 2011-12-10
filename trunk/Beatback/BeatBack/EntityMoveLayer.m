//
//  EntityMoveLayer.m
//  BeatBack
//
//  Created by STEVEN on 11-12-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "EntityMoveLayer.h"
#import "GameScene.h"

@implementation EntityMoveLayer
-(void)dealloc
{
    [super dealloc];
}
-(id)init
{
    if (self=[super init]) {
        self.isTouchEnabled=YES;
        
       hero=[GameScene sharedGameScene].hero ;
        
      //  [self registerWithTouchDispatcher];
      //  [self scheduleUpdate];
    }
    
    return self;
    
}


-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch=[touches anyObject];
    CGPoint location=[[CCDirector sharedDirector]convertToGL: [touch locationInView:[touch view]]];
    
    touchOffsetX=hero.position.x-location.x;
    touchOffsetY=hero.position.y-location.y;
    
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
     UITouch* touch=[touches anyObject];
    CGPoint new;
    CGPoint location=[[CCDirector sharedDirector]convertToGL: [touch locationInView:[touch view]]];
    new=ccpAdd(location, CGPointMake(touchOffsetX, touchOffsetY));
    
    hero.position=new;
}


@end
