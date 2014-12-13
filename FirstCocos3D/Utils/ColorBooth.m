//
//  ColorBooth.m
//  FirstCocos3D
//
//  Created by David Mitchell on 12/10/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CC3Actions.h"
#import "ColorBooth.h"

@implementation ColorBooth

/*
 Initializer.
*/
-(id) init {
    self = [super init];
    
    if(self != nil) {
        
        self.currentColor = 0;
        
        [self initColors];
    }
    
    return self;
}

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
        
        //bodyPart.material = [CC3Material shiny];
        bodyPart.reflectivity = kCC3MaximumMaterialShininess;
        bodyPart.material.reflectivity = bodyPart.reflectivity;
        //bodyPart.material.diffuseColor = color;
        [bodyPart runAction:[CC3ActionTintDiffuseTo actionWithDuration:1.0 colorTo:color]];
        bodyPart.material.specularColor = kCCC4FWhite;
        //NSLog(@"bodyPart: %@", bodyPart.material.fullDescription);
    }
}

/*
 Set the part to the next color. Doesn't hold state, so if the node is different, 
 colors will resume wherever it was left.
*/
-(void) nextColor:(NSArray*) parts inNode:(CC3Node*) node {
    
    NSValue *pCi = [self.colors objectAtIndex: (self.currentColor++ % self.colors.count)];
    
    ccColor4F nextColor;
    [pCi getValue:&nextColor];
    NSLog(@"New color: %@", NSStringFromCCC4F(nextColor));
    [ColorBooth changeColor:parts inNode:node asColor:nextColor];
}

/*
 Allows the user to add a custom color, separate from the built-in ones.
*/
-(void) addColor:(ccColor4F) color {

    NSValue * pColor = [NSValue valueWithBytes:&color objCType:@encode(ccColor4F)];
    [self.colors addObject:pColor];
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

@end