//
//  Hero.m
//  BeatBack
//
//  Created by STEVEN on 11-12-4.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "Hero.h"
#import "GameController.h"

static NSString* HERO_NAME[2][10]={{@"hero_1.png" },{}};

@implementation Hero
-(id)initWithHeroID:(int)heroID
{
   
    if (self=[super initWithFile:HERO_NAME[heroID][0]]) {
           
        
        [self schedule:@selector(update:) interval:0.03];
    }
    return self;
}

-(void)update:(ccTime)aDelta
{
    
  

}
@end
