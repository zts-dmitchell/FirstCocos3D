//
//  PaintBooth.m
//  FirstCocos3D
//
//  Created by David Mitchell on 12/10/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CC3Actions.h"
#import "PaintBooth.h"

@implementation PaintBooth

#pragma mark Initializing Code
/*
 Initializer.
*/
-(id) init {
    self = [super init];
    
    if(self != nil) {
        
        self.currentColor = 0;
        
        self.meshByMaterialName = [[NSMutableDictionary alloc] init];
        
        [self initColors];
    }
    
    return self;
}

/*
 Initializes the default colors.
 */
-(void) initColors {
    
    self.colors = [[NSMutableArray alloc] init];
    
    ccColor4F tan;
    tan.r = 0.979;
    tan.g = 0.897;
    tan.b = 0.597;
    tan.a = 1.0;
    
    NSValue * pColor = [NSValue valueWithBytes:&tan objCType:@encode(ccColor4F)];
    [self.colors addObject:pColor];
    
    
    pColor = [NSValue valueWithBytes:&kCCC4FOrange objCType:@encode(ccColor4F)];
    [self.colors addObject:pColor];
    
    pColor = [NSValue valueWithBytes:&kCCC4FRed objCType:@encode(ccColor4F)];
    [self.colors addObject:pColor];
    
    pColor = [NSValue valueWithBytes:&kCCC4FGreen objCType:@encode(ccColor4F)];
    [self.colors addObject:pColor];
    
    pColor = [NSValue valueWithBytes:&kCCC4FBlue objCType:@encode(ccColor4F)];
    [self.colors addObject:pColor];
    
    pColor = [NSValue valueWithBytes:&kCCC4FCyan objCType:@encode(ccColor4F)];
    [self.colors addObject:pColor];
    
    pColor = [NSValue valueWithBytes:&kCCC4FMagenta objCType:@encode(ccColor4F)];
    [self.colors addObject:pColor];
    
    pColor = [NSValue valueWithBytes:&kCCC4FYellow objCType:@encode(ccColor4F)];
    [self.colors addObject:pColor];
    
    pColor = [NSValue valueWithBytes:&kCCC4FLightGray objCType:@encode(ccColor4F)];
    [self.colors addObject:pColor];
    
    pColor = [NSValue valueWithBytes:&kCCC4FGray objCType:@encode(ccColor4F)];
    [self.colors addObject:pColor];
    
    pColor = [NSValue valueWithBytes:&kCCC4FDarkGray objCType:@encode(ccColor4F)];
    [self.colors addObject:pColor];
    
    pColor = [NSValue valueWithBytes:&kCCC4FWhite objCType:@encode(ccColor4F)];
    [self.colors addObject:pColor];
    
    pColor = [NSValue valueWithBytes:&kCCC4FBlack objCType:@encode(ccColor4F)];
    [self.colors addObject:pColor];
}


#pragma mark Changing Colors

/*
 Change the color of the given body party parts.
*/
+(void) changeColor:(NSArray*) parts inNode:(CC3Node*) node asColor:(ccColor4F) color {
    
    for( NSString* part in parts) {
        
        CC3MeshNode* bodyPart = [node getMeshNodeNamed: part];
        
        if(bodyPart == nil) {
            NSLog(@"Unknown body part: %@", part);
            continue;
        }
        
        //bodyPart.reflectivity = 90.0;
        //bodyPart.material.reflectivity = bodyPart.reflectivity;
        [bodyPart runAction:[CC3ActionTintDiffuseTo actionWithDuration:0.65 colorTo:color]];
        //bodyPart.material.specularColor = kCCC4FWhite;
    }
}

-(void) changeColor:(NSString*) materialName toColor:(ccColor4F) color {
    
    CC3MeshNode* n = [self.meshByMaterialName objectForKey:materialName];
    
    NSArray *parts = @[ n.name ];

    [PaintBooth changeColor:parts inNode:n asColor:color];
    //CC3MeshNode* bodyPart = [n getMeshNodeNamed: n.name];
    
    //bodyPart.material.color = [self getMaterial:materialName].color;

}

