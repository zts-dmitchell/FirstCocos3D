//
//  ExponentialMovingAverage.m
//  FirstCocos3D
//
//  Created by David Mitchell on 11/27/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExponentialMovingAverage.h"

@implementation ExponentialMovingAverage

-(id) initWithNumberOfPeriods:(int) numberOfPeriods {
    
    self = [super init];
    
    if(self) {
        
        self.previousEMA = 1.0;
        self.numberOfPeriods = numberOfPeriods;
        self.smoothingFactor = 2.0/(1+numberOfPeriods);
        
        NSLog(@"Initializing with size: %d, Smoothing factor: %f",
              self.numberOfPeriods, self.smoothingFactor);
    }
    return self;
}

-(NSString*) filterName {
    return @"EMA Filter";
}

/**
 *
 */
-(double) get:(double) value {
    
    const double ema = (value * self.smoothingFactor) + (self.previousEMA * (1.0 - self.smoothingFactor));
    
    NSLog(@"Value: %f. EMA: %f", value, ema);
    self.previousEMA = ema;
    
    return ema;
}

@end
