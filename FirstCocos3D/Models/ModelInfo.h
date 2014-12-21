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
    double maxGroundPitch;
    
    double maxRollDegrees;
    double maxWheelTurn;
    
    
    double groundPlaneY;
    
    double pitchOffset;
    double pitchWheelie;
    
    double currentPitchEmpty;
    double currentRoll;
    double currentWheelPos;
    double currentCourse;
    double currentSpeedPos;
    double currentSpeed;
    double currentGroundPitch;
    
    double groundPitchOffset;
    
    CC3Vector wheelsStraight;
    CC3Vector frontAxle;
    
    bool doWheelies;
    //bool useGyroScope;
    bool rotateGroundPlane;
    
} ModelInfo;

#endif
