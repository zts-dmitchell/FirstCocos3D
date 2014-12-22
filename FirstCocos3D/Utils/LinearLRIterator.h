//
//  PositionIterator.h
//  FirstCocos3D
//
//  Created by David Mitchell on 12/21/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#ifndef FirstCocos3D_PositionIterator_h
#define FirstCocos3D_PositionIterator_h

#import "LocationRotationIterator.h"


@interface LinearLRIterator : NSObject <LocationRotationIterator>

-(id) initWithIncrementBy:(double) incrementBy startingAt:(double) beginning andEndingAt:(double) ending;

-(bool) hasNext;
-(LocationRotation) next;

@property(assign, nonatomic) LocationRotation locationRotation;
@property(assign, nonatomic) double currentPlace;
@property(assign, nonatomic) double incrementBy;
@property(assign, nonatomic) double start;
@property(assign, nonatomic) double end;

@end

#endif
