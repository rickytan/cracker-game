//
//  Helper.h
//  Cracker
//
//  Created by Liu Pok on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box2D.h"

#define PTM_RATIO 96.0f

@interface Helper : NSObject

+ (void)shareFacebook;
+ (void)shareTwitter;
+ (b2Vec2)toMeters:(CGPoint)point;
+ (CGPoint)toPixels:(b2Vec2)vec;
@end
