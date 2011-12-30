//
//  TipsLayer.m
//  Cracker
//
//  Created by Liu Pok on 11-12-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "TipsLayer.h"
#import "GameScene.h"

@implementation TipsLayer

- (id)init
{
    if ((self = [super initWithColor:ccc4(0x0, 0x0, 0x0, 0xc0)])){
        CCMenu *m = [CCMenu menuWithItems:[CCMenuItemImage itemFromNormalImage:@"disable_ad.png"
                                                                 selectedImage:@"disable_ad.png"
                                                                        target:self
                                                                      selector:@selector(dismiss:)],
                     [CCMenuItemImage itemFromNormalImage:@"moving_earn_more.png"
                                            selectedImage:@"moving_earn_more.png"
                                                   target:self
                                                 selector:@selector(dismiss:)], nil];
        [m alignItemsVerticallyWithPadding:45];
        [self addChild:m];
    }
    return self;
}

- (void)dismiss:(id)s
{
    self.scale = 1.0f;
    CCScaleTo *scale = [CCScaleTo actionWithDuration:0.6 scale:0.0f];
    [self runAction:[CCSequence actions:
                     [CCEaseIn actionWithAction:scale rate:5.0], 
                     [CCHide action], nil]];
    [GameScene sharedGame].state = kGameStateMenu;
}
@end
