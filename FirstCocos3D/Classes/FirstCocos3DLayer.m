/**
 *  FirstCocos3DLayer.m
 *  FirstCocos3D
 *
 *  Created by David Mitchell on 9/6/14.
 *  Copyright David Mitchell 2014. All rights reserved.
 */

#import "FirstCocos3DLayer.h"
#import "FirstCocos3DScene.h"
#import "RunningAverage.h"
#import "KalmanFilter.h"

@import CoreLocation;

@interface FirstCocos3DLayer () <CLLocationManagerDelegate>

@property (strong, nonatomic) CCLabelTTF *mphLabel;
@property (strong, nonatomic) CCLabelTTF *altitudeLabel;
@property (strong, nonatomic) CCLabelTTF *courseLabel;
@property (strong, nonatomic) CCLabelTTF *headingLabel;
@property (strong, nonatomic) CCLabelTTF *headingTypeLabel;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocationSpeed speed;
@property (strong, nonatomic) RunningAverage *runningAvg;
@property (strong, nonatomic) RunningAverage *headingRunningAvg;

@end

@implementation FirstCocos3DLayer

/**
 * Override to set up your 2D controls and other initial state, and to initialize update processing.
 *
 * For more info, read the notes of this method on CC3Layer.
 */
-(void) initializeControls {
    
    NSLog(@"Cocos2D Version: %@", cocos2dVersion());

	//[self scheduleUpdate];
    
    self.userInteractionEnabled = YES;
    [self setTouchEnabled:YES];
    
    self.mphLabel = [CCLabelTTF labelWithString:@"" fontName:@"Verdana-Bold" fontSize:18.0f];
    self.mphLabel.positionType = CCPositionTypeNormalized;
    self.mphLabel.position = ccp(0.25f, 0.96f);
    CCColor* color = [CCColor greenColor];
    
    [self.mphLabel setColor:color];
    [self addChild:self.mphLabel];
    
    self.altitudeLabel = [CCLabelTTF labelWithString:@"" fontName:@"Verdana-Bold" fontSize:18.0f];
    self.altitudeLabel.positionType = CCPositionTypeNormalized;
    self.altitudeLabel.position = ccp(0.08f, 0.9f);
    [self addChild:self.altitudeLabel];
    
    self.courseLabel = [CCLabelTTF labelWithString:@"Course: " fontName:@"Verdana-Bold" fontSize:18.0f];
    self.courseLabel.positionType = CCPositionTypeNormalized;
    self.courseLabel.position = ccp(0.12f, 0.84f);
    [self.courseLabel setHorizontalAlignment:CCTextAlignmentLeft];
    [self addChild:self.courseLabel];
    
    self.headingLabel = [CCLabelTTF labelWithString:@"Heading: " fontName:@"Verdana-Bold" fontSize:18.0f];
    self.headingLabel.positionType = CCPositionTypeNormalized;
    self.headingLabel.position = ccp(0.13f, 0.78f);
    [self.headingLabel setHorizontalAlignment:CCTextAlignmentLeft];
    [self addChild:self.headingLabel];
    
    self.headingTypeLabel = [CCLabelTTF labelWithString:@"" fontName:@"Verdana-Bold" fontSize:18.0f];
    self.headingTypeLabel.positionType = CCPositionTypeNormalized;
    self.headingTypeLabel.position = ccp(0.8f, 0.025f);
    [self.headingTypeLabel setHorizontalAlignment:CCTextAlignmentRight];
    [self addChild:self.headingTypeLabel];
    

    // new shit
    bIsCourse = FALSE;
    FirstCocos3DScene* scene = (FirstCocos3DScene*)self.cc3Scene;
    scene.layer = self;
    
    self.runningAvg = [[RunningAverage alloc] initWithAvgLength:2];
    self.headingRunningAvg = [[RunningAverage alloc] initWithAvgLength:2];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // This location manager will be used to collect RSSI samples from the targeted beacon.
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager requestAlwaysAuthorization];
    
    // Start heading updates.
    if ([CLLocationManager headingAvailable]) {
        self.locationManager.headingFilter = 1;
        [self.locationManager startUpdatingHeading];
    }
    
    [self.locationManager startUpdatingLocation];
}

#pragma mark - My Shit

-(void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    [self locationManager:manager didUpdateToLocation:newLocation fromLocation:oldLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *newLocation = [locations lastObject];
    
    self.speed = [newLocation speed];
    CLLocationDistance altitude = [newLocation altitude] * 3.2808399; // Convert meters to feet
    CLLocationDirection course = [newLocation course];
    
    if( self.speed <= 0.0 ) {
        self.speed = 0.0;
    }
    else {
        self.speed *= 2.23694; // Convert KPH to MPH
    }
    
    double average = [self.runningAvg get:self.speed];

    [self.mphLabel setString:[NSString stringWithFormat:@"Speed:%3.0f MPH, Avg:%3.0f MPH", self.speed, average]];
    
//    if( course == -1 )
//        [self.courseLabel setString:@"Course: N/A"];
//    else
//        [self.courseLabel setString:[NSString stringWithFormat: @"Course: %3.0f°", course]];
//    
//    [self.altitudeLabel setString:[NSString stringWithFormat: @"Alt: %3.0f'", altitude]];
    
    
    if( bIsCourse ) {
        FirstCocos3DScene* scene = (FirstCocos3DScene*)self.cc3Scene;
    
        if( course >= 0.0 )
            [scene setCourseHeading: course withSpeed:self.speed];
    
        //[self.headingTypeLabel setString:[NSString stringWithFormat:@"Course: %.f°", course]];
    }

}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    
    if (newHeading.headingAccuracy < 0)
        return;
    
    // Use the true heading if it is valid.
    CLLocationDirection  theHeading = ((newHeading.trueHeading > 0) ?
                                       newHeading.trueHeading : newHeading.magneticHeading);
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    // Adjust the heading based on the orientation of the phone.  It can be off by -90, 90, or 180 degrees.
    if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
        
        if( theHeading < 270.0 )
            theHeading += 90;
        else
            theHeading -= 270.0;
    }
    else if (deviceOrientation == UIDeviceOrientationLandscapeRight) {

        if( theHeading < 90.0 ) {
            theHeading += 270.0;
        } else {
            theHeading -= 90.0;
        }
    }
    else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
        
        if( theHeading < 180.0 ) {
            theHeading += 180.0;
        } else {
            theHeading -= 180.0;
        }
    }

    //[self.headingLabel setString:[NSString stringWithFormat: @"Heading: %.0f°", theHeading]];
    
    if( ! bIsCourse ) {
        FirstCocos3DScene* scene = (FirstCocos3DScene*)self.cc3Scene;
    
        if( theHeading >= 0.0 ) {
            [scene setCourseHeading:theHeading withSpeed:self.speed];
            
            //[self.headingTypeLabel setString:[NSString stringWithFormat:@"Heading: %.f°", theHeading]];
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Failed with: %@", error.localizedDescription);
}


#pragma mark End of my shit
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
-(void) onCloseCC3Layer {

    NSLog(@"Going away ...");
    [_locationManager stopUpdatingLocation];
    [_locationManager stopUpdatingHeading];
}

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
