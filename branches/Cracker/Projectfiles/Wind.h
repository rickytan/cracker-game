//
//  Wind.h
//  Cracker
//
//  Created by ricky on 11-12-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box2D.h"
#import <list>

using namespace std;

typedef list<b2Body*>   bodyList;

@interface Wind : CCNode {
    b2Rot                   direction;

    bodyList                objects;
    
    ccTime                  _elastic;
    ccTime                  _duration;
    BOOL                    _repeat;
}


@property (nonatomic, assign) CGFloat force;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, assign) BOOL repeat;

- (id)init;
- (id)initWithForce:(CGFloat)force andAngle:(CGFloat)angle repeat:(BOOL)repeat;
- (void)blow:(b2Body*)body;
- (void)remove:(b2Body*)body;
- (void)removeAll;
- (void)increase;
- (void)increaseBy:(CGFloat)delta;
- (void)decrease;
- (void)decreaseBy:(CGFloat)delta;
- (void)startBlow;
- (void)stopBlow;
- (void)level0;
@end
