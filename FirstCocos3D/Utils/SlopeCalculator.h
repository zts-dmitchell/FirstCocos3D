//
//  SlopeCalculator.h
//  FirstCocos3D
//
//  Created by David Mitchell on 12/15/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#ifndef FirstCocos3D_SlopeCalculator_h
#define FirstCocos3D_SlopeCalculator_h

#include <Foundation/Foundation.h>
#import "Filters.h"

@import CoreLocation;

@interface SlopeCalculator : NSObject

-(id) init;
-(id) initWithSecondsBetweenUpdates:(double) secondsBetweenUpdates;
-(double) getAngle:(CLLocation*) location fromAltitude:(double) altitude andSpeed:(double) speed;

@property(strong, nonatomic) CLLocation* previousLocation;
@property(strong, nonatomic) id<Filters> angleFilter;
@property(assign, nonatomic) double secondsSinceLastUpdate;
@property(assign, nonatomic) double secondsBetweenUpdates;
@property(assign, nonatomic) double previousAltitude;
@property(assign, nonatomic) double previousAngle;

@end

#endif
