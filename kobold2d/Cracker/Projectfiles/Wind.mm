//
//  Wind.m
//  Cracker
//
//  Created by ricky on 11-12-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "Wind.h"


@implementation Wind

@synthesize force = _force,angle = _angle;

- (id)init
{
    if ((self = [super init])){
        direction.SetIdentity();
        _force = 0;
    }
    return self;
}

- (void)blow:(b2Body*)body 
   withForce:(b2Vec2)force
{
    body->ApplyForceToCenter(force);
}

- (void)blow:(b2Body *)body
{
    body->ApplyForceToCenter(b2Vec2(_force*direction.c,_force*direction.s));
}
- (void)setAngle:(CGFloat)angle
{
    _angle = angle;
    direction.Set(_angle);
}
- (void)setForce:(CGFloat)force
{
    b2Assert(force >= 0);
    _force = force;
}
@end
