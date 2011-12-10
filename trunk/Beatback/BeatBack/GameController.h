//
//  GameController.h
//  BeatBack
//
//  Created by STEVEN on 11-12-4.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "PlayerInfo.h"

@interface GameController : NSObject
{
    CCDirector* sharedDirector;
    CGRect screenSize;
    PlayerInfo* playerInfo;
 
}
@property(nonatomic,assign)  CGRect screenSize;
@property(nonatomic,readonly)CCDirector* sharedDirector;
@property(nonatomic,retain)PlayerInfo* playerInfo;

+ (GameController *)sharedGameController;


@end
