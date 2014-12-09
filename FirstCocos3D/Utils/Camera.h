//
//  Camera.h
//  FirstCocos3D
//
//  Created by David Mitchell on 12/9/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#ifndef FirstCocos3D_Camera_h
#define FirstCocos3D_Camera_h

#import "CC3Foundation.h"
#import "CC3Camera.h"

typedef struct _cameraInfo {
    CC3Vector location;
    CC3Vector rotation;
    double fieldOfView;
    
} CameraInfo;

@interface Camera : NSObject

@property (strong, nonatomic) NSMutableArray* cameraPositions;
@property (assign, nonatomic) int currentCamera;

-(id) init;
-(void) add:(CC3Vector)location withRotation:(CC3Vector) rotation andFieldOfView:(double) fieldOfView;
-(void) add:(CC3Vector)location withRotation:(CC3Vector) rotation;
-(void) add:(CC3Vector)location;
-(void) transitionToNext:(CC3Camera*) camera;
-(void) transitionToNext:(CC3Camera*) camera withDuration:(double) duration;

@end


#endif
