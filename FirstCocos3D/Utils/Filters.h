//
//  Filters.h
//  FirstCocos3D
//
//  Created by David Mitchell on 11/26/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#ifndef FirstCocos3D_Filters_h
#define FirstCocos3D_Filters_h

@protocol Filters <NSObject>

-(double) get:(double) value;
-(NSString*) filterName;

@end

#endif
