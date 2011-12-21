//
//  GameOver.m
//  Cracker
//
//  Created by Liu Pok on 11-12-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "GameOver.h"
#import "Helper.h"

@interface GameOver (PrivateMethods)
- (void)againPressed:(id)sender;
- (void)menuPressed:(id)sender;
@end

@implementation GameOver
@synthesize score = _score;
@synthesize best = _best;
@synthesize delegate;

- (id)init
{
    if ((self = [super initWithColor:ccc4(0x0, 0x0, 0x0, 0xc0)])){
        CGPoint c = [CCDirector sharedDirector].screenCenter;
        
        CCSprite *oops = [CCSprite spriteWithFile:@"oops.png"];
        CCSprite *best = [CCSprite spriteWithFile:@"bestscore.png"];
        CCSprite *score = [CCSprite spriteWithFile:@"score.png"];
        
        scoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"bitmapFontTest2.fnt"];
        bestLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"bitmapFontTest2.fnt"];
        
        oops.position = ccpAdd(c, ccp(0, 160));
        score.position = ccpAdd(c, ccp(-56, 100));
        best.position = ccpAdd(c, ccp(-80, 60));
        scoreLabel.position = ccpAdd(c, ccp(60, 100));
        bestLabel.position = ccpAdd(c, ccp(60, 60));
        
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
        [self addChild:score];
        [self addChild:scoreLabel];
        [self addChild:bestLabel];
        [self addChild:menu]; 
        
        _best = [Helper bestScore];
    }
    return self;
}

- (void)setScore:(uint)score
{
    _score = score;
    scoreLabel.string = [NSString stringWithFormat:@"%d",self.score];
    
    if (_score > _best){
        _best = _score;
        [Helper saveBestScore:_best];
        bestLabel.string = [NSString stringWithFormat:@"%d",_best];
    }
}

- (void)againPressed:(id)sender
{
    self.scale = 1.0f;
    CCScaleTo *scale = [CCScaleTo actionWithDuration:0.6 scale:0.0f];
    [self runAction:[CCSequence actions:
                     [CCEaseIn actionWithAction:scale rate:5.0], 
                     [CCHide action],
                     [CCCallBlock actionWithBlock:^(){
        [delegate onAgain:sender];
    }], nil]];
}

- (void)menuPressed:(id)sender
{
    self.scale = 1.0f;
    CCScaleTo *scale = [CCScaleTo actionWithDuration:0.6 scale:0.0f];
    [self runAction:[CCSequence actions:
                     [CCEaseIn actionWithAction:scale rate:5.0], 
                     [CCHide action],
                     [CCCallBlock actionWithBlock:^(){
        [delegate onMenu:sender];
    }], nil]];
}
@end
