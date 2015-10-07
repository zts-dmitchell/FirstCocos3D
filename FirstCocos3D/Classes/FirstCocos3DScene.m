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

#import "EmptyFilter.h"
#import "KalmanFilter.h"
#import "ExponentialMovingAverage.h"
#import "SimpleMovingAverage.h"
#import "PaintBooth.h"

@implementation FirstCocos3DScene

#pragma mark Global Variables
const CGFloat gMaxPitchDegreesForward = 0.5;
//const CGFloat gMaxPitchDegreesBackward = -2.85; // HHR

//const CGFloat gMaxPitchDegreesBackward = -2.35; // Holden
const CGFloat gMaxPitchDegreesBackward = -0.35; // Holden

const CGFloat gMaxPitchWheelie = 30.0; // Max 30 degrees of wheelie

//const CGFloat gMaxRollDegrees = 20.0; // Chevy HHR
const CGFloat gMaxRollDegrees = -2.8;   // Holden
const CGFloat gMaxWheelTurn = 40.0;
const CGFloat gHeaderEmissionMinSpeed = 30.0;
CGFloat gGasserPitch = 0.0;

const CGFloat gGroundPlaneY = 2.14515;

CGFloat gCurrentPitchEmpty = 0.0;
CGFloat gPitchOffset = 0.0;
CGFloat gPitchWheelie = 0.0;
CGFloat gCurrentRoll = 0.0;
CGFloat gCurrentWheelPos = 0.0;
CGFloat gCurrentCourse = 0.0;
CGFloat gCurrentSpeedPos = 0.0;
CGFloat gCurrentSpeed = 0.0;

CGFloat gMaxGroundPitch = 25.0; // degrees;

CC3Vector gStraight;
CC3Vector gFrontAxle;

bool gRotateGroundPlane = false;

// Real Globals
bool gUseGyroScope = true;
bool gDoWheelies = false;
bool gSelfHasActiveCamera = true;
bool gLockRotation = false;

CoolCarTypes gCoolCarType = Low;
bool gSkinnyTires = false;
CGFloat gFLWheel_x = 0.0;


const CGFloat cRightSideDown = 1;
const CGFloat cLeftSideDown = -1;
const CGFloat gRideAlongOrientation = cLeftSideDown;


#pragma mark End Global Variables

#pragma mark get/set default values
-(void) loadDefaults {
    NSLog(@"Loading Defaults");
    
    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    gLockRotation = [defaults boolForKey:@"gLockRotation"];
}

-(void) loadPostSetupDefaults {
    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Set these values *after* everything else has been setup.

    gCoolCarType  = (CoolCarTypes)[defaults integerForKey:@"gCoolCarType"];
    
    [self setCoolCarType:gCoolCarType];

    int colorPosition = (int)[defaults integerForKey:@"currentColorPosition"];
    
    [self.paintBooth setColorPosition:colorPosition];
    //NSArray *parts = @[ @"Main Body-submesh1", @"Main Body-submesh2", @"Trunk Lid"];
    NSArray *parts = @[ @"Main Body", @"Hood"];
    [self.paintBooth nextColor:parts inNode:self.rootCarNode];
    
    gCurrentCourse   = [defaults floatForKey:@"gCurrentCourse"];
    gCurrentWheelPos = [defaults floatForKey:@"gCurrentWheelPos"];
    gUseGyroScope =  [defaults boolForKey:@"gUseGyroScope"];
    gSkinnyTires = [defaults floatForKey:@"gSkinnyTires"];
    
    [self setWheelWidths];
}

