//
//  PauseScene.m
//  Cracker
//
//  Created by Liu Pok on 11-12-17.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "PauseScene.h"

@implementation PauseScene

+ (id)scene
{
    return [PauseScene nodeWithScene];
}
- (id)init
{
    if ((self = [super init])){
        
        CCMenuItemImage *resumeItem = [CCMenuItemImage itemFromNormalImage:@"continue.png"
                                                             selectedImage:@"continue.png"
                                                                    target:self
                                                                  selector:@selector(resumePressed:)];
        CCMenuItemImage *quit = [CCMenuItemImage itemFromNormalImage:@"blueArrow.png"
                                                       selectedImage:@"blackArrow.png"
                                                              target:self
                                                            selector:@selector(quitPressed:)];
        menu = [CCMenu menuWithItems:resumeItem, quit, nil];
        [menu alignItemsHorizontallyWithPadding:5];
        [self addChild:menu];
        
        
        //[self scheduleUpdate];
    }
    return self;
}

- (void)modal
{
    
}

- (void)resumePressed:(id)sender
{
    CCLayerMultiplex *layer = (CCLayerMultiplex*)self.parent;
    [layer switchTo:1];
    
}

- (void)quitPressed:(id)sender
{
    CCLayerMultiplex *layer = (CCLayerMultiplex*)self.parent;
    [layer switchTo:0];
}
@end
