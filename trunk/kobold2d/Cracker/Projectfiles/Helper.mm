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
    NSString * text = @"Hi! My friends. I'm playing \">20s?\" on iPhone, join me!";
    [_sharer release];
    
    SHKItem *item = [SHKItem text:text];
    _sharer = [[SHKTwitter shareItem:item] retain];
    _sharer.shareDelegate = [Helper sharedHelper];
}

+ (void)shareFacebook
{
    NSString * text = @"Hi! My friends. I'm playing \">20s?\" on iPhone, join me!";
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
    [_sharer dismissViewControllerAnimated:YES
                                completion:NO];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[sharer title]
                                                    message:@"Share succeeded!Now you have disabled the Ad and pushed the wall back"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)sharer:(SHKSharer *)sharer 
failedWithError:(NSError *)error
 shouldRelogin:(BOOL)shouldRelogin
{
#ifdef DEBUG
    NSLog(@"%@",error);
#endif
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ Error!",[sharer title]]
                                                    message:[error description]
                                                   delegate:nil
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)sharerCancelledSending:(SHKSharer *)sharer
{
    [_sharer dismissViewControllerAnimated:YES
                                completion:NO];
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
    if (!dic)
        dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
               [NSNumber numberWithUnsignedInt:0],@"bestscore",
               [NSNumber numberWithBool:NO], @"shared", nil];
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
    if (!dic)
        dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
               [NSNumber numberWithUnsignedInt:0],@"bestscore",
               [NSNumber numberWithBool:NO], @"shared", nil];
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

+ (void)initGameCenter
{
    KKGameKitHelper *gameCenter = [KKGameKitHelper sharedGameKitHelper];
    gameCenter.delegate = [Helper sharedHelper];
    if (gameCenter.isGameCenterAvailable){
        [gameCenter authenticateLocalPlayer];
    }
}

/** Called when local player was authenticated or logged off. */
-(void) onLocalPlayerAuthenticationChanged
{
    
}

/** Called when friend list was received from Game Center. */
-(void) onFriendListReceived:(NSArray*)friends
{
    
}
/** Called when player info was received from Game Center. */
-(void) onPlayerInfoReceived:(NSArray*)players
{
    
}

/** Called when scores where submitted. This can fail, so check for success. */
-(void) onScoresSubmitted:(bool)success
{
    
}
/** Called when scores were received from Game Center. */
-(void) onScoresReceived:(NSArray*)scores
{
    
}

/** Called when achievement was reported to Game Center. */
-(void) onAchievementReported:(GKAchievement*)achievement
{
    
}
/** Called when achievement list was received from Game Center. */
-(void) onAchievementsLoaded:(NSDictionary*)achievements
{
    
}
/** Called to indicate whether the reset achievements command was successful. */
-(void) onResetAchievements:(bool)success
{
    
}

/** Called when a match was found. */
-(void) onMatchFound:(GKMatch*)match
{
    
}
/** Called to indicate whether adding players to a match was successful. */
-(void) onPlayersAddedToMatch:(bool)success
{
    
}
/** Called when matchmaking activity was received from Game Center. */
-(void) onReceivedMatchmakingActivity:(NSInteger)activity
{
    
}

/** Called when a player connected to the match. */
-(void) onPlayerConnected:(NSString*)playerID
{
    
}
/** Called when a player disconnected from a match. */
-(void) onPlayerDisconnected:(NSString*)playerID
{
    
}
/** Called when the match begins. */
-(void) onStartMatch
{
    
}
/** Called whenever data from another player was received. */
-(void) onReceivedData:(NSData*)data fromPlayer:(NSString*)playerID
{
    
}

/** Called when the matchmaking view was closed. */
-(void) onMatchmakingViewDismissed
{
    
}
/** Called for any generic error in the matchmaking view. */
-(void) onMatchmakingViewError
{
    
}
/** Called when the leaderboard view was closed. */
-(void) onLeaderboardViewDismissed
{
    
}
/** Called when the achievements view was closed. */
-(void) onAchievementsViewDismissed
{
    
}

@end
