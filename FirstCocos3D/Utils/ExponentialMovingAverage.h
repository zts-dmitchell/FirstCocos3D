//
//  ExponentialMovingAverage.h
//  FirstCocos3D
//
//  Created by David Mitchell on 11/27/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#ifndef FirstCocos3D_ExponentialMovingAverage_h
#define FirstCocos3D_ExponentialMovingAverage_h

#import "Filters.h"

@interface ExponentialMovingAverage : NSObject <Filters>

@property (strong, nonatomic) NSMutableArray* values;
@property (nonatomic, assign) int size;

-(id) initWithAvgLength: (int) size;
-(double) get:(double) value;

@end


#endif
