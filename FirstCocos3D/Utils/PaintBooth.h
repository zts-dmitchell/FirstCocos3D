//
//  PaintBooth.h
//  FirstCocos3D
//
//  Created by David Mitchell on 12/10/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#ifndef FirstCocos3D_PaintBooth_h
#define FirstCocos3D_PaintBooth_h

#import "CC3Foundation.h"
#import "CC3MeshNode.h"

@interface PaintBooth : NSObject

-(id) init;
-(void) nextColor:(NSArray*) parts inNode:(CC3Node*) node;
-(void) addColor:(ccColor4F) color;
-(void) addColor:(int) r :(int) g :(int) b;
+(void) changeColor:(NSArray*) parts inNode:(CC3Node*) node asColor:(ccColor4F) color;
-(void) changeColor:(NSString*) materialName toColor:(ccColor4F) color;

// Materials
-(void) swapMaterialsInNode:(CC3Node*) node withMaterial:(NSString*) namedThis with:(NSString*) namedThat;
-(void) saveMaterial:(NSString*) theMaterial inNode:(CC3Node*) node;
-(CC3Material*) getMaterial:(NSString*) materialName;
-(void) addMaterial:(CC3Material*) theMaterial withKey:(NSString*) theKey;
-(void) storeMeshNodeByMaterialName:(NSString*) materialName inNode:(CC3Node*) node;

-(void) resetColorIterator;
-(int) getCurrentColorPosition;

@property (strong, nonatomic) NSMutableArray* colors;
@property (assign, nonatomic) int currentColor;
@property (strong, nonatomic) NSMutableDictionary* materials;
@property (strong, nonatomic) NSMutableDictionary* meshByMaterialName;

@end

#endif
