//
//  EmptyFilter.m
//  FirstCocos3D
//
//  Created by David Mitchell on 12/14/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EmptyFilter.h"

@implementation EmptyFilter

-(id) init {
    
    self = [super init];
    
    return self;
}

-(double) get:(double) value {
    return value;
}

-(NSString*) filterName {
    return @"Empty Filter";
}


@end