-(void) storeDefaults {
    NSLog(@"Storing Defaults");
    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setBool:gLockRotation forKey:@"gLockRotation"];
    [defaults setDouble:gCurrentCourse forKey:@"gCurrentCourse"];
    [defaults setDouble:gCurrentWheelPos forKey:@"gCurrentWheelPos"];
    [defaults setDouble:gUseGyroScope forKey:@"gUseGyroScope"];
    
    [defaults setInteger:gCoolCarType forKey:@"gCoolCarType"];
    [defaults setInteger:[self.paintBooth getCurrentColorPosition] forKey:@"currentColorPosition"];
    
    [defaults setDouble:gSkinnyTires forKey:@"gSkinnyTires"];
}


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

    [self loadDefaults];
    
    self.manager = [[CMMotionManager alloc] init];
    [self.manager startAccelerometerUpdates];
    [self.manager startDeviceMotionUpdates];

    self->prevCourse = 0.0;
    
    //////////////////////////////////////////////////////////////////////////////////
    // The Ground Plane. The car body and related assemblies will be parented to this.
    //self.groundPlaneNode = [CC3PODResourceNode nodeFromFile: @"Ground Plane.pod"];
    self.groundPlaneNode = [CC3PODResourceNode nodeFromFile: @"Curved Ground.pod"];
    
    [self addChild:self.groundPlaneNode];
    
    // Get the background node, separate from ground, add as child.
    self.background = [self.groundPlaneNode getNodeNamed:@"Background"];
    [self.groundPlaneNode removeChild:self.background];
    [self addChild:self.background];

    //////////////////////////////////////////////////////////////////////////////////
    
	// Optionally add a static solid-color, or textured, backdrop, by uncommenting one of these lines.
    //self.backdrop = [CC3Backdrop nodeWithColor: ccc4f(0.52, 0.8, 0.92, 1.0)];
	//self.backdrop = [CC3Backdrop nodeWithTexture: [CC3Texture textureFromFile: @"Buildings_750x500.png"]];

    //////////////////////////////////////////////////////////////////////////////////
	// Create and load a POD resource file and add its entire contents to the scene.
	// If needed, prior to adding the loaded content to the scene, you can customize the
	// nodes in the resource, remove unwanted nodes from the resource (eg- extra cameras),
	// or extract only specific nodes from the resource to add them directly to the scene,
	// instead of adding the entire contents.
    //self.rootCarNode = [CC3PODResourceNode nodeFromFile: @"Exportable Body - Holden Efijy - 01.pod"];
    //self.rootCarNode = [CC3PODResourceNode nodeFromFile: @"Chevrolet HHR - Linked.pod"];
    //self.rootCarNode = [CC3PODResourceNode nodeFromFile: @"GoogleDriverLessCar.pod"];
    self.rootCarNode = [CC3PODResourceNode nodeFromFile: @"Chevy - C10.pod"];
    
    [self addChildToGroundPlane:self.rootCarNode];
    
    self.bodyNode = [self.rootCarNode getNodeNamed:@"Main Body"];
    //self.hoodNode = [self.bodyNode getNodeNamed:@"Main Body-submesh0-Mesh"];
    
    NSLog(@"Body node details: %@", self.bodyNode.fullDescription);
    
    [self setInitialPartState];
    
    // Get the pitch empty for pitch rotations
    self.pitchEmpty = [self.rootCarNode getNodeNamed:@"PitchEmpty"];
    
    CC3Node* node2 = [self.rootCarNode getNodeNamed:@"Headlamps"];
    CC3MeshNode* m1 = node2.children[1];
    m1.emissionColor = kCCC4FWhite;
    m1.shininess = 128;
    m1.reflectivity = 1;

    node2 = [self.rootCarNode getNodeNamed:@"Taillight"];
    m1 = node2.children[1];
    //NSLog(@"Info 1: %@", m1.material.fullDescription);
    m1.emissionColor = kCCC4FRed;
    m1.shininess = 128.0;
    m1.reflectivity = 1.0;
    //NSLog(@"Info 2: %@", m1.material.fullDescription);
    
    
    // Bunch a
    self.wheelEmpty = [self.rootCarNode getNodeNamed:@"WheelEmpty"];
    [self.rootCarNode removeChild:self.wheelEmpty];
    [self addChildToGroundPlane:self.wheelEmpty];
    [self printLocation:self.wheelEmpty.location withName:self.wheelEmpty.name];

    self.frontAxle = [self.wheelEmpty getNodeNamed:@"Front Axle"];
    self.rearAxle = [self.wheelEmpty getNodeNamed:@"Rear Axle"];

    //////////////////////////////////////////////////////////////////////////////////
    // Add Camera Locations
    [self addCameras];
    
    //////////////////////////////////////////////////////////////////////////////////
    // The Coloring Object
    self.paintBooth = [[PaintBooth alloc] init];
    
    [self.paintBooth addColor:self.bodyNode.diffuseColor];
    //self.hoodN
    [self.paintBooth addColor:102 :0 :102];
    
    /*
    CC3MeshNode *mn = [self.rootCarNode getMeshNodeNamed:@"Front Window"];
    CC3Material *mat = mn.material;
    ccColor4F c = mat.ambientColor;
    c.a = 0.0;
    mat.ambientColor = kCCC4FBlack;
    
    c = mat.diffuseColor;
    c.a = 0.0;
    mat.diffuseColor = kCCC4FBlack;

    c = mat.specularColor;
    c.a = 0.0;
    mat.specularColor = kCCC4FWhite;
    
    c = mat.emissionColor;
    c.a = 0.0;
    mat.emissionColor = c;
    
    NSLog(@"Opacity of %@: %f. Is opaque? %d", mat.name, mat.opacity, mat.isOpaque);
    mat.opacity = 0.0;
    mat.isOpaque = YES;
    //mat.destinationBlendAlpha = GL_ONE_MINUS_SRC_ALPHA;
    
    mn = [self.rootCarNode getMeshNodeNamed:@"Front Window"];
    NSLog(@"Opacity of %@: %f. Is opaque? %d. Alpha: %f", mn.name, mn.opacity, mn.isOpaque, mn.diffuseColor.a);
    */
    self.headersNode = [self.rootCarNode getNodeNamed:@"Headers"];
    
    //////////////////////////////////////////////////////////////////////////////////
    // Already in low-body position.
    self.lowBodyLocation = self.pitchEmpty.location;
    //self.gasserBodyLocation = cc3v(0, -0.01257, 4.07566); // Y and Z are swapped

    // For Elijy
    //self.gasserBodyLocation = cc3v(0, -0.3, 4.07566); // Y and Z are swapped

    // For C10
    self.superLowBodyLocation = self.lowBodyLocation;
    self.superLowBodyLocation = cc3v(self.lowBodyLocation.x, -0.07566, self.lowBodyLocation.z);
    self.gasserBodyLocation = cc3v(0, 0.1, 4.07566); // Y and Z are swapped
    
    // Debugging: Remove Plane in
    CC3Node* plane = [self.rootCarNode getNodeNamed:@"Plane"];
    if(plane != nil)
        [self.rootCarNode removeChild:plane];

    self.nodeFRWheel = [self wheelFromNode:@"FRWheel"];
    self.nodeFLWheel = [self wheelFromNode:@"FLWheel"];
    self.nodeRRWheel = [self wheelFromNode:@"RRWheel"];
    self.nodeRLWheel = [self wheelFromNode:@"RLWheel"];
    
    [self.paintBooth saveMaterial:@"BR_White_Wall" inNode:self.nodeRLWheel];
    [self.paintBooth saveMaterial:@"BR_Black_Rubber" inNode:self.nodeRLWheel];
    [self.paintBooth storeMeshNodeByMaterialName:@"BR_White_Wall" inNode:self.nodeRLWheel];
    [self.paintBooth storeMeshNodeByMaterialName:@"BR_Tan_Body" inNode:self.bodyNode];
    //[self.paintBooth saveMaterial:@"BR_Tan_Body" inNode:self.pitchEmpty];
    
    [self.paintBooth swapMaterialsInNode:self.bodyNode withMaterial:@"BR_Hood" with:@"BR_Tan_Body"];
    
    gStraight = self.nodeFLWheel.rotation;
    gFrontAxle = self.frontAxle.location;
    gFLWheel_x = self.nodeFLWheel.location.x;
    
    // Display the back sides because it looks strange, otherwise.
    self.rootCarNode.shouldCullBackFaces = NO;
    
    //////////////////////////////////////////////////////////////////////////////////
    // F I L T E R S
    self.wheelTurningFilter = [[ExponentialMovingAverage alloc] initWithNumberOfPeriods:7];
    self.courseFilter  = [[ExponentialMovingAverage alloc] initWithNumberOfPeriods:11];
    self.upDownBodyMotionFilter = [[ExponentialMovingAverage alloc] initWithNumberOfPeriods:3];
    self.rollFilter = [[ExponentialMovingAverage alloc] initWithNumberOfPeriods:22];
    self.pitchFilter = [[ExponentialMovingAverage alloc] initWithNumberOfPeriods:22];
    self.wheelieFilter = [[ExponentialMovingAverage alloc] initWithNumberOfPeriods:3];
    self.groundPlaneGyroFilter = [[KalmanFilter alloc] init];
    //self.groundPlaneGyroFilter = [[ExponentialMovingAverage alloc] initWithNumberOfPeriods:22];
    //self.groundPlaneGyroFilter = [[SimpleMovingAverage alloc] initWithAvgLength:22];
    //self.groundPlaneGyroFilter = [[EmptyFilter alloc] init];
    
    
    //self.rootCarNode.visible = NO;
    //self.groundPlaneNode.visible = NO;
    
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
 
    [self loadPostSetupDefaults];
    
}

