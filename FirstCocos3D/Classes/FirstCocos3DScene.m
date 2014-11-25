/**
 *  FirstCocos3DScene.m
 *  FirstCocos3D
 *
 *  Created by David Mitchell on 9/6/14.
 *  Copyright David Mitchell 2014. All rights reserved.
 */

#import "FirstCocos3DScene.h"
#import "CC3PODResourceNode.h"
#import "CC3ActionInterval.h"
#import "CC3MeshNode.h"
#import "CC3Camera.h"
#import "CC3Light.h"
#import "CC3UtilityMeshNodes.h"
#import "CCActionManager.h"


@implementation FirstCocos3DScene

#pragma mark Global Variables
const CGFloat gMaxPitchDegreesForward = 1.6;
const CGFloat gMaxPitchDegreesBackward = -2.85;
const CGFloat gPitchIncrentBy = 1.0;
CGFloat gCurrentPitch = 0.0;
CGFloat gPitchOffset = 0.0;

//const CGFloat gMaxRollDegrees = 20.0; // Chevy HHR
const CGFloat gMaxRollDegrees = -2.8;   // Holden
const CGFloat gRollIncrementBy = 1.0;
CGFloat gCurrentRoll = 0.0;

const CGFloat gMaxWheelTurn = 30.0;
CGFloat gCurrentTurn = 0.0;

CC3Vector gStraight;
CGFloat gCurrentSpeedPos = 0.0;
CGFloat gCurrentSpeed = 0.0;


#pragma mark End Global Variables

/**
 * Constructs the 3D scene prior to the scene being displayed.
 *
 * Adds 3D objects to the scene, loading a 3D 'hello, world' message
 * from a POD file, and creating the camera and light programatically.
 *
 * When adapting this template to your application, remove all of the content
 * of this method, and add your own to construct your 3D model scene.
 *
 * You can also load scene content asynchronously while the scene is being displayed by
 * loading on a background thread. The
 *
 * NOTES:
 *
 * 1) To help you find your scene content once it is loaded, the onOpen method below contains
 *    code to automatically move the camera so that it frames the scene. You can remove that
 *    code once you know where you want to place your camera.
 *
 * 2) The POD file used for the 'hello, world' message model is fairly large, because converting a
 *    font to a mesh results in a LOT of triangles. When adapting this template project for your own
 *    application, REMOVE the POD file 'hello-world.pod' from the Resources folder of your project.
 */
