//
//  CreditLayer.m
//  Cracker
//
//  Created by Liu Pok on 11-12-22.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CreditLayer.h"
#import "GameScene.h"

@implementation CreditLayer

- (id)init
{
    if ((self = [super init])){
        CCMenuItemImage *item = [CCMenuItemImage itemFromNormalImage:@"credits.png"
                                                       selectedImage:@"credits.png"
                                                              target:self selector:@selector(dismiss:)];
        
        [self addChild:[CCMenu menuWithItems:item, nil]];
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
