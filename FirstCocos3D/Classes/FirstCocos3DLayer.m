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
@property (strong, nonatomic) RunningAverage *runningAvg;
@property (strong, nonatomic) RunningAverage *headingRunningAvg;
@property (strong, nonatomic) KalmanFilter *kalmanHeading;

@end

@implementation FirstCocos3DLayer

/**
 * Override to set up your 2D controls and other initial state, and to initialize update processing.
 *
 * For more info, read the notes of this method on CC3Layer.
 */
-(void) initializeControls {
    
	//[self scheduleUpdate];
    
    self.userInteractionEnabled = YES;
    [self setTouchEnabled:YES];
    
    self.mphLabel = [CCLabelTTF labelWithString:@"Speed:" fontName:@"Verdana-Bold" fontSize:18.0f];
    self.mphLabel.positionType = CCPositionTypeNormalized;
    self.mphLabel.position = ccp(0.15f, 0.96f);
    [self addChild:self.mphLabel];
    
    self.altitudeLabel = [CCLabelTTF labelWithString:@"Altitude: " fontName:@"Verdana-Bold" fontSize:18.0f];
    self.altitudeLabel.positionType = CCPositionTypeNormalized;
    self.altitudeLabel.position = ccp(0.15f, 0.9f);
    [self addChild:self.altitudeLabel];
    
    self.courseLabel = [CCLabelTTF labelWithString:@"Course: " fontName:@"Verdana-Bold" fontSize:18.0f];
    self.courseLabel.positionType = CCPositionTypeNormalized;
    self.courseLabel.position = ccp(0.15f, 0.84f);
    [self addChild:self.courseLabel];
    
    self.headingLabel = [CCLabelTTF labelWithString:@"Heading: " fontName:@"Verdana-Bold" fontSize:18.0f];
    self.headingLabel.positionType = CCPositionTypeNormalized;
    self.headingLabel.position = ccp(0.15f, 0.78f);
    [self addChild:self.headingLabel];
    
    self.headingTypeLabel = [CCLabelTTF labelWithString:@"Type: " fontName:@"Verdana-Bold" fontSize:18.0f];
    self.headingTypeLabel.positionType = CCPositionTypeNormalized;
    self.headingTypeLabel.position = ccp(0.8f, 0.025f);
    [self addChild:self.headingTypeLabel];
    
    
    // new shit
    self.runningAvg = [[RunningAverage alloc] initWithAvgLength:2];
    self.headingRunningAvg = [[RunningAverage alloc] initWithAvgLength:2];
    self.kalmanHeading = [[KalmanFilter alloc] init];
    
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
    CLLocation *oldLocation;
    
    if (locations.count > 1) {
        oldLocation = [locations objectAtIndex:locations.count-2];
    } else {
        oldLocation = nil;
    }
    
    CLLocationSpeed speed = [newLocation speed];
    CLLocationDistance altitude = [newLocation altitude] * 3.2808399; // Convert meters to feet
    CLLocationDirection course = [newLocation course];
    
    //CLLocationDistance distanceChange = [newLocation distanceFromLocation:oldLocation];
    //NSTimeInterval sinceLastUpdate = [newLocation.timestamp timeIntervalSinceDate:oldLocation.timestamp];
    //double calculatedSpeed = distanceChange / sinceLastUpdate;
    
    if( speed <= 0.0 ) {
        speed = 0.0;
    }
    else {
        speed *= 2.23694; // Convert KPH to MPH
    }
    
    double average = [self.runningAvg get:speed];
    //double kspeed = [self.kalmanSpeed get:speed];
    
    //NSLog(@"didUpdateToLocation %@ from %@. MPH %f. Avg %f. Altitude: %.2f\"",
    //      newLocation, oldLocation, speed, average, altitude);
    
    [self.mphLabel setString:[NSString stringWithFormat:@"Speed: %3.0f MPH, Avg: %3.0f MPH", speed, average]];
    
    if( course == -1 )
        [self.courseLabel setString:@"Course: N/A"];
    else
        [self.courseLabel setString:[NSString stringWithFormat: @"Course: %3.0f°", course]];
    [self.altitudeLabel setString:[NSString stringWithFormat: @"Alt: %3.0f'", altitude]];
    
//    FirstCocos3DScene* scene = (FirstCocos3DScene*)self.cc3Scene;
//    
//    if( course >= 0.0 )
//        [scene setCourseHeading: course];
    //[self.headingTypeLabel setString:@"Type: "];
    
//    double kheading = [self.kalmanHeading get:course];
//    [self.headingTypeLabel setString:[NSString stringWithFormat:@"kheading: %.f°", kheading]];
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

    [self.headingLabel setString:[NSString stringWithFormat: @"Heading: %.0f°", theHeading]];
    
    FirstCocos3DScene* scene = (FirstCocos3DScene*)self.cc3Scene;
    
    double avgHeading = [self.headingRunningAvg get:theHeading];
    [self.headingTypeLabel setString:[NSString stringWithFormat:@"AvgHdng: %.f°", avgHeading]];
    
    if( avgHeading >= 0.0 )
        [scene setCourseHeading:avgHeading];
    
//    double kheading = [self.kalmanHeading get:theHeading];
//    [self.headingTypeLabel setString:[NSString stringWithFormat:@"kheading: %.f°", kheading]];
//    if( kheading >= 0.0 )
//        [scene setCourseHeading:kheading];
    
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