// This method will eventually go in a protocol for cars.
-(void) setInitialPartState {
    
    // Get accessories
    self.hoodScoopNode = [self.rootCarNode getNodeNamed:@"Hood Scoop"];
    self.carbVelocityStacksNode = [self.rootCarNode getNodeNamed:@"Carb Velocity Stacks"];
    self.fuelCellNode = [self.rootCarNode getNodeNamed:@"Fuel Cell"];

    // Hide these, initially.
    [self.hoodScoopNode setUniformScale:0.0];
    [self.carbVelocityStacksNode setUniformScale:0.0];
    [self.fuelCellNode setUniformScale:0.0];
}

// Add some cameras.
-(void) addCameras {

    // Set up main camera
    //////////////////////////////////////////////////////////////////////////////////
    // Create the camera, place it back a bit, and add it to the scene
    CC3Camera* mainCamera = [CC3Camera nodeWithName: @"mainCamera"];
    //mainCamera.location = cc3v(0.0, 0.55 + gGroundPlaneY, 25.0);
    mainCamera.location = cc3v(14, -2.0 + gGroundPlaneY, -20.0);
    mainCamera.rotation = cc3v(4, 143, -12);
    self.activeCamera = mainCamera;
    [self addChild:mainCamera];
    
    // Create a light, place it back and to the left at a specific
    // position (not just directional lighting), and add it to the scene
    CC3Light* lamp = [CC3Light nodeWithName: @"Lamp"];
    lamp.location = cc3v( -2.0, 0.0, 0.0 );
    lamp.isDirectionalOnly = NO;
    [mainCamera addChild: lamp];
    
    self.cameras = [[Camera alloc] init];
    
    // Default camera.
    [self.cameras add:cc3v(0.0, 0.55 + gGroundPlaneY, 25.0)];

    [self.cameras add:cc3v(8.62, 2.033, 15.64) withRotation:cc3v(0, 34, 0.0) andFieldOfView:60.0];

    [self.cameras add:cc3v(-10.0, -0.55 + gGroundPlaneY, -12.0) withRotation:cc3v(0, 224, 0) andFieldOfView:60.0];

    // Attach the frontFenderCamera
    [self.cameras add:cc3v(5, -0.55 + gGroundPlaneY, 15.0) withRotation:cc3v(0, 15, 0)];
    
    // Pointing at front wheel
    [self.cameras add:cc3v(10, -0.55 + gGroundPlaneY, -2.0) withRotation:cc3v(0, 45+90, 0)];
    
    // Attach the rearFenderCamera
    [self.cameras add:cc3v(6, -2.0 + gGroundPlaneY, -15.0) withRotation:cc3v(5, 170, 0)];
    
    // Above from rear
    [self.cameras add:cc3v(0.0, 35.0 + gGroundPlaneY, 35.0) withRotation:cc3v(-45, 0, 0)];
    
    // Add driver position camera
    [self.cameras add:cc3v(14.34841, -1.5 + gGroundPlaneY, 10.64886) withRotation:cc3v(4, 57.693, 0) andFieldOfView:60];
    
    // Create the rearFarCamera
    [self.cameras add:cc3v(14, -2.0 + gGroundPlaneY, -20.0) withRotation:cc3v(4, 143, -12)];

}

