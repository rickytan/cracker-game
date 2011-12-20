//
//  GameOver.m
//  Cracker
//
//  Created by Liu Pok on 11-12-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "GameOver.h"

@implementation GameOver
@synthesize score;
@synthesize delegate;

- (id)init
{
    if ((self = [super init])){
        CCSprite *oops = [CCSprite spriteWithFile:@"oops.png"];
        CCSprite *best = [CCSprite spriteWithFile:@"bestscore.png"];
        CCSprite *_score = [CCSprite spriteWithFile:@"score.png"];
        
        CCLabelBMFont *scoreLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"bitmapFontTest2.fnt"];
        
        CCMenuItemSprite *again = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"again.png"]
                                                          selectedSprite:[CCSprite spriteWithFile:@"again.png"]
                                                                   block:^(id sender){
                                                                       [delegate onAgain:sender];
                                                                   }];
        CCMenuItemSprite *m = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithFile:@"menu.png"]
                                                      selectedSprite:[CCSprite spriteWithFile:@"menu.png"]
                                                               block:^(id sender){
                                                                   
                                                               }];
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
    
}
@end
