//
//  PauseScene.h
//  Cracker
//
//  Created by Liu Pok on 11-12-17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"


@interface PauseScene : CCLayer {
    CCMenu *                menu;   // Weak assign
}
+ (id)scene;
- (void)resumePressed:(id)sender;
- (void)quitPressed:(id)sender;
@end