-(void) addChildToGroundPlane:(CC3Node*) node {

    CC3Vector location = node.location;
    
    NSString* fmt = [NSString stringWithFormat:@"Before: %@", node.name];
    
    [self printLocation:location withName:fmt];
    location.y += gGroundPlaneY;

    fmt = [NSString stringWithFormat:@"After adding %f: %@", gGroundPlaneY, node.name];
    [self printLocation:location withName:fmt];

    [node setLocation:location];
    
    [self.groundPlaneNode addChild:node];
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

    [self storeRotationsAndAnimateBody];
    [self rotateNodesToCourse];
    
    // TODO: There's got to be a better way.
    // Front Wheel stuff
    [self.nodeFLWheel setRotation:gStraight];
    [self.nodeFRWheel setRotation:gStraight];
    
    // Set rears, too, so that they don't spin.
    [self.nodeRLWheel setRotation:gStraight];
    [self.nodeRRWheel setRotation:gStraight];
    
    gCurrentSpeedPos += gCurrentSpeed;
    
    //////////////////////////////////////////////////////////////////////////
    // Spin the Wheels Forwards (doesn't do backwards)
    // Set rotation about x *before* rotation about z!!!
    [self.nodeFLWheel rotateByAngle:gCurrentSpeedPos aroundAxis:cc3v(1,0,0)];
    [self.nodeFRWheel rotateByAngle:gCurrentSpeedPos aroundAxis:cc3v(1,0,0)];
    
    // Turn wheels between left and right positions.
    [self.nodeFLWheel rotateByAngle: gRideAlongOrientation * gCurrentWheelPos aroundAxis:cc3v(0,0,1)];
    [self.nodeFRWheel rotateByAngle: gRideAlongOrientation * gCurrentWheelPos aroundAxis:cc3v(0,0,1)];
 
    [self.pitchEmpty setRotation:cc3v(gCurrentPitchEmpty - gPitchWheelie, 0, 0)];
    
    [self.nodeRLWheel rotateByAngle:gCurrentSpeedPos aroundAxis:cc3v(1,0,0)];
    [self.nodeRRWheel rotateByAngle:gCurrentSpeedPos aroundAxis:cc3v(1,0,0)];
}

