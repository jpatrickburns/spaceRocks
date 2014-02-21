//
//  MyScene.m
//  SpaceRocks
//
//  Created by James Burns on 2/13/14.
//  Copyright (c) 2014 James Burns. All rights reserved.
//

#import "MyScene.h"
#import "ViewController.h"


@interface MyScene()

@property int score;
@property int safeTime;

@end


@implementation MyScene

SKSpriteNode *saucer;
SKSpriteNode *autoPilotButton;
SKSpriteNode *pauseButton;
SKLabelNode *scoreLabel;
SKLabelNode *safeTimeLabel;
bool autoPilotIsOn;

//masks for collisions
static const uint32_t rockCategory     =  0x1 << 0;
static const uint32_t saucerCategory      =  0x1 << 1;
static const uint32_t frameCategory      =  0x1 << 2;


static inline CGFloat skRandf() {
    return rand() / (CGFloat) RAND_MAX;
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
    return skRandf() * (high - low) + low;
}



- (void)addRock
{
    
    SKSpriteNode *rock = [SKSpriteNode spriteNodeWithImageNamed:@"rock"];
    CGFloat tempSize = skRand(5, self.size.width/20);
    rock.size = CGSizeMake(tempSize, tempSize);
    rock.position = CGPointMake(skRand(0, self.size.width), self.size.height);
    rock.name = @"rock";
    rock.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:rock.size.height];
    rock.physicsBody.angularVelocity = skRand(-20, 20);
    rock.physicsBody.restitution = .5;
    rock.physicsBody.mass = tempSize/1000;
    rock.physicsBody.contactTestBitMask=0;
    rock.physicsBody.collisionBitMask=0;
    rock.physicsBody.usesPreciseCollisionDetection = YES;
    rock.physicsBody.node.name = @"rock";
    [self addChild:rock];
    //add trail
    NSString *myFile = [[NSBundle mainBundle] pathForResource:@"rockTrail" ofType:@"sks"];
    SKEmitterNode *myTrail = [NSKeyedUnarchiver unarchiveObjectWithFile:myFile];
    myTrail.particlePositionRange = CGVectorMake(tempSize, 0);
    myTrail.targetNode = self;
    [rock addChild:myTrail];
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        /* Setup your scene here */
        autoPilotIsOn = NO;
        self.playMySound = [SKAction playSoundFileNamed:@"boom.mp3" waitForCompletion:NO];
        
        self.physicsWorld.gravity = CGVectorMake(0,-2);
        self.physicsWorld.contactDelegate = self;
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        SKAction *makeRocks = [SKAction sequence: @[
                                                    [SKAction performSelector:@selector(addRock) onTarget:self],
                                                    [SKAction waitForDuration:0.50 withRange:0.15]
                                                    ]];
        [self runAction: [SKAction repeatActionForever:makeRocks]];
        
        //add bg
        
        SKSpriteNode *myBG = [SKSpriteNode spriteNodeWithImageNamed:@"SpaceBG"];
        myBG.position=CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:myBG];
        
        // add nebulae
        SKSpriteNode *myNebulae = [SKSpriteNode spriteNodeWithImageNamed:@"SpaceNebulae"];
        myNebulae.size = self.size;
        CGPoint myTop = CGPointMake(self.size.width/2, self.size.height/2);
        myNebulae.position = myTop;
        [self addChild:myNebulae];
        
        //add a copy
        
        SKSpriteNode *myCopiedNebulae = [myNebulae copy];
        myCopiedNebulae.position = CGPointMake(0,myNebulae.size.height);
        [myNebulae addChild:myCopiedNebulae];
        
        //make looping animation
        SKAction *moveNebulae = [SKAction sequence:@[
                                                     [SKAction moveByX:0 y:-self.size.height duration:10],
                                                     [SKAction moveTo:myTop duration:0]]];
        [myNebulae runAction:[SKAction repeatActionForever:moveNebulae]];
        
        //make path to star emitter file
        NSString *myFile = [[NSBundle mainBundle] pathForResource:@"fallingStars" ofType:@"sks"];
        
        //extract emitter
        SKEmitterNode *myStars = [NSKeyedUnarchiver unarchiveObjectWithFile:myFile];
        myStars.particlePositionRange = CGVectorMake(self.size.width, self.size.height);
        myStars.position = CGPointMake(self.size.width/2, self.size.height);
        
        //add stars emitter
        [self addChild:myStars];
        
        //add saucer
        SKTextureAtlas *flyingSaucer = [SKTextureAtlas atlasNamed:@"FlyingSaucer"];
        NSArray *sortedList = [flyingSaucer.textureNames sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        
        NSMutableArray *saucerTextures = [[NSMutableArray alloc]init];
        for (int i=0; i<sortedList.count; i++) {
            SKTexture *newTex = [flyingSaucer textureNamed:sortedList[i]];
            [saucerTextures addObject:newTex];
            NSLog(@"Added %@",sortedList[i]);
        }
        
        NSLog(@"Textures contain %@",saucerTextures);
        float saucerSize = self.size.width *.2;
        SKAction *flyin = [SKAction repeatActionForever:[SKAction animateWithTextures:saucerTextures timePerFrame:.1]];
        saucer = [[SKSpriteNode alloc] initWithTexture:[flyingSaucer textureNamed:@"saucer001.png"]
                                                 color:nil
                                                  size:CGSizeMake(saucerSize, saucerSize/2)];
        [saucer runAction:flyin];
        
        saucer.position = CGPointMake(self.size.width/2, self.size.height*.55);
        
        //physics stuff
        saucer.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:saucer.size];
        saucer.physicsBody.affectedByGravity = NO;
        saucer.physicsBody.linearDamping = 1;
        saucer.physicsBody.angularDamping = 8;
        saucer.physicsBody.restitution = .5;
        //saucer.physicsBody.usesPreciseCollisionDetection = YES;
        saucer.physicsBody.mass = 1;
        saucer.physicsBody.contactTestBitMask=1;
        saucer.physicsBody.node.name = @"saucer";
        [self addChild:saucer];
        
        //init Accelerometer
        self.myMotionManager = [[CMMotionManager alloc]init];
        [self.myMotionManager startAccelerometerUpdates];
        
        //make readout
        [self setupHud];
        
    }
    return self;
}

