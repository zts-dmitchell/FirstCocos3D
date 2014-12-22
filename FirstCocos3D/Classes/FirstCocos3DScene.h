/**
 *  FirstCocos3DScene.h
 *  FirstCocos3D
 *
 *  Created by David Mitchell on 9/6/14.
 *  Copyright David Mitchell 2014. All rights reserved.
 */


#import "CC3Scene.h"
#import "CC3ResourceNode.h"
#import "FirstCocos3DLayer.h"
#import "Filters.h"
#import "Camera.h"
#import "PaintBooth.h"

@import CoreMotion;

/** A sample application-specific CC3Scene subclass.*/
@interface FirstCocos3DScene : CC3Scene {
    
    CGPoint touchDownPoint;
    double prevCourse;
};

typedef enum coolCarTypes { Low, LowDrag, Gasser } CoolCarTypes;

@property(strong, nonatomic) Camera* cameras;
@property(strong, nonatomic) PaintBooth* paintBooth;
@property(strong, nonatomic) CC3ResourceNode* rootCarNode;
@property(strong, nonatomic) CC3Node* pitchEmpty;
@property(strong, nonatomic) CC3Node* background;

@property(assign, nonatomic) CC3Vector lowBodyLocation;
@property(assign, nonatomic) CC3Vector gasserBodyLocation;
@property(strong, nonatomic) CC3Node* wheelEmpty;
@property(strong, nonatomic) CC3Node* bodyNode;
@property(strong, nonatomic) CC3Node* hoodNode;
@property(strong, nonatomic) CC3Node* hoodScoopNode;
@property(strong, nonatomic) CC3Node* fuelCellNode;
@property(strong, nonatomic) CC3Node* frontAxle;
@property(strong, nonatomic) CC3Node* rearAxle;
@property(strong, nonatomic) CC3Node* nodeFLWheel;
@property(strong, nonatomic) CC3Node* nodeFRWheel;
@property(strong, nonatomic) CC3Node* nodeRLWheel;
@property(strong, nonatomic) CC3Node* nodeRRWheel;

@property (strong, nonatomic) CC3ResourceNode* groundPlaneNode;
@property (strong, nonatomic) FirstCocos3DLayer* layer;
-(void) setCourseHeading:(double)course withSpeed:(double)speed;

@property (strong, nonatomic) CMMotionManager* manager;
@property (strong, nonatomic) id<Filters> wheelTurningFilter;
@property (strong, nonatomic) id<Filters> courseFilter;
@property (strong, nonatomic) id<Filters> rollFilter;
@property (strong, nonatomic) id<Filters> pitchFilter;
@property (strong, nonatomic) id<Filters> groundPlaneGyroFilter;
@property (strong, nonatomic) id<Filters> wheelieFilter;
@property (strong, nonatomic) id<Filters> upDownBodyMotionFilter;
@end