-(void) storeRotationsAndAnimateBody {
    
    const CMAcceleration acceleration = self.manager.accelerometerData.acceleration;
    const double action = [self.upDownBodyMotionFilter get:CLAMP((1.0+acceleration.x) * 0.55, 0.0, 0.125)];
    
    // Up/down the body
    CCActionInterval* actionUp = [CC3ActionMoveUpBy actionWithDuration:0.05 moveBy:action];
    CCActionInterval* actionDown = [CC3ActionMoveUpBy actionWithDuration:0.05 moveBy:-action];
    [self.rootCarNode runAction:[CCActionSequence actionOne:actionUp two:actionDown]];
    
    // gPitchOffset adjusts the pitch, which kind of corrects the original model.
    gCurrentPitchEmpty = MIN(([self.pitchFilter get:acceleration.z] * -10.0) + gPitchOffset, gMaxPitchDegreesForward);
    
    if(gDoWheelies) {
        if(gCurrentPitchEmpty < (gMaxPitchDegreesBackward) ) {
            gPitchWheelie = [self.wheelieFilter get:fabs(gCurrentPitchEmpty - (gMaxPitchDegreesBackward))];
        }
    } else {
        gCurrentPitchEmpty = MAX(gCurrentPitchEmpty, gMaxPitchDegreesBackward);
    }
    
    gCurrentPitchEmpty += gGasserPitch;

    gCurrentRoll = gRideAlongOrientation * CLAMP([self.rollFilter get:acceleration.y] * 10.0, gMaxRollDegrees, -gMaxRollDegrees);
    
    // Speed and turn factoring
    const double speedFactor = getFactorFromSpeed();
    const double scaledWheelPosCosFactor = speedFactor * gMaxWheelTurn * 2;
    
    if(gLockRotation) {
        
    } else if(! self.layer->bIsHeading) {
        
        if(gUseGyroScope) {
            
            CMDeviceMotion *deviceMotion = self.manager.deviceMotion;
            CMAttitude *attitude = deviceMotion.attitude;
            gCurrentCourse = CC_RADIANS_TO_DEGREES(attitude.yaw);
            
        } else {
            
            gCurrentCourse += [self.courseFilter get:acceleration.y] * speedFactor * 3.5 * gRideAlongOrientation;
        }
    }
    
    gCurrentWheelPos = CLAMP([self.wheelTurningFilter get:acceleration.y] * scaledWheelPosCosFactor, -gMaxWheelTurn, gMaxWheelTurn);
    //NSLog(@"acceleration.y: %f, CurrentWheelPos: %f", acceleration.y, gCurrentWheelPos);
    //NSLog(@"acceleration.y: %f, speedFactor: %f, scaledWheelPosCosFactor: %f", acceleration.y, speedFactor, scaledWheelPosCosFactor);
    //NSLog(@"gCurrentCourse: %3.f, gLockRotation: %d", gCurrentCourse, gLockRotation);
}

