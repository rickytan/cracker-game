//
//  PauseScene.h
//  Cracker
//
//  Created by Liu Pok on 11-12-17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@protocol PauseDelegate <NSObject>

@required
- (void)onResume:(id)sender;
- (void)onQuit:(id)sender;

@end

@interface PauseScene : CCLayerColor <CCTargetedTouchDelegate>{
    CCMenu *                menu;   // Weak assign
}
@property (nonatomic, assign) id<PauseDelegate> delegate;

+ (id)scene;
- (void)modal;
- (void)dismiss;
- (void)resumePressed:(id)sender;
- (void)quitPressed:(id)sender;
@end