-(void) initializeScene {

    self.manager = [[CMMotionManager alloc] init];
    [self.manager startAccelerometerUpdates];
    
    self->prevCourse = 0.0;
    self->prevSpeed = 0.0;
    
	// Optionally add a static solid-color, or textured, backdrop, by uncommenting one of these lines.
    //self.backdrop = [CC3Backdrop nodeWithColor: ccc4f(0.52, 0.8, 0.92, 1.0)];
	self.backdrop = [CC3Backdrop nodeWithTexture: [CC3Texture textureFromFile: @"Buildings_750x500.png"]];

    
	// Create the camera, place it back a bit, and add it to the scene
    CC3Camera* cam = [CC3Camera nodeWithName: @"Camera"];
	cam.location = cc3v( 0.0, 0.0, -15.0 );
	[self addChild: cam];

	// Create a light, place it back and to the left at a specific
	// position (not just directional lighting), and add it to the scene
	CC3Light* lamp = [CC3Light nodeWithName: @"Lamp"];
	lamp.location = cc3v( -2.0, 0.0, 0.0 );
	lamp.isDirectionalOnly = NO;
	[cam addChild: lamp];

    
	// Create and load a POD resource file and add its entire contents to the scene.
	// If needed, prior to adding the loaded content to the scene, you can customize the
	// nodes in the resource, remove unwanted nodes from the resource (eg- extra cameras),
	// or extract only specific nodes from the resource to add them directly to the scene,
	// instead of adding the entire contents.
    //self.rezNode = [CC3PODResourceNode nodeFromFile: @"Exportable Body - Ford Highboy - 01.pod"];
     self.bodyNode = [CC3PODResourceNode nodeFromFile: @"Exportable Body - Holden Efijy - 01.pod"];
    //self.bodyNode = [CC3PODResourceNode nodeFromFile: @"Exportable Body - Chevrolet HHR - 00.pod"];
    //self.bodyNode = [CC3PODResourceNode nodeFromFile: @"Chevrolet HHR - Linked.pod"];
	[self addChild: self.bodyNode];
    
    // Display the back sides because it looks strange, otherwise.
    self.bodyNode.shouldCullBackFaces = NO;
    
    // Bunch a
    self.wheelEmpty = [self.bodyNode getNodeNamed:@"WheelEmpty"];
    [self.bodyNode removeChild:self.wheelEmpty];
    [self addChild:self.wheelEmpty];
    [self printLocation:self.wheelEmpty.location withName:self.wheelEmpty.name];

    // Debugging: Remove Plane in
    CC3Node* plane = [self.bodyNode getNodeNamed:@"Plane"];
    if(plane != nil)
        [self.bodyNode removeChild:plane];

    self.nodeFRWheel = [self wheelFromNode:@"FRWheel"];
    self.nodeFLWheel = [self wheelFromNode:@"FLWheel"];
    self.nodeRRWheel = [self wheelFromNode:@"RRWheel"];
    self.nodeRLWheel = [self wheelFromNode:@"RLWheel"];
    
    gStraight = self.nodeFLWheel.rotation;
    
    self.groundPlaneNode = [CC3PODResourceNode nodeFromFile: @"Ground Plane.pod"];

    CC3Vector groundLocation = self.groundPlaneNode.location;
    groundLocation.y = -0.35;
    [self printLocation:self.groundPlaneNode.location withName:@"location"];
    [self.groundPlaneNode setLocation:groundLocation];
    [self addChild: self.groundPlaneNode];
    
    self.groundPlaneNode.visible = YES;
	// In some cases, PODs are created with opacity turned off by mistake. To avoid the possible
	// surprise of an empty scene, the following line ensures that all nodes loaded so far will
	// be visible. However, it also removes any translucency or transparency from the nodes, which
	// may not be what you want. If your model contains transparency or translucency, remove this line.
	self.opacity = kCCOpacityFull;
	
	// Select the appropriate shaders for each mesh node in this scene now. If this step is
	// omitted, a shaders will be selected for each mesh node the first time that mesh node is
	// drawn. Doing it now adds some additional time up front, but avoids potential pauses as
	// the shaders are loaded, compiled, and linked, the first time it is needed during drawing.
	// This is not so important for content loaded in this initializeScene method, but it is
	// very important for content loaded in the addSceneContentAsynchronously method.
	// Shader selection is driven by the characteristics of each mesh node and its material,
	// including the number of textures, whether alpha testing is used, etc. To have the
	// correct shaders selected, it is important that you finish configuring the mesh nodes
	// prior to invoking this method. If you change any of these characteristics that affect
	// the shader selection, you can invoke the removeShaders method to cause different shaders
	// to be selected, based on the new mesh node and material characteristics.
	[self selectShaders];

	// With complex scenes, the drawing of objects that are not within view of the camera will
	// consume GPU resources unnecessarily, and potentially degrading app performance. We can
	// avoid drawing objects that are not within view of the camera by assigning a bounding
	// volume to each mesh node. Once assigned, the bounding volume is automatically checked
	// to see if it intersects the camera's frustum before the mesh node is drawn. If the node's
	// bounding volume intersects the camera frustum, the node will be drawn. If the bounding
	// volume does not intersect the camera's frustum, the node will not be visible to the camera,
	// and the node will not be drawn. Bounding volumes can also be used for collision detection
	// between nodes. You can create bounding volumes automatically for most rigid (non-skinned)
	// objects by using the createBoundingVolumes on a node. This will create bounding volumes
	// for all decendant rigid mesh nodes of that node. Invoking the method on your scene will
	// create bounding volumes for all rigid mesh nodes in the scene. Bounding volumes are not
	// automatically created for skinned meshes that modify vertices using bones. Because the
	// vertices can be moved arbitrarily by the bones, you must create and assign bounding
	// volumes to skinned mesh nodes yourself, by determining the extent of the bounding
	// volume you need, and creating a bounding volume that matches it. Finally, checking
	// bounding volumes involves a small computation cost. For objects that you know will be
	// in front of the camera at all times, you can skip creating a bounding volume for that
	// node, letting it be drawn on each frame. Since the automatic creation of bounding
	// volumes depends on having the vertex location content in memory, be sure to invoke
	// this method before invoking the releaseRedundantContent method.
	[self createBoundingVolumes];
	
	// Create OpenGL buffers for the vertex arrays to keep things fast and efficient, and to
	// save memory, release the vertex content in main memory because it is now redundant.
	[self createGLBuffers];
	[self releaseRedundantContent];

	
	// ------------------------------------------
	
	// That's it! The scene is now constructed and is good to go.
	
	// To help you find your scene content once it is loaded, the onOpen method below contains
	// code to automatically move the camera so that it frames the scene. You can remove that
	// code once you know where you want to place your camera.
	
	// If you encounter problems displaying your models, you can uncomment one or more of the
	// following lines to help you troubleshoot. You can also use these features on a single node,
	// or a structure of nodes. See the CC3Node notes for more explanation of these properties.
	// Also, the onOpen method below contains additional troubleshooting code you can comment
	// out to move the camera so that it will display the entire scene automatically.
	
	// Displays short descriptive text for each node (including class, node name & tag).
	// The text is displayed centered on the pivot point (origin) of the node.
//	self.shouldDrawAllDescriptors = YES;
	
	// Displays bounding boxes around those nodes with local content (eg- meshes).
//	self.shouldDrawAllLocalContentWireframeBoxes = YES;
	
	// Displays bounding boxes around all nodes. The bounding box for each node
	// will encompass its child nodes.
//	self.shouldDrawAllWireframeBoxes = YES;
	
	// If you encounter issues creating and adding nodes, or loading models from
	// files, the following line is used to log the full structure of the scene.
	//LogInfo(@"The structure of this scene is: %@", [self structureDescription]);
	
	// ------------------------------------------
	// And to add some dynamism, we'll animate the 'hello, world' message
	// using a couple of actions...
    
    [self adjustPitch:false];
	
}

