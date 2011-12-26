//
//  KCSampleCC3TouchCubeWorld.m
//  KCSampleCC3TouchCube
//
//  Created by  on 11/12/24.
//  Copyright KCLAB 2011年. All rights reserved.
//

#import "KCSampleCC3TouchCubeWorld.h"
#import "CC3PODResourceNode.h"
#import "CC3ActionInterval.h"
#import "CC3MeshNode.h"
#import "CC3Camera.h"
#import "CC3Light.h"

#import "CC3ParametricMeshNodes.h"
#import "CCTouchDispatcher.h"
#import "CC3VertexArrayMesh.h"

#define VALUE_THRESHOLD_MOVE 5
#define ANGLE_ROTATE 3.0
#define LENGTH_ON_SIDE_FOR_CUBE 8.0

#define NODE_NAME_FRONT  @"front"
#define NODE_NAME_BACK   @"back"
#define NODE_NAME_LEFT   @"left"
#define NODE_NAME_RIGHT  @"right"
#define NODE_NAME_TOP    @"top"
#define NODE_NAME_BOTTOM @"bottom"

CGPoint lastTouchEventPoint;

@interface KCSampleCC3TouchCubeWorld ()
@property(nonatomic, retain) CC3Node* nodeCenter;
- (CC3Node*)cubuTouchableSide;
- (void)updateRotateCenterNodeIfNeedWithLocation:(CGPoint)currentTouchEventPoint;
- (CC3MeshNode*)meshNodeWithName:(NSString*)nodeName 
                           color:(ccColor3B)color
                    LengthOnSide:(CGFloat)lengthOnSide 
                        location:(CC3Vector)loc
                         rotaion:(CC3Vector)rot;
@end

@implementation KCSampleCC3TouchCubeWorld

@synthesize nodeCenter = nodeCenter_;

-(void) dealloc {
	[super dealloc];
}

-(void) initializeWorld {

	// Create the camera, place it back a bit, and add it to the world
	CC3Camera* cam = [CC3Camera nodeWithName: @"Camera"];
	cam.location = cc3v( 0.0, 0.0, 100.0 );
	[self addChild: cam];

	// Create a light, place it back and to the left at a specific
	// position (not just directional lighting), and add it to the world
	CC3Light* lamp = [CC3Light nodeWithName: @"Lamp"];
	lamp.location = cc3v( 0.0, 50.0, 50.0 );
	lamp.isDirectionalOnly = NO;
	[cam addChild: lamp];
  
  //self.ambientLight = kCCC4FBlackTransparent;

  CC3Node* firstCube = [self cubuTouchableSide];
  self.nodeCenter = firstCube;
  [self addChild:firstCube];
}

- (CC3MeshNode*)meshNodeWithName:(NSString*)nodeName 
                           color:(ccColor3B)color
                    LengthOnSide:(CGFloat)lengthOnSide 
                        location:(CC3Vector)loc
                         rotaion:(CC3Vector)rot {
  
  CC3MeshNode* mn = [CC3BoxNode nodeWithName:nodeName];
	CC3BoundingBox bBox;
  CGFloat lengthOnSideHalf = lengthOnSide / 2;
	bBox.minimum = cc3v(-lengthOnSideHalf, -lengthOnSideHalf, 0.0);
	bBox.maximum = cc3v( lengthOnSideHalf,  lengthOnSideHalf, 0.0);
	[mn populateAsSolidBox: bBox];
	mn.material = [CC3Material material];
  mn.material.color = color;
	mn.location = loc;
  mn.rotation = rot;
  mn.isTouchEnabled = YES;
  
  return mn;
}

- (CC3Node*)cubuTouchableSide {
  
  CC3Node* node = [CC3Node nodeWithName:@"nodeCenter"];
  node.location = cc3v(0.0, 0.0, 0.0);
  
  CGFloat lengthOnSideHalf = LENGTH_ON_SIDE_FOR_CUBE / 2;
  
  // Front.
  {
    
    CC3MeshNode* meshNode = [self meshNodeWithName:NODE_NAME_FRONT 
                                             color:ccYELLOW
                                      LengthOnSide:LENGTH_ON_SIDE_FOR_CUBE
                                          location:cc3v(0.0, 0.0, lengthOnSideHalf) 
                                           rotaion:cc3v(0.0, 0.0, 0.0)];
    [node addChild:meshNode];
  }
  
  // Back.
  {
    
    CC3MeshNode* meshNode = [self meshNodeWithName:NODE_NAME_BACK
                                             color:ccBLUE
                                      LengthOnSide:LENGTH_ON_SIDE_FOR_CUBE
                                          location:cc3v(0.0, 0.0, -lengthOnSideHalf)
                                           rotaion:cc3v(180.0, 0.0, 0.0)];
    [node addChild:meshNode];
  }

  // Left.
  {
    
    CC3MeshNode* meshNode = [self meshNodeWithName:NODE_NAME_LEFT
                                             color:ccGREEN
                                      LengthOnSide:LENGTH_ON_SIDE_FOR_CUBE
                                          location:cc3v(-lengthOnSideHalf, 0.0, 0.0) 
                                           rotaion:cc3v(0.0, -90.0, 0.0)];
    [node addChild:meshNode];
  }

  // Right.
  {
    
    CC3MeshNode* meshNode = [self meshNodeWithName:NODE_NAME_RIGHT
                                             color:ccRED
                                      LengthOnSide:LENGTH_ON_SIDE_FOR_CUBE
                                          location:cc3v(lengthOnSideHalf, 0.0, 0.0) 
                                           rotaion:cc3v(0.0, 90.0, 0.0)];
    [node addChild:meshNode];
  }

  // Top.
  {
    
    CC3MeshNode* meshNode = [self meshNodeWithName:NODE_NAME_TOP
                                             color:ccMAGENTA
                                      LengthOnSide:LENGTH_ON_SIDE_FOR_CUBE
                                          location:cc3v(0.0, lengthOnSideHalf, 0.0) 
                                           rotaion:cc3v(-90.0, 0.0, 0.0)];
    [node addChild:meshNode];
  }

  // Bottom.
  {
    
    CC3MeshNode* meshNode = [self meshNodeWithName:NODE_NAME_BOTTOM
                                             color:ccORANGE
                                      LengthOnSide:LENGTH_ON_SIDE_FOR_CUBE
                                          location:cc3v(0.0, -lengthOnSideHalf, 0.0) 
                                           rotaion:cc3v(90.0, 0.0, 0.0)];
    [node addChild:meshNode];
  }
  
  return node;
}

