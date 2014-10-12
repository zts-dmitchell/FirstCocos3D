/**
 *  FirstCocos3DScene.h
 *  FirstCocos3D
 *
 *  Created by David Mitchell on 9/6/14.
 *  Copyright David Mitchell 2014. All rights reserved.
 */


#import "CC3Scene.h"
#import "CC3ResourceNode.h"

/** A sample application-specific CC3Scene subclass.*/
@interface FirstCocos3DScene : CC3Scene {
    
    CGPoint touchDownPoint;
    double prevCourse;

};

@property (strong, nonatomic) CC3ResourceNode* rezNode;
-(void) setCourseHeading:(double)course;

@end
