//
//  ModelInfo.h
//  FirstCocos3D
//
//  Created by David Mitchell on 12/2/14.
//  Copyright (c) 2014 David Mitchell. All rights reserved.
//

#ifndef FirstCocos3D_ModelInfo_h
#define FirstCocos3D_ModelInfo_h

typedef struct _modelInfo {
    
    double maxPitchDegreesForward;
    double maxPitchDegreesBackward;
    double maxPitchWheelie;
    
    double maxRollDegrees;
    double maxWheelTurn;
    double groundPlaneY;
    
    bool doesWheelies;
    
} ModelInfo;


const CGFloat gMaxPitchDegreesForward = 1.4;
//const CGFloat gMaxPitchDegreesBackward = -2.85; // Holden
const CGFloat gMaxPitchDegreesBackward = -2.35; // Holden
const CGFloat gMaxPitchWheelie = 30.0; // Max 30 degrees of wheelie

//const CGFloat gMaxRollDegrees = 20.0; // Chevy HHR
const CGFloat gMaxRollDegrees = -2.8;   // Holden
const CGFloat gMaxWheelTurn = 40.0;
const CGFloat gGroundPlaneY = -0.35;

#endif
