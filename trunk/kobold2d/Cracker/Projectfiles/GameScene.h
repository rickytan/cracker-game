//
//  GameScene.h
//  Cracker
//
//  Created by  on 11-12-5.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CCScene.h"
#import "PlayLayer.h"
#import <iAd/iAd.h>

@interface GameScene : CCScene <ADBannerViewDelegate> {
    ADBannerView *          adView;
    PlayLayer *             playlayer;  // Weak assign
}

- (void)showAd;
- (void)hideAd;
@end
