//
//  GameScene.m
//  Cracker
//
//  Created by  on 11-12-5.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "MenuScene.h"
#import "SimpleAudioEngine.h"
#import "PauseScene.h"


@implementation GameScene

- (id)init
{
    if ((self = [super init])){

        
        //[[CCDirector sharedDirector] enableRetinaDisplay:YES];
        
        playlayer = [PlayLayer node];
        pauselayer = [PauseScene node];
        
        menulayer = [MainMenu node];

        CCLayerMultiplex *layer = [CCLayerMultiplex layerWithLayers:menulayer,playlayer,pauselayer,nil];
        
        [self addChild:layer];
    }
    return self;
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
    
    [UIView beginAnimations:@"AdViewAppear" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.35];
    
    adView.frame = CGRectMake(0, -50, 320, 50);
    
    [UIView commitAnimations];
}

- (void)onEnter
{
    [super onEnter];
    
    adView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    
    adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
    [[CCDirector sharedDirector].openGLView addSubview:adView];
    adView.delegate = self;
    adView.hidden = YES;
}

- (void)onExit
{
    [super onExit];
    
    [adView removeFromSuperview];
    [adView release];
    adView = nil;
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
    if ([playlayer isRunning]) {
        [self showAd];
    }
}

// This method will be invoked when an error has occurred attempting to get advertisement content.
// The ADError enum lists the possible error codes.
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [self hideAd];
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
    if (!willLeave && playlayer.isRunning) {
        [playlayer pauseSchedulerAndActions];
    }
    return YES;
}

// This message is sent when a modal action has completed and control is returned to the application.
// Games, media playback, and other activities that were paused in response to the beginning
// of the action should resume at this point.
- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    [playlayer resumeSchedulerAndActions];
    [self hideAd];
}
@end