-(CC3Node*) wheelFromNode:(NSString*) nodeName {
    
    CC3Node* node = [self.wheelEmpty getNodeNamed:nodeName];
    //[node addAxesDirectionMarkers];

    //node.shouldDrawDescriptor = YES;
    [self printLocation:node.location withName: node.name];
    return node;
}

-(void) printLocation:(CC3Vector) position withName:(NSString*) info {
    
    NSLog(@"%@: x: %f, y: %f, z: %f", info, position.x, position.y, position.z);
}

/**
 * By populating this method, you can add add additional scene content dynamically and
 * asynchronously after the scene is open.
 *
 * This method is invoked from a code block defined in the onOpen method, that is run on a
 * background thread by the CC3Backgrounder available through the backgrounder property.
 * It adds content dynamically and asynchronously while rendering is running on the main
 * rendering thread.
 *
 * You can add content on the background thread at any time while your scene is running, by
 * defining a code block and running it on the backgrounder. The example provided in the
 * onOpen method is a template for how to do this, but it does not need to be invoked only
 * from the onOpen method.
 *
 * Certain assets, notably shader programs, will cause short, but unavoidable, delays in the
 * rendering of the scene, because certain finalization steps from shader compilation occur on
 * the main thread when the shader is first used. Shaders and certain other critical assets can
 * be pre-loaded and cached in the initializeScene method, prior to the opening of this scene.
 */
-(void) addSceneContentAsynchronously {}


#pragma mark Updating custom activity

/**
 * This template method is invoked periodically whenever the 3D nodes are to be updated.
 *
 * This method provides your app with an opportunity to perform update activities before
 * any changes are applied to the transformMatrix of the 3D nodes in the scene.
 *
 * For more info, read the notes of this method on CC3Node.
 */
-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {
}


/**
 * This template method is invoked periodically whenever the 3D nodes are to be updated.
 *
 * This method provides your app with an opportunity to perform update activities after
 * the transformMatrix of the 3D nodes in the scen have been recalculated.
 *
 * For more info, read the notes of this method on CC3Node.
 */

