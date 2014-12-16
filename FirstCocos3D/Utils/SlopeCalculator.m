//
//  SlopeCalculator.m
//  FirstCocos3D
//
//  Created by David Mitchell on 12/9/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#import "SlopeCalculator.h"
#import "KalmanFilter.h"
#import "EmptyFilter.h"

#define METERS_TO_FEET(m)   ((m) * 3.2808399);

@implementation SlopeCalculator

-(id) init {
    
    self = [super init];

    if( self != nil) {
        
        self.previousLocation = nil;
        self.secondsSinceLastUpdate = 0.0;
        self.secondsBetweenUpdates = 1.0;
        self.previousAltitude = 0.0;
        self.previousAngle = 0.0;
        
        //self.angleFilter = [[KalmanFilter alloc] init];
        self.angleFilter = [[EmptyFilter alloc] init];
    }
    
    return self;
}

-(id) initWithSecondsBetweenUpdates:(double) secondsBetweenUpdates {

    self = [self init];
    
    if(self != nil)
        self.secondsBetweenUpdates = secondsBetweenUpdates;
    
    return self;
}

#ifndef CC_RADIANS_TO_DEGREES
#define CC_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 57.29577951f) // PI * 180
#endif

-(double) getAngle:(CLLocation*) location fromAltitude:(double) altitude {
 
    if(self.previousLocation == nil) {
        
        self.previousLocation = location;
        NSLog(@"SlopeCalculator: Too soon");
        return 0.0;
    }
    
    self.secondsSinceLastUpdate += [location.timestamp timeIntervalSinceDate:self.previousLocation.timestamp];
    
    if(self.secondsSinceLastUpdate < self.secondsBetweenUpdates) {
        
        //NSLog(@"sslu: %f, sbu: %f", self.secondsSinceLastUpdate, self.secondsBetweenUpdates);
        return self.previousAngle;
    }
        
    self.secondsSinceLastUpdate = 0.0;
    
    CLLocationDistance distance = METERS_TO_FEET([location distanceFromLocation:self.previousLocation]);

    // angle = atan(distance/altitude);
    // Convert to degrees.
    const double changeInAltitude = altitude - self.previousAltitude;
    
    NSLog(@"distance: %f, alt: %f, prevAlt: %f, diff: %f", distance, altitude, self.previousAltitude, changeInAltitude);

    self.previousLocation = location;
    self.previousAltitude = altitude;

    if(changeInAltitude == 0.0)
        return self.previousAngle;
    
    self.previousAngle = [self.angleFilter get:CC_RADIANS_TO_DEGREES(atan(distance/changeInAltitude))];
    
    return self.previousAngle;
}



@end