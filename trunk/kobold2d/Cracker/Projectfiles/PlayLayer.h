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
#import "Wind.h"
#import "MainMenu.h"
#import "PauseScene.h"
#import "GameOver.h"

class ContactListener::b2ContactListener
{
private:
    virtual 
};
@interface PlayLayer : CCLayer {
    b2World *               world;
    b2Body *                topBoundBody;

    b2Body *                theBall;    // Weak assign
    
    Ball3DLayer *           ball3DLayer;// Weak assign
    NSTimer *               timer;
    Wind *                  wind;       // Weak assign
    uint                    score;
    CCLabelBMFont *         scoreLabel;
    NSTimer *               scoreAddTimer;

    CCMenu *                pausemenu;  // Weak assign
    CCMenu *                upmenu;     // Weak assign
    CCMotionStreak *        motionStreak;   // Weak assign
    
    BOOL                    isAdShown;
}

@property (nonatomic, assign) uint score;
@property (nonatomic, readonly) BOOL isGamePlaying;


- (void)showAd;
- (void)hideAd;
- (void)startGame;
- (void)pauseGame;
- (void)resumeGame;
- (void)endGame;
@end