-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {
    
    [self.nodeFLWheel setRotation:gStraight];
    [self.nodeFRWheel setRotation:gStraight];
    
    gCurrentSpeedPos += 30.0 * gCurrentSpeed;
    
    [self.nodeFLWheel rotateByAngle:gCurrentSpeedPos aroundAxis:cc3v(1,0,0)];
    [self.nodeFLWheel rotateByAngle:gCurrentTurn aroundAxis:cc3v(0,0,1)];
    
    [self.nodeFRWheel rotateByAngle:gCurrentSpeedPos aroundAxis:cc3v(1,0,0)];
    [self.nodeFRWheel rotateByAngle:gCurrentTurn aroundAxis:cc3v(0,0,1)];
}


#pragma mark Scene opening and closing

/**
 * Callback template method that is invoked automatically when the CC3Layer that
 * holds this scene is first displayed.
 *
 * This method is a good place to invoke one of CC3Camera moveToShowAllOf:... family
 * of methods, used to cause the camera to automatically focus on and frame a particular
 * node, or the entire scene.
 *
 * For more info, read the notes of this method on CC3Scene.
 */
-(void) onOpen {

	// Add additional scene content dynamically and asynchronously, on a background thread
	// after rendering has begun on the rendering thread, using the CC3Backgrounder singleton.
	// Asynchronous loading must be initiated after the scene has been attached to the view.
	// It cannot be started in the initializeScene method. However, it does not need to be
	// invoked only from the onOpen method. You can use the code in the line here as a template
	// for use whenever your app requires background content loading after the scene has opened.
	[CC3Backgrounder.sharedBackgrounder runBlock: ^{ [self addSceneContentAsynchronously]; }];

	// Move the camera to frame the scene. The resulting configuration of the camera is output as
	// an [info] log message, so you know where the camera needs to be in order to view your scene.
    [self.activeCamera moveWithDuration: 1.0 toShowAllOf: self.bodyNode withPadding: 0.1f];
    //[self.activeCamera moveWithDuration:0.5 toShowAllOf:self.bodyNode withPadding:0.1f];

	// Uncomment this line to draw the bounding box of the scene.
//	self.shouldDrawWireframeBox = YES;
}

/**
 * Callback template method that is invoked automatically when the CC3Layer that
 * holds this scene has been removed from display.
 *
 * For more info, read the notes of this method on CC3Scene.
 */
-(void) onClose {

    //[self.locationManager stopUpdatingLocation];
    [self.manager stopAccelerometerUpdates];
}


#pragma mark Drawing

/**
 * Template method that draws the content of the scene.
 *
 * This method is invoked automatically by the drawScene method, once the 3D environment has
 * been established. Once this method is complete, the 2D rendering environment will be
 * re-established automatically, and any 2D billboard overlays will be rendered. This method
 * does not need to take care of any of this set-up and tear-down.
 *
 * This implementation simply invokes the default parent behaviour, which turns on the lighting
 * contained within the scene, and performs a single rendering pass of the nodes in the scene 
 * by invoking the visit: method on the specified visitor, with this scene as the argument.
 * Review the source code of the CC3Scene drawSceneContentWithVisitor: to understand the
 * implementation details, and as a starting point for customization.
 *
 * You can override this method to customize the scene rendering flow, such as performing
 * multiple rendering passes on different surfaces, or adding post-processing effects, using
 * the template methods mentioned above.
 *
 * Rendering output is directed to the render surface held in the renderSurface property of
 * the visitor. By default, that is set to the render surface held in the viewSurface property
 * of this scene. If you override this method, you can set the renderSurface property of the
 * visitor to another surface, and then invoke this superclass implementation, to render this
 * scene to a texture for later processing.
 *
 * When overriding the drawSceneContentWithVisitor: method with your own specialized rendering,
 * steps, be careful to avoid recursive loops when rendering to textures and environment maps.
 * For example, you might typically override drawSceneContentWithVisitor: to include steps to
 * render environment maps for reflections, etc. In that case, you should also override the
 * drawSceneContentForEnvironmentMapWithVisitor: to render the scene without those additional
 * steps, to avoid the inadvertenly invoking an infinite recursive rendering of a scene to a
 * texture while the scene is already being rendered to that texture.
 *
 * To maintain performance, by default, the depth buffer of the surface is not specifically
 * cleared when 3D drawing begins. If this scene is drawing to a surface that already has
 * depth information rendered, you can override this method and clear the depth buffer before
 * continuing with 3D drawing, by invoking clearDepthContent on the renderSurface of the visitor,
 * and then invoking this superclass implementation, or continuing with your own drawing logic.
 *
 * Examples of when the depth buffer should be cleared are when this scene is being drawn
 * on top of other 3D content (as in a sub-window), or when any 2D content that is rendered
 * behind the scene makes use of depth drawing. See also the closeDepthTestWithVisitor:
 * method for more info about managing the depth buffer.
 */
