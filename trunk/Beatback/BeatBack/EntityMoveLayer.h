//
//  EntityMoveLayer.h
//  BeatBack
//
//  Created by STEVEN on 11-12-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Hero.h"

@interface EntityMoveLayer : CCLayer {
    Hero* hero;
    float touchOffsetX,touchOffsetY; 
}

@end
