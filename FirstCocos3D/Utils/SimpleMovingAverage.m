//
//  SimpleMovingAverage.m
//  FirstCocos3D
//
//  Created by David Mitchell on 11/27/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SimpleMovingAverage.h"

@implementation SimpleMovingAverage

-(id) initWithAvgLength:(int) size {
    
    self = [super init];
    
    if(self) {
        
        if( self.values != nil ) {
            NSLog(@"Already initialized!!");
            return self;
        }
        
        self.size = size;
        
        NSLog(@"Initializing with %d", size);
        
        self.values = [[NSMutableArray alloc] initWithCapacity:size];
    }
    return self;
}

-(NSString*) filterName {
    return @"Running Average Filter";
}
/**
 *
 */
-(double) get:(double) value {
    
    [self.values addObject:[NSNumber numberWithFloat:value]];
    
    if(self.values.count < self.size) {
        
        NSLog(@"Not ready yet.  Size is %lu", (unsigned long)self.values.count);
        return 0.0;
    }
    
    double sum = 0.0;
    
    for (id object in self.values) {
        NSNumber *val = object;
        sum += [val doubleValue];
    }
    
    double avg = sum / self.values.count;
    
    [self.values removeObjectAtIndex:0];
    
    return avg;
}

@end
