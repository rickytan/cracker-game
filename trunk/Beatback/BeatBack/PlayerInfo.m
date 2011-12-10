//
//  PlayerInfo.m
//  BeatBack
//
//  Created by STEVEN on 11-12-4.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "PlayerInfo.h"
#import "Global.h"

@implementation PlayerInfo

@synthesize topScore;
@synthesize crakerNumber,fuhuobiNumber,playerName;
@synthesize isMusicOn;

- (void) dealloc
{
    [playerName release];
    [super dealloc];
}
- (id)init
{
    self = [super init];
    [self loadPlayerInfo];
    return self;
}
- (void)openHero:(int)heroId
{
    heroState[heroId] = YES;
}
- (void)openMap:(int)mapId
{
    mapState[mapId] = YES;
}
- (void)addCrakers:(int)addNum
{
    crakerNumber += addNum;
}
- (void)addFuhuobiNumber:(int)addNum
{
    fuhuobiNumber +=addNum;
}
- (void)changePlayerNameTo:(NSString *) aplayerName{
    playerName = aplayerName;
}
-(int)mapStateAt:(int)k
{
    return mapState[k];
}
-(int)heroStateAt:(int)k
{
    return heroState[k];
}
#pragma mark -
#pragma mark PlayerInfo

- (void)loadPlayerInfo
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentPath = [documentsDirectory stringByAppendingPathComponent:@"playerInfo.info"];
    
	NSMutableData *playerInfoData;
    NSKeyedUnarchiver *decoder;
    
	playerInfoData = [NSData dataWithContentsOfFile:documentPath];
    if (playerInfoData) {
        decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:playerInfoData];
        
        playerName = [[decoder decodeObjectForKey:@"playerName"] retain];
        crakerNumber = [decoder decodeIntForKey:@"crakers"];
        fuhuobiNumber = [decoder decodeIntForKey:@"fuhuobi"];
        topScore = [decoder decodeIntForKey:@"topScore"];
        isMusicOn = [decoder decodeBoolForKey:@"isMusicOn"];
        
        mapState[0] = [decoder decodeIntForKey:@"map0"];
        mapState[1] = [decoder decodeIntForKey:@"map1"];
        mapState[2] = [decoder decodeIntForKey:@"map2"];
        mapState[3] = [decoder decodeIntForKey:@"map3"];
        mapState[4] = [decoder decodeIntForKey:@"map4"];
        mapState[5] = [decoder decodeIntForKey:@"map5"];
        mapState[6] = [decoder decodeIntForKey:@"map6"];
        
        heroState[0] = [decoder decodeIntForKey:@"hero0"];
        heroState[1] = [decoder decodeIntForKey:@"hero1"];
        heroState[2] = [decoder decodeIntForKey:@"hero2"];
        heroState[3] = [decoder decodeIntForKey:@"hero3"];
        heroState[4] = [decoder decodeIntForKey:@"hero4"];
        
        
        [decoder release];
    }
    else
    {
        playerName = [[NSString alloc] initWithString:@"Craker_Player"];
        crakerNumber = 5;
        fuhuobiNumber = 5;
        isMusicOn = YES;
        topScore = 0;
        mapState[0] =KGoods_Unlock;
        for (int k=1; k<7; k++) {
            mapState[k] = kGoods_Locked;
        }
        heroState[0] = KGoods_Unlock;
        for (int k = 1; k<5; k++) {
            mapState[k] = kGoods_Locked;
        }
        [self savePlayerInfo];
    }
    
	
}

- (void)savePlayerInfo {
    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *playerInfoPath = [documentsDirectory stringByAppendingPathComponent:@"playerInfo.info"];
    
    NSKeyedArchiver *encoder;
    
	NSMutableData *playerInfoData = [NSMutableData data];
	encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:playerInfoData];
	
	// Archive the entities
	[encoder encodeObject:playerName forKey:@"playerName"];
    [encoder encodeInt:crakerNumber forKey:@"crakers"];
    [encoder encodeInt:fuhuobiNumber forKey:@"fuhuobi"];
    [encoder encodeInt:topScore forKey:@"topScore"];
    [encoder encodeBool:isMusicOn forKey:@"isMusicOn"];
    
    [encoder encodeInt:mapState[0] forKey:@"map0"];
    [encoder encodeInt:mapState[1] forKey:@"map1"];
    [encoder encodeInt:mapState[2] forKey:@"map2"];
    [encoder encodeInt:mapState[3] forKey:@"map3"];
    [encoder encodeInt:mapState[4] forKey:@"map4"];
    [encoder encodeInt:mapState[5] forKey:@"map5"];
    [encoder encodeInt:mapState[6] forKey:@"map6"];
    
    [encoder encodeInt:heroState[0] forKey:@"hero0"];
    [encoder encodeInt:heroState[1] forKey:@"hero1"];
    [encoder encodeInt:heroState[2] forKey:@"hero2"];
    [encoder encodeInt:heroState[3] forKey:@"hero3"];
    [encoder encodeInt:heroState[4] forKey:@"hero4"];
	
	[encoder finishEncoding];
	[playerInfoData writeToFile:playerInfoPath atomically:YES];
	[encoder release];
}
@end
