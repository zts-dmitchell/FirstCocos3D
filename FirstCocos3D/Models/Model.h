//
//  Model.h
//  FirstCocos3D
//
//  Created by David Mitchell on 12/3/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#ifndef FirstCocos3D_Model_h
#define FirstCocos3D_Model_h

@protocol Model <NSObject>

-(id) init;
-(void) hideParts;
-(void) setCoolCarType:(int) carType;
-(NSString*) filterName;

@end

#endif
