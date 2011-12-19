//
//  PlayLayer.h
//  Cracker
//
//  Created by  on 11-12-6.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CCLayer.h"
#import "Box2D.h"
#import "CC3Node.h"
#import "Ball3DLayer.h"
#import "ContactListener.h"
#import "Wind.h"
#import "MainMenu.h"
#import "PauseScene.h"

@interface PlayLayer : CCLayer <MainMenuButtonDelegate, PauseDelegate> {
    b2World *               world;
    b2Body *                topBoundBody;
    ContactListener *       contact;
    b2Body *                theBall;    // Weak assign
    
    Ball3DLayer *           ball3DLayer;// Weak assign
    NSTimer *               timer;
    Wind *                  wind;       // Weak assign
    uint                    score;
    CCLabelBMFont *         scoreLabel;
    NSTimer *               scoreAddTimer;
    MainMenu *              menulayer;  // Weak assign
    PauseScene *            pauselayer; // Weak assign
    CCMenu *                pausemenu;  // Weak assign

    BOOL                    isAdShown;
}

@property (nonatomic, assign) uint score;
@property (nonatomic, readonly) BOOL isGamePlaying;

- (void)pausePressed:(id)sender;
- (void)showAd;
- (void)hideAd;
- (void)pauseGame;
- (void)resumeGame;
@end
