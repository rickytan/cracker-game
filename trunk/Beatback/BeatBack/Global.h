/*
 *  Global.h
 *  SLQTSOR
 *
 *  Created by Michael Daley on 19/04/2009.
 *  Copyright 2009 Michael Daley. All rights reserved.
 *
 */

#import <OpenGLES/ES1/gl.h>
#import "Structures.h"

#pragma mark -
#pragma mark Logging

//#define SLQLOG(...) NSLog(__VA_ARGS__);
#define SLQLOG(...)
#define DFB


#pragma mark -
#pragma mark Macros

//颜色值
#define Red 0
#define Blue 1
#define White 2
// 随机产生一个-1到1之间的数
#define RANDOM_MINUS_1_TO_1() ((random() / (GLfloat)0x3fffffff )-1.0f)

//随机产生一个0到1之间的数
#define RANDOM_0_TO_1() ((random() / (GLfloat)0x7fffffff ))

//随机产生1或0
#define RANDOM_0_or_1() (((int)random())%2)

// 角度到弧度的转化
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(__RADIANS) (__RADIANS / M_PI *180)

//讲X置于A和B之间
#define CLAMP(X, A, B) ((X < A) ? A : ((X > B) ? B : X))

#pragma mark -
#pragma mark Enumerators

// 场景状态
enum {
	kSceneState_Idle,
	//kSceneState_Credits,
	kSceneState_Loading,
	kSceneState_TransitionIn,
	kSceneState_TransitionOut_Game,
    kSceneState_TransitionOut_Store,
	//kSceneState_TransportingIn,
	//kSceneState_TransportingOut,
	kSceneState_Running,
	kSceneState_Paused,
    kSceneState_waiting,
	kSceneState_GameOver,
	kSceneState_SaveScore,
	kSceneState_GameCompleted
    //kSceneState_GameSpecial
};
// 实体状态
enum entityState {
	kEntityState_Idle=0,
	kEntityState_Dead=1,
	kEntityState_Dying=2,
	kEntityState_Alive=3,
	kEntityState_Appearing=4,
    kEntityState_Disappearing=5
};

enum entityAbnormalState{
    kEntityState_Freezing=6,
	kEntityState_LoseColor=7,
	kEntityState_Prison=8,
    kEntityState_LoseAttack=9,
    kEntityState_Dizzy=11,
    kEntityState_God=10

};

// 敌人类型
enum  {
    kEnermyType_SoliderNormal = 1,
    kEnermyType_SoliderJiguang =2,
    kEnermyType_SoliderLianFa = 3,
    kEnermyType_SoliderSanDan = 4,
    kEnermyType_SoliderWanQuDan = 5,
    kEnermyType_SoliderDaoDan = 6,
    
    kEnermyType_FuzhuDuqi = 11,
    kEnermyType_FuzhuBing = 12,
    kEnermyType_FuzhuYanseKongzhi = 13,
    kEnermyType_FuzhuZhadan = 14,
    kEnermyType_FuzhuFengzhu = 15,
    
    kEnermyType_Boss1 = 21,
    kEnermyType_Boss2 = 22,
    kEnermyType_Boss3 = 23,

    kEnermyType_Boss4 = 24,

    kEnermyType_Boss5 = 25,

    kEnermyType_Boss6 = 26,
    kEnermyType_Boss7 = 27,


    
};
//敌人附加状态
enum{
    kEnermySubType_Normal=0,
    kEnermySubType_ZhongZhuang=1,
    kEnermySubType_ShuangSe=2,
    kEnermySubType_KuaiSu=4

};

enum {
    kSendShape_SanDan=0,
    kSendShape_ZhiXian=1,
    kSendShape_Yici=2
};

// 子弹类型
enum {
	kBulletType_BulletNormal = 11,
//    kBulletType_BulletNormal_sandan = 12,
//    kBulletType_BulletNormal_zhixiandan = 13,
//    kBulletType_BulletNormal_QuanDan = 14,
//    kBulletType_BulletNormal_SanLianFa = 15,
    
    kBulletType_BulletJiGuang = 21,
   // kBulletType_BulletJiGuang_PaiXian = 22,
    kBulletType_BulletZhaDan2=22,
    kBulletType_BulletDaoDan = 31,
    kBulletType_BulletWanQuDan = 41,
    
