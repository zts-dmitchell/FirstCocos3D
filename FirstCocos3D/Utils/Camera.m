//
//  Camera.m
//  FirstCocos3D
//
//  Created by David Mitchell on 12/9/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Camera.h"
#import "CC3ActionInterval.h"

@implementation Camera

-(id) init {
    self = [super init];

    if( self != nil) {
        self.currentCamera = 0;
        
        self.cameraPositions = [[NSMutableArray alloc] initWithCapacity:10];
    }
    
    return self;
}

// setFieldOfView
-(void) add:(CC3Vector)location withRotation:(CC3Vector) rotation andFieldOfView:(double) fieldOfView {

    CameraInfo ci;
    
    ci.location = location;
    ci.rotation = rotation;
    ci.fieldOfView = fieldOfView;
    
    NSValue * pCameraInfo = [NSValue valueWithBytes:&ci objCType:@encode(CameraInfo)];
    [self.cameraPositions addObject:pCameraInfo];
}

-(void) add:(CC3Vector)location withRotation:(CC3Vector) rotation {

    [self add:location withRotation:rotation andFieldOfView:45.0];
}

-(void) add:(CC3Vector)location {
    [self add:location withRotation:cc3v(0, 0, 0)];
}

-(void) transitionToNext:(CC3Camera*) camera {
    [self transitionToNext:camera withDuration:0.5];
}

-(void) transitionToNext:(CC3Camera*) camera withDuration:(double) duration {
    
    NSLog(@"transitioningToNext: %@", camera.name);
    CameraInfo ci;
    
    NSValue *pCi = [self.cameraPositions objectAtIndex: (self.currentCamera++ % self.cameraPositions.count )];
    [pCi getValue:&ci];
    
    camera.fieldOfView = ci.fieldOfView;
    [camera runAction:[CC3ActionMoveTo actionWithDuration:duration moveTo:ci.location]];
    [camera runAction:[CC3ActionRotateTo actionWithDuration:duration rotateTo:ci.rotation]];
}


@end