//
//  MyScene.h
//  SpaceRocks
//

//  Copyright (c) 2014 James Burns. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <CoreMotion/CoreMotion.h>

@interface MyScene : SKScene <SKPhysicsContactDelegate>

@property (strong, nonatomic) SKAction *playMySound;
@property (strong, nonatomic) CMMotionManager *myMotionManager;

- (void)autoPilot;
@end