    kBulletType_BulletDuQiDan   = 51,
    kBulletType_BulletBingKuai  = 61,
    kBulletType_BulletZhaDan    = 71,
    kBulletType_BulletFengzhu   = 81,
    kBulletType_BulletColorContr = 91,
    
    kBulletType_BulletHero = 99,
    kBulletType_Default=0

};

// 物品解锁状态
enum{
    kGoods_Locked=0,
    KGoods_Unlock=1,
    kGoods_Purchase=2,
    kGoods_Consume=3
};



#pragma mark -
#pragma mark Constants

// Name of the scenes
#define kGame_Scene_Name @"game"
#define kMenu_Scene_Name @"menu"

// Tile map details
#define kTile_Width 40
#define kTile_Height 40
#define kMax_Map_Width 200
#define kMax_Map_Height 200

// Spawning
#define kMax_Player_Distance 8

// Dying Emitter
#define kDyingEmitterDuration 0.15

#pragma mark -
#pragma mark Inline Functions

// 地图位置 到 屏幕位置 转化
static inline CGPoint tileMapPositionToPixelPosition(CGPoint tmp) {
	return CGPointMake((int)(tmp.x * kTile_Width), (int)(tmp.y * kTile_Height));
}

// Returns YES is the point provided is inside the closed poly defined by
// the vertices provided
static inline BOOL isPointInPoly(int sides, float *px, float *py, CGPoint point) {
	int sideCount;
	int totalSides = sides - 1;
	BOOL inside = NO;
	
	for (sideCount = 0; sideCount < sides; sideCount++) {
		if ((py[sideCount] < point.y && py[totalSides] >= point.y) ||
			(py[totalSides] < point.y && py[sideCount] >= point.y)) {
			if (px[sideCount] + (point.y - py[sideCount]) / (py[totalSides] - py[sideCount]) * (px[totalSides] - px[sideCount]) < point.x) {
				inside = !inside;
			}
		}
	}
	return inside;
}

// Returns YES if the rectangle and circle interset each other.  This include the circle being fulling inside
// the rectangle.
static inline BOOL RectIntersectsCircle(CGRect aRect, Circle aCircle) {
	
	float testX = aCircle.x;
	float testY = aCircle.y;
	
	if (testX < aRect.origin.x)
		testX = aRect.origin.x;
	if (testX > (aRect.origin.x + aRect.size.width))
		testX = (aRect.origin.x + aRect.size.width);
	if (testY < aRect.origin.y)
		testY = aRect.origin.y;
	if (testY > (aRect.origin.y + aRect.size.height))
		testY = (aRect.origin.y + aRect.size.height);
	
	return ((aCircle.x - testX) * (aCircle.x - testX) + (aCircle.y - testY) * (aCircle.y - testY)) < aCircle.radius * aCircle.radius;		
}

// Returns YES if the two circles provided intersect each other
static inline BOOL CircleIntersectsCircle(Circle aCircle1, Circle aCircle2) {
	float dx = aCircle2.x - aCircle1.x;
	float dy = aCircle2.y - aCircle1.y;
	float radii = aCircle1.radius + aCircle2.radius;
	
	return ((dx * dx) + (dy * dy)) < radii * radii;
}
static inline BOOL CircleContainsPoint(Circle aCircle, CGPoint aPoint)
{
    return ((aCircle.x - aPoint.x) * (aCircle.x - aPoint.x) + (aCircle.y - aPoint.y) * (aCircle.y - aPoint.y)) < aCircle.radius * aCircle.radius;
}

// 返回颜色
static const Color4f Color4fOnes = {1.0f, 1.0f, 1.0f, 1.0f};

// 比例
static const Vector2f Vector2fZero = {0.0f, 0.0f};

// 比例
static inline Scale2f Scale2fMake(float x, float y) {
    return (Scale2f) {x, y};
}

// 
static inline Vector2f Vector2fMake(GLfloat x, GLfloat y) {
	return (Vector2f) {x, y};
}
static inline Circle CircleMake(float x,float y, float radius)
{
    return (Circle){x,y,radius};
}

static inline CGPoint vm(GLfloat x, GLfloat y) {
	return (CGPoint) {x, y};
}

// Return a Color4f structure populated with the color values passed in
static inline Color4f Color4fMake(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) {
	return (Color4f) {red, green, blue, alpha};
}

// Return a Vector2f containing v multiplied by s
static inline Vector2f Vector2fMultiply(Vector2f v, GLfloat s) {
	return (Vector2f) {v.x * s, v.y * s};
}

