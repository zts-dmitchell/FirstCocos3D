//
//  ColorBooth.m
//  FirstCocos3D
//
//  Created by David Mitchell on 12/10/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ColorBooth.h"

@implementation ColorBooth

-(id) init {
    self = [super init];
    
    if(self != nil) {
        
        self.currentColor = 0;
        
        [self initColors];
    }
    
    return self;
    
}

+(void) changeColor:(NSArray*) parts inNode:(CC3Node*) node asColor:(ccColor4F) color{
    
    for( NSString* part in parts) {
        
        CC3MeshNode* bodyPart = [node getMeshNodeNamed: part];
        
        bodyPart.material = [CC3Material shiny];
        bodyPart.reflectivity = kCC3MaximumMaterialShininess;
        bodyPart.material.reflectivity = bodyPart.reflectivity;
        bodyPart.material.diffuseColor = color;
        bodyPart.material.specularColor = kCCC4FWhite;
        //NSLog(@"bodyPart: %@", bodyPart.material.fullDescription);
    }
}

-(void) nextColor:(NSArray*) parts inNode:(CC3Node*) node {
    
    NSValue *pCi = [self.colors objectAtIndex: (self.currentColor++ % self.colors.count)];
    
    ccColor4F nextColor;
    [pCi getValue:&nextColor];
    NSLog(@"New color: %@", NSStringFromCCC4F(nextColor));
    [ColorBooth changeColor:parts inNode:node asColor:nextColor];
}

-(void) addColor:(ccColor4F) color {

    NSValue * pColor = [NSValue valueWithBytes:&color objCType:@encode(ccColor4F)];
    [self.colors addObject:pColor];
}

-(void) initColors {
    
    self.colors = [[NSMutableArray alloc] init];
    
    NSValue * pColor = [NSValue valueWithBytes:&kCCC4FOrange objCType:@encode(ccColor4F)];
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
    
    pColor = [NSValue valueWithBytes:&kCCC4FRed objCType:@encode(ccColor4F)];
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
    
    pColor = [NSValue valueWithBytes:&kCCC4FBlackTransparent objCType:@encode(ccColor4F)];
    [self.colors addObject:pColor];
}

@end