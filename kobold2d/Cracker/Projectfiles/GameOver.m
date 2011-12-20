//
//  GameOver.m
//  Cracker
//
//  Created by Liu Pok on 11-12-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "GameOver.h"

@interface GameOver (PrivateMethods)
- (void)againPressed:(id)sender;
- (void)menuPressed:(id)sender;
@end

@implementation GameOver
@synthesize score;
@synthesize delegate;

- (id)init
{
    if ((self = [super initWithColor:ccc4(0x0, 0x0, 0x0, 0xc0)])){
        CGPoint c = [CCDirector sharedDirector].screenCenter;
        
        CCSprite *oops = [CCSprite spriteWithFile:@"oops.png"];
        CCSprite *best = [CCSprite spriteWithFile:@"bestscore.png"];
        CCSprite *_score = [CCSprite spriteWithFile:@"score.png"];
        
        CCLabelBMFont *scoreLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"bitmapFontTest2.fnt"];
        
        oops.position = ccpAdd(c, ccp(0, 160));
        _score.position = ccpAdd(c, ccp(-60, 100));
        best.position = ccpAdd(c, ccp(-90, 60));
        
        CCMenuItemSprite *again = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"back.png"]
                                                          selectedSprite:[CCSprite spriteWithFile:@"back.png"]
                                                                   target:self
                                                                selector:@selector(againPressed:)];
        [again runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:1 angle:360]]];
        CCMenuItemSprite *m = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"menu.png"]
                                                      selectedSprite:[CCSprite spriteWithFile:@"menu.png"]
                                                               target:self
                                                            selector:@selector(menuPressed:)];
        CCMenu *menu = [CCMenu menuWithItems:again, m, nil];
        [menu alignItemsHorizontally];
        
        [self addChild:oops];
        [self addChild:best];
        [self addChild:_score];
        [self addChild:scoreLabel];
        [self addChild:menu];
    }
    return self;
}

- (void)againPressed:(id)sender
{
    [delegate onAgain:sender];
}

- (void)menuPressed:(id)sender
{
    [delegate onMenu:sender];
}
@end