-(void) drawSceneContentWithVisitor: (CC3NodeDrawingVisitor*) visitor {
	[super drawSceneContentWithVisitor: visitor];
}


#pragma mark Handling touch events 

/**
 * This method is invoked from the CC3Layer whenever a touch event occurs, if that layer
 * has indicated that it is interested in receiving touch events, and is handling them.
 *
 * Override this method to handle touch events, or remove this method to make use of
 * the superclass behaviour of selecting 3D nodes on each touch-down event.
 *
 * This method is not invoked when gestures are used for user interaction. Your custom
 * CC3Layer processes gestures and invokes higher-level application-defined behaviour
 * on this customized CC3Scene subclass.
 *
 * For more info, read the notes of this method on CC3Scene.
 */

-(void) touchEvent: (uint) touchType at: (CGPoint) touchPoint {

    if( touchType == 0 ) {
        
        const CGSize s = [CCDirector sharedDirector].viewSize;
        const CGFloat widthDivisionSize = s.width/3.0;
        const CGFloat heightDivisionsize = s.height/3.0;
        int widthSection = -2;
        int heightSection = -2;
        
        //NSLog(@"touchPoint.x: %f, touchPoint.y: %f", touchPoint.x, touchPoint.y);
        // When heightSection == -1, Turning
        // When heightSection ==  0, Changing Speed
        // Nothing for when heightSection == 1.
        
        if(touchPoint.x <= widthDivisionSize)
            widthSection = -1;
        else if(touchPoint.x <= (widthDivisionSize*2))
            widthSection = 0;
        else
            widthSection = 1;
        
        if(touchPoint.y <= heightDivisionsize)
            heightSection = -1;
        else if( touchPoint.y <= (heightDivisionsize*2))
            heightSection = 0;
        else if( touchPoint.y <= s.height)
            heightSection = 1;
        else
            NSLog(@"WTF?: %f", s.height);
        
        if(heightSection == -1) { // Pitch
            
            if(widthSection == -1) { // Backward
                
                gCurrentPitch += gPitchIncrentBy;
                gCurrentPitch = MIN(gCurrentPitch, gMaxPitchDegreesForward);
                
            } else if(widthSection == 0) { // Reset Straight
                
                gCurrentPitch = 0.0;
                
            } else { // Forward

                gCurrentPitch -= gPitchIncrentBy;
                gCurrentPitch = MAX(gCurrentPitch, -gMaxPitchDegreesForward);
            }
            
        } else if(heightSection == 0) {
            
            if(widthSection == -1) { // Roll Left

                gCurrentRoll += gRollIncrementBy;
                gCurrentRoll = MIN(gCurrentRoll, gMaxRollDegrees);

            } else if(widthSection == 0) { // Reset Roll

                gCurrentRoll = 0.0;
                
            } else { // Roll Right

                gCurrentRoll -= gRollIncrementBy;
                gCurrentRoll = MAX(gCurrentRoll, -gMaxRollDegrees);
            }
            
        } else {
            
            if(widthSection == -1) {
                
                self.layer->bIsCourse = !self.layer->bIsCourse;
                NSLog(@"bIsCourse: %d", self.layer->bIsCourse);
            }
            else if(widthSection == 0) {

                [self adjustPitch:true];
            }
            else {
                
                [self adjustPitch:false];
            }
        }
    }
}

-(void) adjustPitch:(BOOL) reset {
    
    if(reset) {
        
        gPitchOffset = 0.0;
        NSLog(@"Resetting gPitchOffset to 0");
    } else {
        
        const CMAcceleration acceleration = self.manager.accelerometerData.acceleration;
        
        gPitchOffset = acceleration.z * 10;
        
        NSLog(@"Setting gPitchOffset to %f", gPitchOffset);
    }
}

/**
 * A method for setting the course heading. Includes speed, so that one can
 * take actions based on velocity.
 */