-(void) rotateNodesToCourse {
    
    [self.frontAxle setLocation:gFrontAxle];
    
    // Rotate the ground by the current course.
    [self.groundPlaneNode setRotation:cc3v(0, /*gRideAlongOrientation */ gCurrentCourse, 0)];
    
    CC3Vector vector = self.groundPlaneNode.rotation;
    
    // Rotate the ground when self has active camera.
    if(gSelfHasActiveCamera) {
        
        CC3Vector gr = self.background.rotation;
        gr.y = gRideAlongOrientation * vector.y;
        
        [self.background setRotation:gr];
    }
    
    // TODO: Decide whether to keep " ... + gPitchWheelie" here.
    [self.rootCarNode setRotation:cc3v(vector.x + gPitchWheelie, 0, gCurrentRoll)];
    
    if(!gDoWheelies)
        return;
    
    const double sin_theta = sin(CC_DEGREES_TO_RADIANS(gPitchWheelie));
    const double cos_theta = cos(CC_DEGREES_TO_RADIANS(gPitchWheelie));
    
    CC3Vector pxpy = self.frontAxle.location;
    CC3Vector oxoy = self.rearAxle.location;
    
    const double pz = cos_theta * (pxpy.z-oxoy.z) - sin_theta * (pxpy.y-oxoy.y) + oxoy.z;
    const double py = sin_theta * (pxpy.z-oxoy.z) + cos_theta * (pxpy.y-oxoy.y) + oxoy.y;
    
    /////////////////////////////////////////////
    // Set the left wheel
    vector = self.frontAxle.location;
    vector.y = py;
    vector.z = pz;
    
    self.frontAxle.location = vector;
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
    //[self.activeCamera moveWithDuration: 1.0 toShowAllOf: self.rootCarNode withPadding: 0.1f];
    //[self.activeCamera moveWithDuration:0.5 toShowAllOf:self.rootCarNode withPadding:0.1f];
    
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

-(void) touchEvent: (uint) touchType at: (CGPoint) touchPoint {

    if( touchType == 0 ) {
        
        //[self printLocation:self.groundPlaneNode];
        
        const CGSize s = [CCDirector sharedDirector].viewSize;
        const CGFloat widthDivisionSize = s.width/3.0;
        const CGFloat heightDivisionsize = s.height/3.0;
        int widthSection = -2;
        int heightSection = -2;
        
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
        
        if(heightSection == -1) { // Bottom 3rd
            
            if(widthSection == -1) { // Backward
                
                gLockRotation = !gLockRotation;
                
            } else if(widthSection == 0) { // Reset Straight

                gSkinnyTires = !gSkinnyTires;
                
                [self setWheelWidths];
                
            } else { // Forward

                [self setNextCarType];
            }
            
        } else if(heightSection == 0) {  // Middle 3rd
            
            if(widthSection == -1) { // Roll Left

                //NSArray *parts = @[ @"Main Body-submesh1", @"Main Body-submesh2", @"Trunk Lid"];
                NSArray *parts = @[ @"Main Body", @"Hood"];
                [self.paintBooth nextColor:parts inNode:self.rootCarNode];
                
                //self.layer->bIsHeading = !self.layer->bIsHeading;
                //[self.layer headingState:self.layer->bIsHeading];
                //NSLog(@"bIsHeading: %d", self.layer->bIsHeading);

            } else if(widthSection == 0) { // Reset Roll

                /*
                NSLog(@"Moving camera");
                CC3Vector initialPos = cc3v(8, 2, 150);
                CC3Vector endPos     = cc3v(1, 2, 20);
                
                self.activeCamera.location = initialPos;
                
                CCActionInterval* actOne = [CC3ActionMoveTo actionWithDuration:2.0 endVector:endPos];
                CCActionInterval* actTwo = [CC3ActionRotateToLookAt actionWithDuration:0.25 targetLocation:cc3v(0,0,0)];
                
                CCActionFiniteTime *time = [[CCActionFiniteTime alloc] init];
                time.duration = 0.0;
                [self.activeCamera runAction:[CCActionSequence actions:time, actOne, actTwo, nil]];
                 */
                
                //gDoWheelies = !gDoWheelies;
                // Reset the wheelie to zero, so wheels don't remain in the air.
                gPitchWheelie = 0.0;
                
            } else { // Roll Right

                gUseGyroScope = !gUseGyroScope;
                
            }
            
        } else {    // Top 3rd
            
            if(widthSection == -1) {

                [self.cameras transitionToNext:self.activeCamera];
            }
            else if(widthSection == 0) {
                
                [self move:self.activeCamera from:self to:self.groundPlaneNode];

                // When true, will rotate the 'Background' node.
                gSelfHasActiveCamera = false;
                
                // Other stuff
                [self adjustPitch:true]; // Resets w/o Accelerometer
            }
            else {
                
                [self move:self.activeCamera from:self.groundPlaneNode to:self];
                
                gSelfHasActiveCamera = true;
                // Other stuff
                [self adjustPitch:false];  // Sets w/Accelerometer
            }
        }
    }
    
    [self storeDefaults];
}

-(void) setNextCarType {
    
    // Calculate the next cool car type
    gCoolCarType = (gCoolCarType + 1) % 3;
    
    [self setCoolCarType:gCoolCarType];
}

/**
 * Sets the car type to one of the cool pre-sets.
 **/
-(void) setCoolCarType:(CoolCarTypes) type {

    if(self.hoodScoopNode == nil) {
       // return;
    }
    
    gCoolCarType = type;
    
    CC3Vector location = self.pitchEmpty.location;

    switch(type) {
            
        case Low:
            NSLog(@"Setting Low Body");
            
            gGasserPitch = 0.0;
            //location.y = self.lowBodyLocation.y;
            location = self.lowBodyLocation;
            [self.pitchEmpty runAction:[CC3ActionMoveTo actionWithDuration:0.5 moveTo:location]];

            //[self.nodeFLWheel runAction:[CC3ActionScaleTo actionWithDuration:0.5 scaleTo:cc3v(1,1,1)]];
            //[self.nodeFRWheel runAction:[CC3ActionScaleTo actionWithDuration:0.5 scaleTo:cc3v(1,1,1)]];

            // Used for Efijy
            [self.nodeFLWheel runAction:[CC3ActionMoveTo actionWithDuration:0.5 moveTo:cc3v(gFLWheel_x, 0, 0)]];
            [self.nodeFRWheel runAction:[CC3ActionMoveTo actionWithDuration:0.5 moveTo:cc3v(-gFLWheel_x, 0, 0)]];
            
            //[self.paintBooth changeColor:@"BR_White_Wall" toColor:kCCC4FWhite];
            
            if(self.hoodScoopNode != nil) {
                [self.hoodScoopNode runAction:[CC3ActionScaleTo actionWithDuration:0.5 scaleUniformlyTo:0.0]];
                [self.carbVelocityStacksNode runAction:[CC3ActionScaleTo actionWithDuration:0.5 scaleUniformlyTo:0.0]];
                [self.fuelCellNode runAction:[CC3ActionScaleTo actionWithDuration:0.5 scaleUniformlyTo:0.0]];
            }
            break;
            
        case LowDrag:
            NSLog(@"Setting (super) Low Drag Body");
            
            gGasserPitch = 0.0;
            //location.y = self.superLowBodyLocation.y;
            location = self.superLowBodyLocation;
            [self.pitchEmpty runAction:[CC3ActionMoveTo actionWithDuration:0.5 moveTo:location]];

            // Used for Efijy
            //[self.nodeFLWheel runAction:[CC3ActionScaleTo actionWithDuration:0.5 scaleTo:cc3v(0.55, 1.0, 1.0)]];
            //[self.nodeFRWheel runAction:[CC3ActionScaleTo actionWithDuration:0.5 scaleTo:cc3v(0.55, 1.0, 1.0)]];
            //[self.nodeFLWheel runAction:[CC3ActionMoveTo actionWithDuration:0.5 moveTo:cc3v(2.66, 0, 0)]];
            //[self.nodeFRWheel runAction:[CC3ActionMoveTo actionWithDuration:0.5 moveTo:cc3v(-2.66, 0, 0)]];
            //[self.paintBooth changeColor:@"BR_White_Wall" toColor:kCCC4FWhite];
            
            if(self.hoodScoopNode != nil) {
                [self.hoodScoopNode runAction:[CC3ActionScaleTo actionWithDuration:0.5 scaleUniformlyTo:1.0]];
                [self.carbVelocityStacksNode runAction:[CC3ActionScaleTo actionWithDuration:0.5 scaleUniformlyTo:1.0]];
                [self.fuelCellNode runAction:[CC3ActionScaleTo actionWithDuration:0.5 scaleUniformlyTo:0.0]];
            }
            break;
            
        case Gasser:
            NSLog(@"Setting Gasser Body");
           
            // For Efijy
            //gGasserPitch = -2.25;
            
            // For C10
            gGasserPitch = -1.75;
            
            location.y = self.gasserBodyLocation.y;
            [self.pitchEmpty runAction:[CC3ActionMoveTo actionWithDuration:0.5 moveTo:location]];
     
            // Used for Efijy
            //[self.nodeFLWheel runAction:[CC3ActionMoveTo actionWithDuration:0.5 moveTo:cc3v(2.94, 0, -0.2)]];
            //[self.nodeFRWheel runAction:[CC3ActionMoveTo actionWithDuration:0.5 moveTo:cc3v(-2.94, 0, -0.2)]];
            //[self.nodeFLWheel runAction:[CC3ActionScaleTo actionWithDuration:0.5 scaleTo:cc3v(0.55, 0.8, 0.8)]];
            //[self.nodeFRWheel runAction:[CC3ActionScaleTo actionWithDuration:0.5 scaleTo:cc3v(0.55, 0.8, 0.8)]];
            
            //[self.frontAxle runAction:[CC3ActionMoveTo actionWithDuration:0.5 moveTo:cc3v(0, 0, -03.2)]];
            ///[self.paintBooth swapMaterialsInNode:self.nodeRLWheel withMaterial:@"BR_White_Wall" with:@"BR_Black_Rubber"];
            //[self.paintBooth changeColor:@"BR_White_Wall" toColor:kCCC4FBlack];
            //[self.paintBooth changeColor:@"BR_Hood" toColor:kCCC4FBlack];
            
            if(self.hoodScoopNode != nil) {

                [self.hoodScoopNode runAction:[CC3ActionScaleTo actionWithDuration:0.5 scaleUniformlyTo:0.0]];
                [self.carbVelocityStacksNode runAction:[CC3ActionScaleTo actionWithDuration:0.5 scaleUniformlyTo:1.2]];
                [self.fuelCellNode runAction:[CC3ActionScaleTo actionWithDuration:0.5 scaleUniformlyTo:1.0]];
            }
            break;
            
        default:
            NSLog(@"Unknown type: %d", type);
    }
}

-(void) setWheelWidths {
    
    GLfloat scale;
    
    if(gSkinnyTires) {
        scale = 1.0;
    } else {
        scale = 1.75;
    }
    
    // Use for the C10
    [self.nodeRLWheel runAction:[CC3ActionScaleTo actionWithDuration:0.5 scaleTo:cc3v(scale, 1.0, 1.0)]];
    [self.nodeRRWheel runAction:[CC3ActionScaleTo actionWithDuration:0.5 scaleTo:cc3v(scale, 1.0, 1.0)]];
    [self.nodeFLWheel runAction:[CC3ActionScaleTo actionWithDuration:0.5 scaleTo:cc3v(scale, 1.0, 1.0)]];
    [self.nodeFRWheel runAction:[CC3ActionScaleTo actionWithDuration:0.5 scaleTo:cc3v(scale, 1.0, 1.0)]];
    //[self.nodeRLWheel runAction:[CC3ActionMoveTo actionWithDuration:0.5 moveTo:cc3v(2.66, 0, 0)]];
    //[self.nodeRRWheel runAction:[CC3ActionMoveTo actionWithDuration:0.5 moveTo:cc3v(-2.66, 0, 0)]];
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

#pragma mark Course and Speed Reciever

/**
 * A method for setting the course heading. Includes speed, so that one can
 * take actions based on velocity.
 */
-(void) setCourseHeading:(double)course withSpeed:(double)speed {
        
    // Store the course/heading ...
    if(self.layer->bIsHeading) {
        
        // The filters don't behave well when course crosses from 359 to 0+ degrees.
        //gCurrentCourse = [self convertCourseToSimple:[self.courseFilter get:ccourse]];
        gCurrentCourse = course;
    }
    
    // ... and speed
    gCurrentSpeed = speed;
    
    [self setHeadersGlowBasedOnVelocity];
}

-(void) setHeadersGlowBasedOnVelocity {
    
    if(self.headersNode == nil) // Not all models have headers
        return;
    
    double speed = gCurrentSpeed;
    
    if(gCurrentSpeed < gHeaderEmissionMinSpeed) {
        // No emision under gHeaderEmissionMinSpeed MPH
        speed = 0.0;
    } else {
        // Reduce by gHeaderEmissionMinSpeed, so that headers won't glow at, say, 10 MPH.
        speed = (gCurrentSpeed-gHeaderEmissionMinSpeed)/40.0;
    }
    
    // Convert speed to some percentage of desired color.
    [self.paintBooth emit:kCCC4FBlack to:kCCC4FRed with:(speed) on:self.headersNode];
}

#pragma mark Utilities

double getFactorFromSpeed() {
    
    //return cos(CC_DEGREES_TO_RADIANS(gCurrentSpeed)); // Cos percentage
    return (101.0 - gCurrentSpeed) / 100.0; // Linear percentage
}

-(BOOL) shouldChangeCourse:(double) course {

    // Do calcs
    const double distance = fabs(course - self->prevCourse);

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

-(void) adjustPitch:(BOOL) reset {
    
    if(reset) {
        
        gPitchOffset = 0.0;
    } else {
        
        const CMAcceleration acceleration = self.manager.accelerometerData.acceleration;
        
        gPitchOffset = CLAMP(acceleration.z * 10, gMaxPitchDegreesForward, gMaxPitchDegreesBackward);
    }
}

#pragma mark Mesh Utilities

// [self move:self.cam1 from:self.par1 to:self.par2];
// Move thisCamera from thisParent toThat parent
-(void) move:(CC3Node*) thisNode from:(CC3Node*)oldParent to:(CC3Node*) newParent {
    
    NSLog(@"Moving child, %@, from parent, %@, to parent, %@", thisNode.name, oldParent.name, newParent.name);
    
    if( [oldParent getNodeNamed:thisNode.name] != nil) {
        [oldParent removeChild:thisNode];
        [newParent addChild:thisNode];
    } else {
        NSLog(@"Child, %@, is not parented to %@!!", thisNode.name, oldParent);
    }
}

-(CC3Node*) wheelFromNode:(NSString*) nodeName {
    
    CC3Node* node = [self.wheelEmpty getNodeNamed:nodeName];
    //[node addAxesDirectionMarkers];
    
    //node.shouldDrawDescriptor = YES;
    [self printLocation:node.location withName: node.name];
    return node;
}

#pragma mark Printing Utilities

-(void) printLocation:(CC3Vector) position withName:(NSString*) info {
    
    NSLog(@"%@: x: %f, y: %f, z: %f", info, position.x, position.y, position.z);
}

-(void) printLocation:(CC3Node*) node {
    
    [self printLocation:node.location withName:node.name];
}

@end