-(void) touchEvent: (uint) touchType at: (CGPoint) touchPoint {
  LogDebug(@"touchPoint => %@", NSStringFromCGPoint(touchPoint));
  
  [super touchEvent:touchType at:touchPoint];
  
	switch (touchType) {
		case kCCTouchBegan:
      LogDebug(@"kCCTouchBegan");
      //[touchedNodePicker pickNodeFromTouchEvent: touchType at: touchPoint];
      lastTouchEventPoint = touchPoint;
			break;
		case kCCTouchMoved:
      LogDebug(@"kCCTouchMoved");
      [self updateRotateCenterNodeIfNeedWithLocation:touchPoint];
			break;
		case kCCTouchEnded:
      LogDebug(@"kCCTouchMoved");
			break;
		default:
			break;
	}
}

- (void)updateRotateCenterNodeIfNeedWithLocation:(CGPoint)currentTouchEventPoint {
  int dx = currentTouchEventPoint.x - lastTouchEventPoint.x;
  int dy = currentTouchEventPoint.y - lastTouchEventPoint.y;
  
  if (dy > VALUE_THRESHOLD_MOVE) {
    LogDebug(@"Up");
    [self.nodeCenter rotateByAngle:-ANGLE_ROTATE aroundAxis:kCC3VectorUnitXPositive];
    lastTouchEventPoint.y = currentTouchEventPoint.y;
  } else if (dy < -VALUE_THRESHOLD_MOVE) {
    [self.nodeCenter rotateByAngle:ANGLE_ROTATE aroundAxis:kCC3VectorUnitXPositive];
    lastTouchEventPoint.y = currentTouchEventPoint.y;
  }
  
  if (dx > VALUE_THRESHOLD_MOVE) {
    [self.nodeCenter rotateByAngle:ANGLE_ROTATE aroundAxis:kCC3VectorUnitYPositive];
    lastTouchEventPoint.x = currentTouchEventPoint.x;
  } else if (dx < -VALUE_THRESHOLD_MOVE){
    [self.nodeCenter rotateByAngle:-ANGLE_ROTATE aroundAxis:kCC3VectorUnitYPositive];
    lastTouchEventPoint.x = currentTouchEventPoint.x;
  }
}

-(void) nodeSelected: (CC3Node*) aNode byTouchEvent: (uint) touchType at: (CGPoint) touchPoint {
  LogDebug();
	LogInfo(@"You selected %@ at %@, or %@ in 2D.", aNode,
          NSStringFromCC3Vector(aNode ? aNode.globalLocation : kCC3VectorZero),
          NSStringFromCC3Vector(aNode ? [activeCamera projectNode: aNode] : kCC3VectorZero));
  
  LogDebug(@"touchPoint => %@", NSStringFromCGPoint(touchPoint));
  
  if ([aNode.name isEqualToString:NODE_NAME_FRONT]) {
    LogDebug(@"TAG_FRONT");
    CC3Node* aCube = [self cubuTouchableSide];
    
    aCube.location = cc3v(0.0, 0.0, LENGTH_ON_SIDE_FOR_CUBE);
    [aNode.parent addChild:aCube];
  } else if ([aNode.name isEqualToString:NODE_NAME_BACK]) {
    LogDebug(@"TAG_BACK");
    CC3Node* aCube = [self cubuTouchableSide];
    aCube.location = cc3v(0.0, 0.0, -LENGTH_ON_SIDE_FOR_CUBE);
    [aNode.parent addChild:aCube];
  } else if ([aNode.name isEqualToString:NODE_NAME_LEFT]) {
    LogDebug(@"TAG_LEFT");
    CC3Node* aCube = [self cubuTouchableSide];
    aCube.location = cc3v(-LENGTH_ON_SIDE_FOR_CUBE, 0.0, 0.0);    
    [aNode.parent addChild:aCube];
  } else if ([aNode.name isEqualToString:NODE_NAME_RIGHT]) {
    LogDebug(@"TAG_RIGHT");
    CC3Node* aCube = [self cubuTouchableSide];
    aCube.location = cc3v(LENGTH_ON_SIDE_FOR_CUBE, 0.0, 0.0);
    [aNode.parent addChild:aCube];
  } else if ([aNode.name isEqualToString:NODE_NAME_TOP]) {
    LogDebug(@"TAG_TOP");
    CC3Node* aCube = [self cubuTouchableSide];
    aCube.location = cc3v(0.0, LENGTH_ON_SIDE_FOR_CUBE, 0.0);
    [aNode.parent addChild:aCube];
  } else if ([aNode.name isEqualToString:NODE_NAME_BOTTOM]) {
    LogDebug(@"TAG_BOTTOM");
    CC3Node* aCube = [self cubuTouchableSide];
    aCube.location = cc3v(0.0, -LENGTH_ON_SIDE_FOR_CUBE, 0.0);
    [aNode.parent addChild:aCube];
  }
}

@end

