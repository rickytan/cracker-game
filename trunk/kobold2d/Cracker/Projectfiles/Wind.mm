//
//  Wind.m
//  Cracker
//
//  Created by ricky on 11-12-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "Wind.h"


@implementation Wind

- (void)blow:(b2Body*)body 
   withForce:(b2Vec2)force
{
    body->ApplyForceToCenter(force);
}
@end
