//
//  StartScene.m
//  BeatBack
//
//  Created by STEVEN on 11-12-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "StartScene.h"


@implementation StartScene
-(void)dealloc
{
    [super dealloc];
}


+(id)scene
{
    CCScene* scene=[CCScene node];
    StartScene* layer=[StartScene node];
    [scene addChild:layer];
    return  scene;
}

-(id)init
{
    if (self=[super init]) {
        CGSize wsize=[[CCDirector sharedDirector]winSize];
        
        CCSprite* bg=[CCSprite spriteWithFile:@"startbackground.png"];
        bg.position=CGPointMake(wsize.width/2, wsize.height/2);
        [self addChild:bg z:0];
        
        CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
        [frameCache addSpriteFramesWithFile:@"jiemianyuansu.plist"];
        
        CCSprite* play = [CCSprite spriteWithSpriteFrameName:@"play.png"];
        
        CCSprite* play2 = [CCSprite spriteWithSpriteFrameName:@"play.png"];
        play2.scale = 1.03;
        
        CCMenuItemSprite* playButtonItem =
       // [CCMenuItemSprite itemFromNormalSprite:play selectedSprite:play2];
        CCMenu* playButton = [CCMenu menuWithItems:playButtonTtem, nil];
        playButton.position = CGPointMake(wsize.width / 2, wsize.height / 2);
        [playButton alignItemsVerticallyWithPadding:0];
        [self addChild:playButton];
        
        self.isTouchEnabled=YES;
    }

    return self;

}
-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{


}

@end