- (void) pauseScene
{
    self.paused = !self.paused;
}

-(void)setupHud {
    self.score = 0;
    self.safeTime = 0;
    SKSpriteNode *readOutBG = [[SKSpriteNode alloc]initWithColor:[SKColor colorWithHue:0.573 saturation:0.510 brightness:0.882 alpha:0.5] size:CGSizeMake(self.size.width, 30)];
    readOutBG.zPosition = 5;
    readOutBG.anchorPoint = CGPointMake(0, 0);
    readOutBG.position = CGPointMake(0, 0);
    [self addChild:readOutBG];
    
    autoPilotButton = [[SKSpriteNode alloc]initWithImageNamed:@"apOff"];
    autoPilotButton.anchorPoint = CGPointZero;
    autoPilotButton.position = CGPointMake(5, 5);
    autoPilotButton.name = @"autoPilot";
    [readOutBG addChild:autoPilotButton];
    
    pauseButton = [[SKSpriteNode alloc]initWithImageNamed:@"pauseButton"];
    pauseButton.anchorPoint = CGPointZero;
    pauseButton.position = CGPointMake(autoPilotButton.size.width+10, 5);
    pauseButton.name = @"pauseButton";
    [readOutBG addChild:pauseButton];
    
    scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
    //scoreLabel.name = kScoreHudName;
    scoreLabel.fontSize = 15;
    scoreLabel.fontColor = [SKColor whiteColor];
    scoreLabel.text = [NSString stringWithFormat:@"Score:%04u", self.score];
    scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    scoreLabel.position = CGPointMake(autoPilotButton.size.width+pauseButton.size.width + 20, readOutBG.size.height/3);
    scoreLabel.name = @"score";
    [readOutBG addChild:scoreLabel];
    
    safeTimeLabel = [scoreLabel copy];
    //safeTimeLabel.text = [NSString stringWithFormat:@"%04f",_safeTime];
    safeTimeLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    safeTimeLabel.position = CGPointMake(self.size.width/2, readOutBG.size.height+5);
    safeTimeLabel.alpha=.5;
    [readOutBG addChild:safeTimeLabel];
    
}

// method to interpret motion data

