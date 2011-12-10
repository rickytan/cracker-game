//
//  GameScene.h
//  BeatBack
//
//  Created by STEVEN on 11-12-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Hero.h"

@interface GameScene : CCLayer {
    Hero *hero;
}
@property(nonatomic,retain)Hero* hero;

+(GameScene*) sharedGameScene;
+(id)sceneWithHero:(int) HID map:(int)MID;
-(id)initWithHero:(int)HID;
@end
