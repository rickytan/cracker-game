//
//  GameScene.h
//  Cracker
//
//  Created by  on 11-12-5.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "PlayLayer.h"
#import "MenuScene.h"
#import "PauseScene.h"
#import "GameOver.h"
#import <iAd/iAd.h>


typedef enum {
    kGameStateMenu,
    kGameStatePlaying,
    kGameStatePausing,
    kGameStateOver
} GameState;

@interface GameScene : CCScene 
<ADBannerViewDelegate, GameOverDelegate, MainMenuButtonDelegate, PauseDelegate> {
    ADBannerView *          adView;
    PlayLayer *             playlayer;  // Weak assign
    GameOver *              gameover;   // Weak assign
    MainMenu *              menulayer;   // Weak assign
    PauseScene *            pauselayer; // Weak assign
}
@property (nonatomic, assign) GameState state;
+ (id)sharedGame;
- (void)showAd;
- (void)hideAd;
@end
