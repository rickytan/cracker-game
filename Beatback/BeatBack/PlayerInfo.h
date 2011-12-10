//
//  PlayerInfo.h
//  BeatBack
//
//  Created by STEVEN on 11-12-4.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayerInfo : NSObject
{
	int crakerNumber;	//饼干币数
    int fuhuobiNumber;
	NSString *playerName;	// Players name
    int mapState[7];
    int heroState[5];
    int topScore;
    BOOL isMusicOn;
}
@property (nonatomic,assign) int topScore;
@property (nonatomic,assign)int crakerNumber,fuhuobiNumber;
@property (nonatomic,retain) NSString *playerName;
@property BOOL isMusicOn;
- (id)init;
- (void)openHero:(int)heroId;
- (void)openMap:(int)mapId;
- (void)addCrakers:(int)addNum;
- (void)addFuhuobiNumber:(int)addNum;
- (void)changePlayerNameTo:(NSString *)aplayerName;
- (void)loadPlayerInfo;
- (void)savePlayerInfo;
-(int)mapStateAt:(int) k;
-(int)heroStateAt:(int) k;
@end
