//
//  GameOver.h
//  Cracker
//
//  Created by Liu Pok on 11-12-20.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@protocol GameOverDelegate <NSObject>

@required
- (void)onAgain:(id)sender;
- (void)onMenu:(id)sender;

@end

@interface GameOver : CCLayerColor {
    CCLabelBMFont *             scoreLabel;
    CCLabelBMFont *             bestLabel;
}

@property (nonatomic, assign) uint score;
@property (nonatomic, readonly) uint best;
@property (nonatomic, assign) id<GameOverDelegate> delegate;

@end
