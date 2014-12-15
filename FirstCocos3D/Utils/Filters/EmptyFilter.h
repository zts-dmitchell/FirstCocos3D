//
//  EmptyFilter.h
//  FirstCocos3D
//
//  Created by David Mitchell on 12/14/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#ifndef FirstCocos3D_EmptyFilter_h
#define FirstCocos3D_EmptyFilter_h

#import "Filters.h"

@interface EmptyFilter : NSObject <Filters>

-(id) init;
-(double) get:(double) value;

@end

#endif
