//
//  Hero.h
//  BeatBack
//
//  Created by STEVEN on 11-12-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Hero : CCSprite {
    
}
-(id)initWithHeroID:(int)heroID;
-(void)update:(ccTime)aDelta;
@end
