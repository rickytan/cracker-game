//
//  GameScene.m
//  Cracker
//
//  Created by  on 11-12-5.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "SimpleAudioEngine.h"
#import "PauseScene.h"
#import "Helper.h"

static GameScene *_sharedGame = nil;

@implementation GameScene
@synthesize state = _state;

+ (GameScene*)sharedGame
{
    if (!_sharedGame){
        _sharedGame = [[GameScene alloc] init];
    }
    return _sharedGame;
}

+ (id)alloc
{
    NSAssert(_sharedGame == nil, @"Can't alloc twice!!!");
    return [super alloc];
}

- (void)dealloc
{
    [super dealloc];
    _sharedGame = nil;
    
    
    [adView removeFromSuperview];
    [adView release];
    adView = nil;
}

- (id)init
{
    if ((self = [super init])){
        
        CCDirector *dir = [CCDirector sharedDirector];
        
        [dir enableRetinaDisplay:YES];
        
        
        playlayer = [PlayLayer node];
        gameover = [GameOver node];
        menulayer = [MainMenu node];
        pauselayer = [PauseScene node];
        
        gameover.delegate = self;
        pauselayer.delegate = self;
        menulayer.delegate = self;
        
        [self addChild:playlayer z:-3];
        [self addChild:gameover z:2];
        [self addChild:pauselayer z:1];
        [self addChild:menulayer];

        
        self.state = kGameStateMenu;
    }
    return self;
}

- (void)initAd
{
    if (adView)
        return;
    
    adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    
    adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
    [[CCDirector sharedDirector].openGLView addSubview:adView];
    adView.delegate = self;
    adView.hidden = YES;
}

- (void)showAd
{
    [playlayer showAd];
    
    adView.frame = CGRectMake(0, -50, 320, 50);
    
    [UIView beginAnimations:@"AdViewAppear" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.35];
    
    adView.hidden = NO;
    adView.frame = CGRectMake(0, 0, 320, 50);
    
    [UIView commitAnimations];
}

- (void)hideAd
{
    [playlayer hideAd];
    
    [UIView beginAnimations:@"AdViewDisappear" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.35];
    
    adView.frame = CGRectMake(0, -50, 320, 50);
    
    [UIView commitAnimations];
}

#pragma mark - setter

- (void)setState:(GameState)state
{
    CGSize s = [CCDirector sharedDirector].screenSize;
    switch (state) {
        case kGameStateMenu:
            if (_state == kGameStateCredits || _state == kGameStateTips) {
                break;
            }
            gameover.visible = NO;
            pauselayer.visible = NO;
            [playlayer hideAd];
            
            menulayer.visible = YES;
            menulayer.position = ccp(-s.width, 0);
            [menulayer runAction:[CCSequence actions:[CCEaseElasticOut actionWithAction:[CCMoveTo actionWithDuration:1.2 position:ccp(0, 0)]],[CCCallBlock actionWithBlock:^(){
                [menulayer resumeSchedulerAndActions];
            }], nil]];
            break;
        case kGameStateOver:
            if (_state == kGameStatePlaying){
                [playlayer endGame];
                
                gameover.score = playlayer.score;
                gameover.visible = YES;
                gameover.scale = 1.0f;
                gameover.position = ccp(0,s.height);
                CCMoveTo *move = [CCMoveTo actionWithDuration:1.2 position:ccp(0, 0)];
                [gameover runAction:[CCEaseElasticOut actionWithAction:move]];
                
            }
            break;
        case kGameStatePausing:
            [playlayer pauseGame];
            [pauselayer modal];
            break;
        case kGameStatePlaying:
            if (_state == kGameStatePausing){   // resume game
                [playlayer resumeGame];
            }
            else if (_state == kGameStateMenu){ // first start
                [self initAd];
                [playlayer startGame];
                CCMoveTo *move = [CCMoveTo actionWithDuration:0.35 position:ccp(-500, 0)];
                [menulayer runAction:[CCSequence actions: move, [CCHide action],[CCCallBlock actionWithBlock:^(){
                    [menulayer pauseSchedulerAndActions];
                }], nil]];
            }
            else {
                [playlayer startGame];
            }
            //[self showAd];
            break;
        case kGameStateTips:
        {
            if (!tiplayer){
                tiplayer = [TipsLayer node];
                [self addChild:tiplayer z:3];
            }
            tiplayer.scale = 0.0f;
            CCScaleTo *scale = [CCScaleTo actionWithDuration:1.2 scale:1.0f];
            
            [tiplayer runAction:[CCSequence actions:[CCShow action], [CCEaseElasticOut actionWithAction:scale], nil]];
            break;
        }
        case kGameStateCredits:
        {
            if (!creditlayer){
                creditlayer = [CreditLayer node];
                [self addChild:creditlayer z:3];
            }
            creditlayer.scale = 0.0f;
            CCScaleTo *scale = [CCScaleTo actionWithDuration:1.2 scale:1.0f];
            
            [creditlayer runAction:[CCSequence actions:[CCShow action], [CCEaseElasticOut actionWithAction:scale], nil]];
            break;
        }
        default:
            break;
    }
    _state = state;
}

