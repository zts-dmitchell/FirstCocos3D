/**
 *  FirstCocos3DLayer.m
 *  FirstCocos3D
 *
 *  Created by David Mitchell on 9/6/14.
 *  Copyright David Mitchell 2014. All rights reserved.
 */

#import "FirstCocos3DLayer.h"
#import "FirstCocos3DScene.h"


@implementation FirstCocos3DLayer

/**
 * Override to set up your 2D controls and other initial state, and to initialize update processing.
 *
 * For more info, read the notes of this method on CC3Layer.
 */
-(void) initializeControls {
	[self scheduleUpdate];
}


#pragma mark Updating layer

/**
 * Override to perform set-up activity prior to the scene being opened
 * on the view, such as adding gesture recognizers.
 *
 * For more info, read the notes of this method on CC3Layer.
 */
-(void) onOpenCC3Layer {}

/**
 * Override to perform tear-down activity prior to the scene disappearing.
 *
 * For more info, read the notes of this method on CC3Layer.
 */
-(void) onCloseCC3Layer {}

/**
 * The ccTouchMoved:withEvent: method is optional for the <CCTouchDelegateProtocol>.
 * The event dispatcher will not dispatch events for which there is no method
 * implementation. Since the touch-move events are both voluminous and seldom used,
 * the implementation of ccTouchMoved:withEvent: has been left out of the default
 * CC3Layer implementation. To receive and handle touch-move events for object
 * picking, uncomment the following method implementation.
 */
/*
-(void) ccTouchMoved: (UITouch *)touch withEvent: (UIEvent *)event {
	[self handleTouch: touch ofType: kCCTouchMoved];
}
 */

@end
