//
//  GameScene.h
//  Cracker
//
//  Created by  on 11-12-5.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "PlayLayer.h"
#import "MainMenu.h"
#import "PauseScene.h"
#import "GameOver.h"
#import "TipsLayer.h"
#import "CreditLayer.h"
#import <iAd/iAd.h>


typedef enum {
    kGameStateMenu,
    kGameStatePlaying,
    kGameStatePausing,
    kGameStateOver,
    kGameStateTips,
    kGameStateCredits
} GameState;

@class PlayLayer;

@interface GameScene : CCScene 
<ADBannerViewDelegate, GameOverDelegate, MainMenuButtonDelegate, PauseDelegate> {
    ADBannerView *          adView;
    PlayLayer *             playlayer;  // Weak assign
    GameOver *              gameover;   // Weak assign
    MainMenu *              menulayer;   // Weak assign
    PauseScene *            pauselayer; // Weak assign
    TipsLayer *             tiplayer;   // Weak
    CreditLayer *           creditlayer;// Weak
}
@property (nonatomic, assign) GameState state;
+ (GameScene*)sharedGame;
- (void)showAd;
- (void)hideAd;
@end
