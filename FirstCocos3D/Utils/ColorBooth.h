//
//  ColorBooth.h
//  FirstCocos3D
//
//  Created by David Mitchell on 12/10/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#ifndef FirstCocos3D_ColorBooth_h
#define FirstCocos3D_ColorBooth_h

#import "CC3Foundation.h"
#import "CC3MeshNode.h"

@interface ColorBooth : NSObject

-(id) init;
-(void) nextColor:(NSArray*) parts inNode:(CC3Node*) node;
-(void) addColor:(ccColor4F) color;
-(void) addColor:(int) r :(int) g :(int) b;
+(void) changeColor:(NSArray*) parts inNode:(CC3Node*) node asColor:(ccColor4F) color;

-(void) resetColorIterator;
-(int) getCurrentColorPosition;

@property (strong, nonatomic) NSMutableArray* colors;
@property (assign, nonatomic) int currentColor;
@end


#endif