-(void) setCourseHeading:(double)course withSpeed:(double)speed {

//    if( speed > 0.0 )
        [self animateBody];
    
//    if( ! [self shouldChangeCourse:course] ) {
//        NSLog(@"Not changing course");
//        return;
//    }
//    
//    NSLog(@"Changing course");
    
    [self doDraw:course withSpeed:speed];
    
    self->prevSpeed = speed;
}

#pragma mark Draw the Scene

/**
 * Draws stuff to the screen for this scene.
 */
-(void) doDraw:(double)course withSpeed:(double) speed {

    // Store the speed
    gCurrentSpeed = speed;
    
    course = [self convertCourseToSimple:course];
    
    //self->prevCourse = course;
    //NSLog(@"Corrected course: %f", course);
    NSLog(@"Current Pitch: %f, Roll: %f, Wheel Pos: %f", gCurrentPitch, gCurrentRoll, gCurrentTurn);

    const double durationSpeed = 0.5;
    
    [self.bodyNode runAction: [CC3ActionRotateTo actionWithDuration:durationSpeed rotateTo:cc3v(gCurrentPitch, course, gCurrentRoll)]];
    [self.groundPlaneNode runAction: [CC3ActionRotateTo actionWithDuration:durationSpeed rotateTo:cc3v(0, course, 0)]];
    
    [self.nodeRLWheel runAction: [CC3ActionRotateForever actionWithRotationRate: cc3v(30.0 * speed, 0.0, 0.0)]];
    [self.nodeRRWheel runAction: [CC3ActionRotateForever actionWithRotationRate: cc3v(30.0 * speed, 0.0, 0.0)]];
    
    [self.wheelEmpty runAction: [CC3ActionRotateTo actionWithDuration:durationSpeed rotateTo:cc3v(270, course, 0)]];
}

-(void) animateBody {
    
    if(self.manager == nil) {
        NSLog(@"CMMotionManager not available");
        return;
    }
    
    const CMAcceleration acceleration = self.manager.accelerometerData.acceleration;
    const double action = CLAMP((1.0-acceleration.x) * 0.55, 0.0, 0.125);
    
    //NSLog(@"action: %f, x: %f, y: %f, z: %f", action , 1.0-acceleration.x, acceleration.y, acceleration.z);
    
    CCActionInterval* actionUp = [CC3ActionMoveUpBy actionWithDuration:0.05 moveBy:action];
    CCActionInterval* actionDown = [CC3ActionMoveUpBy actionWithDuration:0.15 moveBy:-action];
    
    [self.bodyNode runAction: [CCActionSequence actionOne: actionUp two: actionDown]];
    
    // gPitchOffset adjusts the pitch, which kind of corrects the original model.
    gCurrentPitch = MAX(MIN((acceleration.z * -10) + gPitchOffset, gMaxPitchDegreesForward),gMaxPitchDegreesBackward);
    
    gCurrentRoll  = MAX(MIN(acceleration.y * 10, gMaxRollDegrees), -gMaxRollDegrees);
    
    gCurrentTurn = MAX(MIN(gCurrentRoll * 20, gMaxWheelTurn), -gMaxWheelTurn);
    
}


-(BOOL) shouldChangeCourse:(double) course {

    // Do calcs
    const double distance = abs(course - self->prevCourse);

    //NSLog(@"Distance: %f", distance);
    return(distance > 15.0 && distance < 345.0);
}

-(double) convertCourseToSimple:(double) course {
    
    course = 360.0 - course;
    
    return course;
    const double extra = 0.0;
    
    if(course >= 271.0 + extra)
        course = 315.0;
    else if(course >= 181.0 + extra)
        course =  225.0;
    else if(course >= 91.0 + extra)
        course =  135.0;
    else if(course >= extra)
        course = 45.0;
 
    self->prevCourse = course;

    return course;
}

/**
 * This callback template method is invoked automatically when a node has been picked
 * by the invocation of the pickNodeFromTapAt: or pickNodeFromTouchEvent:at: methods,
 * as a result of a touch event or tap gesture.
 *
 * Override this method to perform activities on 3D nodes that have been picked by the user.
 *
 * For more info, read the notes of this method on CC3Scene.
 */
-(void) nodeSelected: (CC3Node*) aNode byTouchEvent: (uint) touchType at: (CGPoint) touchPoint {

}

@end

