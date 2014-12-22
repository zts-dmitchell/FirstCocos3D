//
//  PositionIterator.m
//  FirstCocos3D
//
//  Created by David Mitchell on 12/21/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LinearLRIterator.h"

@implementation LinearLRIterator

-(id) initWithIncrementBy:(double) incrementBy startingAt:(double) beginning andEndingAt:(double) ending {
    
    self = [super init];
    
    if(self != nil) {

        assert(incrementBy > 0.0);
        assert(beginning < ending);

        _incrementBy = incrementBy;
        _start = beginning;
        _end = ending;
        //_next = -1;
    }
    
    return self;
}

-(bool) hasNext {

    if(_start <= _end) {
        
       // _next = _start;
        _start += _incrementBy;
        
        return true;
    }
    
    //_next = -1;
    _start = 1;
    _end = 0;
    
    return false;
}

-(LocationRotation) next {
    
    //assert(_next != -1);
    //return _next;
    return _locationRotation;
}

@end