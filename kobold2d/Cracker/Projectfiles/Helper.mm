//
//  Helper.m
//  Cracker
//
//  Created by Liu Pok on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "Helper.h"
#import "GameScene.h"
#import "SHKItem.h"
#import "SHKSharer.h"
#import "SHKFacebook.h"
#import "SHKTwitter.h"

static Helper *_sharedHelper = nil;
static SHKSharer *_sharer = nil;

@implementation Helper

+ (Helper*) sharedHelper
{
    if (!_sharedHelper){
        _sharedHelper = [[Helper alloc] init];
        
        [SHK flushOfflineQueue];
    }
    return _sharedHelper;
}

+ (id) alloc
{
    NSAssert(_sharedHelper == nil, @"Singleton can't allocate twice!!!");
    return [super alloc];
}

- (void)dealloc
{
    [super dealloc];
    _sharedHelper = nil;
}

- (id) init
{
    if ((self = [super init])) {
        //
    }
    return self;
}

+ (void)shareTwitter
{
    NSString * text = @"Hi! My friends. I'm playing Cracker on iPhone, and it's very funny";
    [_sharer release];
    
    SHKItem *item = [SHKItem text:text];
    _sharer = [[SHKTwitter shareItem:item] retain];
    _sharer.shareDelegate = [Helper sharedHelper];
}

+ (void)shareFacebook
{
    NSString * text = @"Hi! My friends. I'm playing Cracker on iPhone, and it's very funny";
    [_sharer release];
    
    SHKItem *item = [SHKItem text:text];
    _sharer = [[SHKFacebook shareItem:item] retain];
    _sharer.shareDelegate = [Helper sharedHelper];
}

- (void)sharerStartedSending:(SHKSharer *)sharer
{
    
}

- (void)sharerFinishedSending:(SHKSharer *)sharer
{
    [Helper setShared:YES];
}

- (void)sharer:(SHKSharer *)sharer 
failedWithError:(NSError *)error
 shouldRelogin:(BOOL)shouldRelogin
{
    
}

- (void)sharerCancelledSending:(SHKSharer *)sharer
{
    
}

+ (uint)bestScore
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask , YES); 
    NSLog(@"Get document path: %@",[paths objectAtIndex:0]);
    
    NSString *fileName=[[paths objectAtIndex:0] stringByAppendingPathComponent:@"data.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:fileName];
    return [(NSNumber*)[dic objectForKey:@"bestscore"] unsignedIntValue];
}

+ (void)saveBestScore:(uint)score;
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask , YES); 
    NSLog(@"Get document path: %@",[paths objectAtIndex:0]);
    
    NSString *fileName=[[paths objectAtIndex:0] stringByAppendingPathComponent:@"data.plist"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:fileName];
    
    [dic setValue:[NSNumber numberWithUnsignedInt:score]
           forKey:@"bestscore"];
    [dic writeToFile:fileName
          atomically:YES];
}

+ (BOOL)isShared
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask , YES); 
    NSLog(@"Get document path: %@",[paths objectAtIndex:0]);
    
    NSString *fileName=[[paths objectAtIndex:0] stringByAppendingPathComponent:@"data.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:fileName];
    return [(NSNumber*)[dic objectForKey:@"shared"] boolValue];
}

+ (void)setShared:(BOOL)shared
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask , YES); 
    NSLog(@"Get document path: %@",[paths objectAtIndex:0]);
    
    NSString *fileName=[[paths objectAtIndex:0] stringByAppendingPathComponent:@"data.plist"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithContentsOfFile:fileName];
    
    [dic setValue:[NSNumber numberWithBool:shared]
           forKey:@"shared"];
    [dic writeToFile:fileName
          atomically:YES];
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