// Return a Vector2f containing v1 + v2
static inline Vector2f Vector2fAdd(Vector2f v1, Vector2f v2) {
	return (Vector2f) {v1.x + v2.x, v1.y + v2.y};
}

// Return a Vector2f containing v1 - v2
static inline Vector2f Vector2fSub(Vector2f v1, Vector2f v2) {
	return (Vector2f) {v1.x - v2.x, v1.y - v2.y};
}

// Return the dot product of v1 and v2
static inline GLfloat Vector2fDot(Vector2f v1, Vector2f v2) {
	return (GLfloat) v1.x * v2.x + v1.y * v2.y;
}

// Return the length of the vector v
static inline GLfloat Vector2fLength(Vector2f v) {
	return (GLfloat) sqrtf(Vector2fDot(v, v));
}

// Return a Vector2f containing a normalized vector v
static inline Vector2f Vector2fNormalize(Vector2f v) {
	return Vector2fMultiply(v, 1.0f/Vector2fLength(v));
}

#pragma mark -
#pragma mark Entity Details Enermy
static inline EnermyDetails soliderJiGuangDetail(int aSubType)
{
    EnermyDetails tmp;
    tmp.angle=0.0f;
    tmp.speed=3.0f; 
    tmp.color=(aSubType&8)>>3;
    tmp.enegy=70;
    tmp.addScore=7;
    tmp.appearingTime=100.0f;
    tmp.bulletType=kBulletType_BulletJiGuang;
    tmp.enermyType=kEnermyType_SoliderJiguang;
    if (aSubType&1) {
        tmp.enegy+=70;
        tmp.addScore+=7;
        tmp.appearingTime+=15.0f;
    }//zhongzhuang
    
    if(aSubType&2)
    {
        tmp.addScore+=14;
        tmp.color=White;
    }//shuangse
    if(aSubType&4)
    {
        tmp.addScore+=4;
    }//kuaisu
        
    return tmp;
}

static inline EnermyDetails soliderNormalDetail(int aSubType)
{
    EnermyDetails tmp;
    tmp.angle=0.0f;
    tmp.speed=3.5f;
    tmp.color=(aSubType&8)>>3;
    tmp.enegy=60;
    tmp.addScore=6;
    tmp.appearingTime=100.0f;
    tmp.bulletType=kBulletType_BulletNormal;
    tmp.enermyType=kEnermyType_SoliderNormal;
    if (aSubType&1) {
        tmp.enegy+=60;
        tmp.addScore+=6;
        tmp.appearingTime+=100.0f;
    }//zhongzhuang
    
    if(aSubType&2)
    {
        tmp.addScore+=12;
        tmp.color=White;
    }//shuangse
    if(aSubType&4)
    {
        tmp.addScore+=3;
    }//kuaisu

    
    return tmp;
}
static inline EnermyDetails soliderLianFaDetail(int aSubType)
{
    EnermyDetails tmp;
    tmp.angle=40.0f;
    tmp.speed=3.0f; 
    tmp.color=(aSubType&8)>>3;
    tmp.enegy=100;
    tmp.addScore=10;
    tmp.appearingTime=100.0f;
    tmp.bulletType=kBulletType_BulletNormal;
    tmp.enermyType=kEnermyType_SoliderLianFa;
    
    if (aSubType&1) {
        tmp.enegy+=100;
        tmp.addScore+=10;
        tmp.appearingTime+=15.0f;
    }//zhongzhuang
    
    if(aSubType&2)
    {
        tmp.addScore+=20;
        tmp.color=White;
    }//shuangse
    if(aSubType&4)
    {
        tmp.addScore+=5;
    }//kuaisu

    
        return tmp;
}
static inline EnermyDetails soliderWanQuDan(int aSubType)
{
    EnermyDetails tmp;
    tmp.angle=0.0f;
    tmp.speed=3.0f; 
    tmp.color=(aSubType&8)>>3;
    tmp.enegy=20;
    tmp.addScore=3;
    tmp.appearingTime=100.0f;
    tmp.bulletType=kBulletType_BulletWanQuDan;
    tmp.enermyType=kEnermyType_SoliderWanQuDan;
   
    if (aSubType&1) {
        tmp.enegy+=20;
        tmp.addScore+=3;
        tmp.appearingTime+=15.0f;
    }//zhongzhuang
    
    if(aSubType&2)
    {
        tmp.addScore+=6;
        tmp.color=White;
    }//shuangse
    if(aSubType&4)
    {
        tmp.addScore+=2;
    }//kuaisu

    
    return tmp;
}
static inline EnermyDetails soliderSanDanDetail(int aSubType)
{
    EnermyDetails tmp;
    tmp.angle=0.0f;
    tmp.speed=3.0f; 
    tmp.color=(aSubType&8)>>3;
    tmp.enegy=80;
    tmp.addScore=8;
    tmp.appearingTime=100.0f;

    tmp.bulletType=kBulletType_BulletNormal;
    tmp.enermyType=kEnermyType_SoliderSanDan;

    if (aSubType&1) {
        tmp.enegy+=80;
        tmp.addScore+=8;
        tmp.appearingTime+=15.0f;
    }//zhongzhuang
    
    if(aSubType&2)
    {
        tmp.addScore+=16;
        tmp.color=White;
    }//shuangse
    if(aSubType&4)
    {
        tmp.addScore+=4;
    }//kuaisu
    
    return tmp;
}

