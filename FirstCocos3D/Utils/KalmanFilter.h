//
//  KalmanFilter.h
//  FirstCocos3D
//
//  Created by David Mitchell on 10/2/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#ifndef FirstCocos3D_KalmanFilter_h
#define FirstCocos3D_KalmanFilter_h

@interface KalmanFilter : NSObject
{
    @private double _previousXk;
    @private double _previousPk;
}

-(id) init;
-(double) get:(double) value;
-(void) reset;

@end

#endif
