//
//  RunningAverage.m
//  FirstCocos3D
//
//  Created by David Mitchell on 9/29/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RunningAverage.h"

@implementation RunningAverage

-(id) initWithAvgLength:(int) size {
 
    if( self.values != nil ) {
        NSLog(@"Already initialized!!");
        return self;
    }
    
    self.size = size;
    
    NSLog(@"Initializing with %d", size);
    
    self.values = [[NSMutableArray alloc] initWithCapacity:size];
    
    return self;
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


-(void) boo {
    NSLog(@"BOOO!!!");
}

@end