-(void)processUserMotionForUpdate:(NSTimeInterval)currentTime {
    float forceFactor = 1000.0;
    CMAccelerometerData* data = self.myMotionManager.accelerometerData;
    if (fabs(data.acceleration.x) > 0.2||fabs(data.acceleration.y) > 0.2) {
        //this might be high! Might need to scale to device
        [saucer.physicsBody applyForce:CGVectorMake(forceFactor * data.acceleration.x, forceFactor * data.acceleration.y)];
    }
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    //
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    NSArray *nodes = [self nodesAtPoint:[touch locationInNode:self]];
    for (SKNode *node in nodes) {
        if ([node.name isEqual:@"autoPilot"]) {
            [self autoPilot];
        }
        if ([node.name isEqualToString:@"pauseButton"]) {
            [self pauseScene];
        }
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (!self.isPaused) {
        _safeTime++;
        _score++;
        safeTimeLabel.text = [NSString stringWithFormat:@"%04D",_safeTime ];
        scoreLabel.text = [NSString stringWithFormat:@"Score: %04U",_score];
        if (self.score > 0) {
            scoreLabel.fontColor=[SKColor whiteColor];
        }
        if (!autoPilotIsOn) {
            //implement tilt motion
            [self processUserMotionForUpdate:currentTime];
        }
    }
    //NSLog(@"Rotation is %f",saucer.zRotation);
    SKAction *straighten = [SKAction rotateToAngle:0 duration:.75];
    SKAction *elevate = [SKAction moveToY:self.size.height*.55 duration:.75];
    [elevate setTimingMode:SKActionTimingEaseInEaseOut];
    if (saucer.position.y<self.size.height*.55) {
        //NSLog(@"Saucer dropped too low!");
        [saucer.physicsBody applyForce:CGVectorMake(0, 100)];
    }
    float max = 22.0;
    if (saucer.zRotation>(0.0174532925 * max)||saucer.zRotation<-max * 0.0174532925) {
        [saucer runAction:straighten];
    }
}

- (void)autoPilot{
    
    autoPilotIsOn = !autoPilotIsOn;
    
    if (autoPilotIsOn) {
        //add action to oscillate saucer
        SKAction *bounce =[SKAction sequence:@[[SKAction moveToX:0 duration:3],
                                               [SKAction moveToX:self.size.width duration:3],
                                               ]];
        [bounce setTimingMode:SKActionTimingEaseInEaseOut];
        [saucer runAction:[SKAction repeatActionForever:bounce] withKey:@"autoPilot"];
        autoPilotButton.texture = [SKTexture textureWithImageNamed:@"apOn"];
        NSLog(@"Autopilot is on!");
    }else{
        [saucer removeActionForKey:@"autoPilot"];
        autoPilotButton.texture = [SKTexture textureWithImageNamed:@"apOff"];
        
        NSLog(@"Autopilot is off!");
    }
}

-(void)didSimulatePhysics
{
    [self enumerateChildNodesWithName:@"rock" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y < 0)
            
            //get rid of rock
            [node removeFromParent];
    }];
}

- (void)adjustScore
{
    //subtract for rock hit
    //self.score = self.score + _safeTime;
    self.score = self.score -100;
    if (self.score <0) {
        scoreLabel.fontColor = [SKColor redColor];
    }
    _safeTime = 0;
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    float factor;
    if (self.size.width==360) {
        factor=.5;
    }else{
        factor=1;
    }
    
    if ([contact.bodyB.node.name isEqual:@"rock"]) {
        NSString *myFile = [[NSBundle mainBundle] pathForResource:@"explosion" ofType:@"sks"];
        SKEmitterNode *boom = [NSKeyedUnarchiver unarchiveObjectWithFile:myFile];
        //NSLog(@"%@ hit %@",contact.bodyA.node.name, contact.bodyB.node.name);
        boom.position = contact.contactPoint;
        boom.particleScale = factor/2;
        boom.particleSize = CGSizeMake(64*factor, 64*factor);
        [self addChild:boom];
        [self runAction:self.playMySound];
        [contact.bodyB.node.children[0] removeFromParent];
        [contact.bodyB.node removeFromParent];
        [self adjustScore];
        
    }
}

-(void)didEndContact:(SKPhysicsContact *)contact
{
    
}

@end
