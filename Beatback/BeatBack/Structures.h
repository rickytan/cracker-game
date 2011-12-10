/*
 *  Structures.h
 *  SLQTSOR
 *
 *  Created by Mike Daley on 22/09/2009.
 *  Copyright 2009 Michael Daley. All rights reserved.
 *
 */

#import <OpenGLES/ES1/gl.h>



#pragma mark -
#pragma mark Type structures

// Structure that defines the elements which make up a color
typedef struct {
	float red;
	float green;
	float blue;
	float alpha;
} Color4f;

// 矢量
typedef struct {
	GLfloat x;
	GLfloat y;
} Vector2f;

// 比例
typedef struct {
    float x;
    float y;
} Scale2f;




typedef struct {
	int x;
	int y;
} Position;

// Structure used to hold details of a circle
typedef struct {
	float x;
	float y;
	float radius;
} Circle;

typedef struct{
    float damage;
    int bulletType;
    CGPoint location;
    CGPoint aimPosition;
    float speed;
    float angle;
    int color;
    float appearingTime;
    NSString *dyingEmitter;
    NSString *appearEmitter;
    NSString *moveEmitter;
    NSString *image;
    
}BulletDetails;


typedef struct{
    CGPoint location;
    float speed;
    float angle;
    int color;
    int addScore;
    float enegy;
    int enermyType;
    int enermySubType;
    int bulletType;
    float appearingTime;
    NSString *dyingEmitter;
    NSString *appearEmitter;
    NSString *moveEmitter;
    NSString *image;
    
}EnermyDetails;

typedef struct{
    int enermyType;
    int enermySubType;
}EneryInList;