/*
 Set the part to the next color. Doesn't hold state, so if the node is different,
 colors will resume wherever it was left.
*/
-(void) nextColor:(NSArray*) parts inNode:(CC3Node*) node {
    
    NSValue *pCi = [self.colors objectAtIndex: (self.currentColor++ % self.colors.count)];
    
    ccColor4F nextColor;
    [pCi getValue:&nextColor];
    NSLog(@"Next color: %@", NSStringFromCCC4F(nextColor));
    [PaintBooth changeColor:parts inNode:node asColor:nextColor];
}

/*
 Allows the user to add a custom color, separate from the built-in ones.
*/
-(void) addColor:(ccColor4F) color {

    NSLog(@"Adding color: %@", NSStringFromCCC4F(color));

    NSValue * pColor = [NSValue valueWithBytes:&color objCType:@encode(ccColor4F)];
    [self.colors addObject:pColor];
}

#define Z255_TO_Z1(x)   ((x)/255.0)

-(void) addColor:(int) r :(int) g :(int) b {

    [self addColor:ccc4f(Z255_TO_Z1(r),Z255_TO_Z1(g),Z255_TO_Z1(b), 1)];
}

/*
 Resets to color iterator to the beginning.
*/
-(void) resetColorIterator {
    self.currentColor = 0;
}

/*
 Returns the current color position.
*/
-(int) getCurrentColorPosition {
    return (self.currentColor % self.colors.count);
}

#pragma mark Materials Section

-(void) swapMaterialsInNode:(CC3Node*) node withMaterial:(NSString*) namedThis with:(NSString*) namedThat {
    
    CC3Material* newMat = [self getMaterial:namedThat];
    
    if(!newMat) {
        NSLog(@"Couldn't find material: %@", namedThat);
        return;
    }
    
    for(CC3MeshNode* n in node.children) {
        
        CC3Material* mat = n.material;
        
        if(!mat)
            continue;
        
        if([mat.name compare:namedThis] == NSOrderedSame) {
            NSLog(@"Found it: %@", mat.name);
            [n setMaterial:newMat];
            return;
        }
    }
}

-(void) saveMaterial:(NSString*) materialName inNode:(CC3Node*) node {
    
    CC3Material* mat = [self findMaterialWithNameInNode:materialName inNode:node];
    
    if(mat != nil)
        [self addMaterial:mat withKey:materialName];
    else
        NSLog(@"Couldn't find material: %@", materialName);

}

-(void) storeMeshNodeByMaterialName:(NSString*) materialName inNode:(CC3Node*) node {
    
    NSArray* children = node.children;
    
    for(CC3MeshNode* n in children) {
        NSLog(@"Description of parent, %@: %@", node.name, n.description);
        
        CC3Material* mat = n.material;
        
        if(!mat)
            continue;
        
        if([mat.name compare:materialName] == NSOrderedSame) {
            NSLog(@"Found it: %@", mat.name);
            
            [self.meshByMaterialName setObject:n forKey:materialName];
            
        } else {
            NSLog(@"Material was: %@", mat.name);
        }        
    }
}


-(CC3Material*) findMaterialWithNameInNode:(NSString*) materialName inNode:(CC3Node*) node {

    NSArray* children = node.children;
    
    for(CC3MeshNode* n in children) {
        NSLog(@"Description of parent, %@: %@", node.name, n.description);
        
        CC3Material* mat = n.material;
        
        if(!mat)
            continue;
        
        if([mat.name compare:materialName] == NSOrderedSame) {
            NSLog(@"Found it: %@", mat.name);
            return [mat copy];
        } else {
            NSLog(@"Material was: %@", mat.name);
        }
        
        [self saveMaterial:materialName inNode:n];
    }

    return nil;
}

-(void) addMaterial:(CC3Material*) theMaterial withKey:(NSString*) theKey {
    
    if(self.materials == nil)
        self.materials = [[NSMutableDictionary alloc] init];
    
    [self.materials setObject:theMaterial forKey:theKey];
}

-(CC3Material*) getMaterial:(NSString*) materialName {
    
    if(!self.materials) return nil;
    
    return [self.materials objectForKey:materialName];
}

@end