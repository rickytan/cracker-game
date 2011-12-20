//
//  GameScene.h
//  Cracker
//
//  Created by  on 11-12-5.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "PlayLayer.h"
#import <iAd/iAd.h>


enum {
    kPlayLayer
};

@interface GameScene : CCScene <ADBannerViewDelegate> {
    ADBannerView *          adView;
    PlayLayer *             playlayer;  // Weak assign
}
@property (nonatomic, readonly) uint score;

- (void)showAd;
- (void)hideAd;
@end