static inline EnermyDetails soliderDaoDanDetail(int aSubType)
{
    EnermyDetails tmp;
    tmp.angle=0.0f;
    tmp.speed=3.0f;
    tmp.color=White;
    tmp.enegy=40;
    tmp.addScore=0;
    tmp.appearingTime=8.0f;
    
    tmp.bulletType=kBulletType_BulletDaoDan;
    tmp.enermyType=kEnermyType_SoliderDaoDan;
    
    if (aSubType&1) {
        
    }//zhongzhuang
    
    if(aSubType&2)
    {
    }//shuangse
    if(aSubType&4)
    {
        
    }//kuaisu
    return tmp;
}
static inline EnermyDetails soliderFengZhuDetail(int aSubType)
{
    EnermyDetails tmp;
    tmp.angle=0.0f;
    tmp.speed=3.0f;
    tmp.color=White;
    tmp.enegy=10;
    tmp.addScore=0;
    tmp.appearingTime=8.0f;
    tmp.bulletType=kBulletType_BulletFengzhu;
    tmp.enermyType=kEnermyType_FuzhuFengzhu;
    if (aSubType&1) {
        
    }//zhongzhuang
    
    if(aSubType&2)
    {
    }//shuangse
    if(aSubType&4)
    {
        
    }//kuaisu
    
    return tmp;
}
static inline EnermyDetails soliderBingDetail(int aSubType)
{
    EnermyDetails tmp;
    tmp.angle=0.0f;
    tmp.speed=3.0f;
    tmp.color=White;
    tmp.enegy=10;
    tmp.addScore=0;
    tmp.appearingTime=8.0f;
    tmp.bulletType=kBulletType_BulletBingKuai;
    tmp.enermyType=kEnermyType_FuzhuBing;
  
    if (aSubType&1) {
        
    }//zhongzhuang
    
    if(aSubType&2)
    {
    }//shuangse
    if(aSubType&4)
    {
        
    }//kuaisu
    

    
    return tmp;
}


static inline EnermyDetails soliderDuQiDetail(int aSubType)
{
    EnermyDetails tmp;
    tmp.angle=0.0f;
    tmp.speed=3.0f;
    tmp.color=White;
    tmp.enegy=10;
    tmp.addScore=0;
    tmp.appearingTime=8.0f;
    tmp.bulletType=kBulletType_BulletDuQiDan;
    tmp.enermyType=kEnermyType_FuzhuDuqi;
   
    if (aSubType&1) {
        
    }//zhongzhuang
    
    if(aSubType&2)
    {
    }//shuangse
    if(aSubType&4)
    {
        
    }//kuaisu

    
    return tmp;
}
static inline EnermyDetails soliderZhaDanDetail(int aSubType)
{
    EnermyDetails tmp;
    tmp.angle=0.0f;
    tmp.speed=3.0f;
    tmp.color=White;
    tmp.enegy=10;
    tmp.addScore=0;
    tmp.appearingTime=15.0f;
    tmp.bulletType=kBulletType_BulletZhaDan;
    tmp.enermyType=kEnermyType_FuzhuZhadan;
       
    if (aSubType&1) {
        
    }//zhongzhuang
    
    if(aSubType&2)
    {
    }//shuangse
    if(aSubType&4)
    {
        tmp.speed+=1;
    }//kuaisu

    return tmp;
}


