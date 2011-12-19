//
//  MainMenu.h
//  Cracker
//
//  Created by  on 11-12-5.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
//#import "GameScene.h"

@protocol MainMenuButtonDelegate <NSObject>

@required
- (void)onStart:(id)sender;
- (void)onHelp:(id)sender;
- (void)onAbout:(id)sender;
- (void)onShareFacebook:(id)sender;
- (void)onShareTwitter:(id)sender;

@end

@interface MainMenu : CCLayer {
    b2World *                   world;
    BOOL                        worldStatic;

    CCMenu *                    menu;       // Weak assign
  	GLESDebugDraw *             debugDraw;     
}
@property (nonatomic, assign) id<MainMenuButtonDelegate> delegate;
- (id)init;

- (void)onStart:(id)sender;
- (void)onHelp:(id)sender;
- (void)onAbout:(id)sender;
- (void)onShareFacebook:(id)sender;
- (void)onShareTwitter:(id)sender;
@end
