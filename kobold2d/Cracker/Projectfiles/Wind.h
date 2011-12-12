//
//  Wind.h
//  Cracker
//
//  Created by ricky on 11-12-11.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Box2D.h"


@interface Wind : NSObject {
    b2Rot                   direction;
}
- (void)blow:(b2Body*)body;

@property (nonatomic, assign) CGFloat force;
@property (nonatomic, assign) CGFloat angle;
@end