static inline EnermyDetails soliderColorContrDetail(int aSubType)
{
    EnermyDetails tmp;
    tmp.angle=0.0f;
    tmp.speed=3.0f;
    tmp.color=White;
    tmp.enegy=10;
    tmp.addScore=0;
    tmp.appearingTime=5.0f;
    tmp.bulletType=kBulletType_BulletColorContr;
    tmp.enermyType=kEnermyType_FuzhuYanseKongzhi;
    
    if (aSubType&1) {
        
    }//zhongzhuang
    
    if(aSubType&2)
    {
    }//shuangse
    if(aSubType&4)
    {
        
    }//kuaisu
    
    return tmp;
}



static inline EnermyDetails Boss1Detail()
{
    EnermyDetails tmp;
    tmp.angle=0.0f;
    tmp.speed=3.0f;
    tmp.color=Red;
    tmp.enegy=10;
    tmp.addScore=50;
     tmp.appearingTime=1200.0f;
    tmp.bulletType=kBulletType_BulletNormal;
    tmp.enermyType=kEnermyType_Boss1;
    
    return tmp;
}







#pragma mark -
#pragma mark Entity Details Bullet



static inline BulletDetails ColorContrBulletDetail()
{
    BulletDetails tmp;
    tmp.damage=0.0f;
    tmp.appearingTime=15.0f;
    
    tmp.bulletType=kBulletType_BulletColorContr;

    return  tmp;
}

static inline BulletDetails FengZhuBulletDetail()
{
    BulletDetails tmp;
    tmp.damage=0.0f;
    tmp.speed=1.5f;
    tmp.appearingTime=15.0f;
    tmp.bulletType=kBulletType_BulletFengzhu;
    return  tmp;
}

static inline BulletDetails ZhaDanBulletDetail()
{
    BulletDetails tmp;
    tmp.damage=0.0f;
    tmp.speed=1.0f;
    tmp.appearingTime=15.0f;
    tmp.bulletType=kBulletType_BulletZhaDan;
    return  tmp;
}
static inline BulletDetails ZhaDan2BulletDetail()
{
    BulletDetails tmp;
    tmp.damage=0.0f;
    tmp.speed=1.3f;
    tmp.appearingTime=15.0f;
    tmp.bulletType=kBulletType_BulletZhaDan2;
    return  tmp;
}
static inline BulletDetails daoDanBulletDetail()
{
    BulletDetails tmp;
    tmp.damage=5.0f;
    tmp.speed=1.0f;
    tmp.appearingTime=6.0f;
    tmp.bulletType=kBulletType_BulletDaoDan;
    
    return  tmp;
}

static inline BulletDetails BingBulletDetail()
{
    BulletDetails tmp;
    tmp.damage=0.0f;
    
    tmp.speed=1.5f;
    
    tmp.appearingTime=15.0f;
    
    tmp.bulletType=kBulletType_BulletBingKuai;
    return  tmp;
}
static inline BulletDetails DuQiBulletDetail()
{
    BulletDetails tmp;
    tmp.damage=0.0f;
    tmp.speed=1.5f;
    tmp.appearingTime=15.0f;
    
    tmp.bulletType=kBulletType_BulletDuQiDan;
    
    return  tmp;
}

static inline BulletDetails JiGuangBulletDetail()
{
    BulletDetails tmp;
    tmp.damage=0.0f;
    tmp.speed=6.0f;
    tmp.appearingTime=15.0f;
    tmp.bulletType=kBulletType_BulletJiGuang;
    return  tmp;
}

static inline BulletDetails WanQuDanBulletDetail()
{
    BulletDetails tmp;
    tmp.damage=0.0f;
    tmp.speed=2.7f;
    tmp.appearingTime=15.0f;
    tmp.bulletType=kBulletType_BulletWanQuDan;
    return  tmp;
}




static inline BulletDetails normalBulletDetail()
{
    BulletDetails tmp;
    tmp.damage=10.0f;
    tmp.speed=1.3f;
    tmp.appearingTime=15.0f;    
    tmp.bulletType=kBulletType_BulletNormal;
    
    return  tmp;
}


static inline BulletDetails heroBulletDetail()
{
    BulletDetails tmp;
    tmp.damage=10.0f;
    tmp.speed=10.0f;
    tmp.appearingTime=15.0f;
    tmp.bulletType=kBulletType_BulletHero;
    return  tmp;
}


//more and more 

//more and more 
