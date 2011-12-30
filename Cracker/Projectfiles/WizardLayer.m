//
//  WizardLayer.m
//  Cracker
//
//  Created by Liu Pok on 11-12-29.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WizardLayer.h"

@implementation WizardLayer

- (id)init
{
    if ((self = [super initWithColor:ccc4(0x0, 0x0, 0x0, 0xc0)])){
        CCMenuItemImage *item = [CCMenuItemImage itemFromNormalImage:@"teach-player.png"
                                                       selectedImage:@"teach-player.png"
                                                              target:self selector:@selector(dismiss:)];
        
        [self addChild:[CCMenu menuWithItems:item, nil]];
    }
    return self;
}

- (void)dismiss:(id)sender
{
    self.scale = 1.0f;
    CCScaleTo *scale = [CCScaleTo actionWithDuration:0.6 scale:0.0f];
    [self runAction:[CCSequence actions:
                     [CCEaseIn actionWithAction:scale rate:5.0], 
                     [CCHide action], nil]];
}
@end
