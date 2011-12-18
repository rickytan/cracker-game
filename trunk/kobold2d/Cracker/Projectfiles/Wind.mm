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

- (void)randomDirection;

- (void)level1;
- (void)level2;
- (void)level3;
- (void)level4;
- (void)level5;
- (void)level6;
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
        [self level1];
        [self pauseSchedulerAndActions];
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
    [self resumeSchedulerAndActions];
}

- (void)stopBlow
{
    [self pauseSchedulerAndActions];
    [[CCScheduler sharedScheduler] pauseTarget:self];
}


- (void)level1
{
    CCDelayTime *d1 = [CCDelayTime actionWithDuration:2.5];
    CCCallFunc *c1 = [CCCallFunc actionWithTarget:self
                                         selector:@selector(randomDirection)];
    CCRepeat *r = [CCRepeat actionWithAction:[CCSequence actions:d1, c1, nil] times:2];
    CCCallFunc *next = [CCCallFunc actionWithTarget:self selector:@selector(level2)];
    
    [self runAction:[CCSequence actions:r, next, nil]];
}

- (void)level2
{
    CCDelayTime *d1 = [CCDelayTime actionWithDuration:2.0];
    CCCallFunc *c1 = [CCCallFunc actionWithTarget:self
                                         selector:@selector(randomDirection)];
    CCRepeat *r = [CCRepeat actionWithAction:[CCSequence actions:d1, c1, nil] times:3];
    CCCallFunc *next = [CCCallFunc actionWithTarget:self selector:@selector(level3)];
    
    [self runAction:[CCSequence actions:r, next, nil]];
}

- (void)level3
{
    CCDelayTime *d1 = [CCDelayTime actionWithDuration:1.5];
    CCCallFunc *c1 = [CCCallFunc actionWithTarget:self
                                         selector:@selector(randomDirection)];
    CCRepeat *r = [CCRepeat actionWithAction:[CCSequence actions:d1, c1, nil] times:4];
    CCCallFunc *next = [CCCallFunc actionWithTarget:self selector:@selector(level4)];
    
    [self runAction:[CCSequence actions:r, next, nil]];
}

- (void)level4
{
    CCDelayTime *d1 = [CCDelayTime actionWithDuration:1.0];
    CCCallFunc *c1 = [CCCallFunc actionWithTarget:self
                                         selector:@selector(randomDirection)];
    CCRepeat *r = [CCRepeat actionWithAction:[CCSequence actions:d1, c1, nil] times:5];
    CCCallFunc *next = [CCCallFunc actionWithTarget:self selector:@selector(level5)];
    
    [self runAction:[CCSequence actions:r, next, nil]];
}

- (void)level5
{
    CCDelayTime *d1 = [CCDelayTime actionWithDuration:1.0];
    CCCallFunc *c1 = [CCCallFunc actionWithTarget:self
                                         selector:@selector(randomDirection)];
    CCCallFunc *c2 = [CCCallFunc actionWithTarget:self selector:@selector(increase)];
    CCRepeat *r = [CCRepeat actionWithAction:[CCSequence actions:d1, c1, c2, nil] times:5];
    CCCallFunc *next = [CCCallFunc actionWithTarget:self selector:@selector(level6)];
    
    [self runAction:[CCSequence actions:r, next, nil]];
}

- (void)level6
{
    CCDelayTime *d1 = [CCDelayTime actionWithDuration:0.6];
    CCCallFunc *c1 = [CCCallFunc actionWithTarget:self
                                         selector:@selector(randomDirection)];
    
    CCRepeatForever *r = [CCRepeatForever actionWithAction:[CCSequence actions:d1, c1, nil]];
    
    [self runAction:r];
}

- (void)randomDirection
{
    CGFloat angle = CCRANDOM_MINUS1_1()*M_PI;
    self.angle = angle;
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
