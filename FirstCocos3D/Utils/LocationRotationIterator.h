//
//  Iterator.h
//  FirstCocos3D
//
//  Created by David Mitchell on 12/21/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#ifndef FirstCocos3D_Iterator_h
#define FirstCocos3D_Iterator_h

#import "CC3Foundation.h"

typedef struct _locationRotation {
    CC3Vector rotation;
    CC3Vector location;
}LocationRotation;

@protocol LocationRotationIterator <NSObject>

@required
-(bool) hasNext;
-(LocationRotation) next;

@end

#endif
