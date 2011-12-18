//
//  PlayLayer.h
//  Cracker
//
//  Created by  on 11-12-6.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CCLayer.h"
#import "Box2D.h"
#import "CC3Node.h"
#import "Ball3DLayer.h"
#import "ContactListener.h"
#import "Wind.h"

@interface PlayLayer : CCLayer {
    b2World *               world;
    b2Body *                topBoundBody;
    ContactListener *       contact;
    b2Body *                theBall;    // Weak assign
    
    Ball3DLayer *           ball3DLayer;// Weak assign
    NSTimer *               timer;
    Wind *                  wind;
    uint                    score;
    CCLabelAtlas *          scoreLabel;
    NSTimer *               scoreAddTimer;

    
    BOOL                    isAdShown;
}

@property (nonatomic, assign) uint score;
@end