#pragma mark - MainMenuDelegate Methods

- (void)onShareTwitter:(id)sender
{
    [Helper shareTwitter];
}

- (void)onShareFacebook:(id)sender
{
    [Helper shareFacebook];
}

- (void)onStart:(id)sender
{
    self.state = kGameStatePlaying;
}

- (void)onAbout:(id)sender
{
    self.state = kGameStateCredits;
}

- (void)onHelp:(id)sender
{
    self.state = kGameStateTips;
}

#pragma mark - PauseDelegate Methods

- (void)onQuit:(id)sender
{
    self.state = kGameStateMenu;
}

- (void)onResume:(id)sender
{
    self.state = kGameStatePlaying;
}

#pragma mark - GameOverDelegate Methods

- (void)onAgain:(id)sender
{
    self.state = kGameStatePlaying;
}

- (void)onMenu:(id)sender
{
    self.state = kGameStateMenu;
}

#pragma mark - AdBannerDelegate

// This method is invoked when the banner has confirmation that an ad will be presented, but before the ad
// has loaded resources necessary for presentation.
- (void)bannerViewWillLoadAd:(ADBannerView *)banner __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_5_0)
{
    
}

// This method is invoked each time a banner loads a new advertisement. Once a banner has loaded an ad,
// it will display that ad until another ad is available. The delegate might implement this method if
// it wished to defer placing the banner in a view hierarchy until the banner has content to display.
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if ([Helper isShared]){
        if (playlayer.isGamePlaying && !playlayer.isAdshown) {
            [self showAd];
        }
        else if (playlayer.isAdshown){
            [UIView beginAnimations:@"flixad" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDuration:2.0];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                                   forView:adView
                                     cache:YES];
            [UIView commitAnimations];
        }
    }
}

// This method will be invoked when an error has occurred attempting to get advertisement content.
// The ADError enum lists the possible error codes.
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    //[self hideAd];
}

// This message will be sent when the user taps on the banner and some action is to be taken.
// Actions either display full screen content in a modal session or take the user to a different
// application. The delegate may return NO to block the action from taking place, but this
// should be avoided if possible because most advertisements pay significantly more when
// the action takes place and, over the longer term, repeatedly blocking actions will
// decrease the ad inventory available to the application. Applications may wish to pause video,
// audio, or other animated content while the advertisement's action executes.
- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner 
               willLeaveApplication:(BOOL)willLeave
{
    if (!willLeave && playlayer.isGamePlaying) {
        self.state = kGameStatePausing;
    }
    return YES;
}

// This message is sent when a modal action has completed and control is returned to the application.
// Games, media playback, and other activities that were paused in response to the beginning
// of the action should resume at this point.
- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    [self hideAd];
}
@end
