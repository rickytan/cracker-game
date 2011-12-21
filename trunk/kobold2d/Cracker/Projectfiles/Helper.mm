//
//  Helper.m
//  Cracker
//
//  Created by Liu Pok on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "Helper.h"
#import "Box2D.h"

@implementation Helper

+ (void)shareTwitter
{
    
}

+ (void)shareFacebook
{
    
}

// convenience method to convert a CGPoint to a b2Vec2
+ (b2Vec2) toMeters:(CGPoint)point
{
	return b2Vec2(point.x / PTM_RATIO, point.y / PTM_RATIO);
}

// convenience method to convert a b2Vec2 to a CGPoint
+ (CGPoint) toPixels:(b2Vec2)vec
{
	return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}
@end
