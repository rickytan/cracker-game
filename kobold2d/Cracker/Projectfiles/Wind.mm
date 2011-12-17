//
//  Wind.m
//  Cracker
//
//  Created by ricky on 11-12-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "Wind.h"

@interface Wind (Private)
- (void)update:(ccTime)dt;
- (void)apply:(ccTime)delta;
@end

@implementation Wind

@synthesize force = _force,angle = _angle,repeat = _repeat;

- (id)init
{
    if ((self = [super init])){
        direction.SetIdentity();
        _force = 0;
        objects.clear();
        _elastic = 0.0f;
        _duration = 2.0f;
        _repeat = NO;
        [[CCScheduler sharedScheduler] scheduleUpdateForTarget:self
                                                      priority:0 paused:YES];
    }
    return self;
}

- (id)initWithForce:(CGFloat)force andAngle:(CGFloat)angle repeat:(BOOL)repeat;
{
    if ((self = [self init])){
        self.force = force;
        self.angle = angle;
        self.repeat = repeat;
    }
    return self;
}
- (void)dealloc
{
#ifdef KK_ARC_ENABLED
    [super dealloc];
#endif
}

- (void)blow:(b2Body*)body 
{
    objects.push_back(body);
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
- (void)remove:(b2Body*)body
{
    objects.remove(body);
}
- (void)removeAll
{
    objects.clear();
}
- (void)increase
{
    [self increaseBy:0.002*expf(_force)];
}
- (void)increaseBy:(CGFloat)delta
{
    _force += delta;
}
- (void)decrease
{
    [self decreaseBy:0.002*expf(_force) - 0.002];
}
- (void)decreaseBy:(CGFloat)delta
{
    _force -= delta;
    if (_force < 0.0f)
        _force = 0.0f;
}
- (void)startBlow
{
    [[CCScheduler sharedScheduler] resumeTarget:self];
}

- (void)stopBlow
{
    [[CCScheduler sharedScheduler] pauseTarget:self];
}

- (void)step:(ccTime)dt
{
    
}

- (void)apply:(ccTime)delta
{
    for (bodyList::iterator it = objects.begin(); it != objects.end(); ++it) {
        CGFloat f = _force * sinf(M_PI*delta);
        (*it)->ApplyForceToCenter(f*b2Vec2(direction.c,direction.s));
    }
}
- (void)update:(ccTime)dt
{
    _elastic += dt;
    if (_elastic >= _duration && _repeat){
        _elastic -= _duration;
    }
    else if (_elastic >= _duration){
        [self stopBlow];
        return;
    }
    
    [self apply:MIN(1, _elastic/_duration)];
}
@end
