//
//  KalmanFilter.m
//  FirstCocos3D
//
//  Created by David Mitchell on 10/2/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KalmanFilter.h"


@implementation KalmanFilter

-(id) init {
    
    self = [super init];
    
    if(self) {
        
        _resetIfZero = false;
        
        // Starting values
        [self reset];
    }
    return self;
}

-(NSString*) filterName {
    return @"Kalman Filter";
}

-(void) resetIfZero:(BOOL) resetIfZero {
    _resetIfZero = resetIfZero;
}

-(double) get:(double) zk {

    if( _resetIfZero && zk <= 0.0 ) {
        [self reset];
        return 0.0;
    }
    
    double kk = _previousPk / (_previousPk + 0.1);
    
    _previousXk += kk * (zk - _previousXk);
    _previousPk = (1 - kk) * _previousPk;
    
    return _previousXk; // which is actully *this* Xk;
}

-(void) reset {
    _previousXk = 0.0;
    _previousPk = 1.0;
}

@end