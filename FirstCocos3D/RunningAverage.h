//
//  RunningAverage.h
//  FirstCocos3D
//
//  Created by David Mitchell on 9/29/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#ifndef FirstCocos3D_RunningAverage_h
#define FirstCocos3D_RunningAverage_h


@interface RunningAverage : NSObject

@property (strong, nonatomic) NSMutableArray* values;
@property (nonatomic, assign) int size;

-(id) initWithAvgLength: (int) size;
-(void) boo;
-(double) get:(double) value;

@end

#endif
