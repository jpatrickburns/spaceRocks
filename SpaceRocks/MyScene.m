//
//  MyScene.m
//  SpaceRocks
//
//  Created by James Burns on 2/13/14.
//  Copyright (c) 2014 James Burns. All rights reserved.
//

#import "MyScene.h"
#import "ViewController.h"
#import "GameOver.h"

@interface MyScene()

@property int score;
@property int bonus;
@property float damage;
@end


@implementation MyScene

SKSpriteNode *saucer;
SKSpriteNode *autoPilotButton;
SKSpriteNode *pauseButton;
//readouts
SKLabelNode *scoreLabel;
SKLabelNode *bonusLabel;
UIProgressView *damageIndicator;

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
        self.playMySound = [SKAction playSoundFileNamed:@"boom.mp3" waitForCompletion:NO];
        
        self.physicsWorld.gravity = CGVectorMake(0,-2);
        self.physicsWorld.contactDelegate = self;
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        //start the rocks
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
        //load textures
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
        
        saucer.position = CGPointMake(self.size.width/2, self.size.height*.55);
        [saucer runAction:flyin];
        
        //physics stuff
        saucer.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:saucer.size];
        saucer.physicsBody.affectedByGravity = NO;
        saucer.physicsBody.linearDamping = 1;
        saucer.physicsBody.angularDamping = 8;
        saucer.physicsBody.restitution = .5;
        //saucer.physicsBody.usesPreciseCollisionDetection = YES;
        saucer.physicsBody.mass = 1;
        saucer.physicsBody.contactTestBitMask = 1;
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
    if (self.paused) {
        pauseButton.texture = [SKTexture textureWithImageNamed:@"playButton"];
    }else{
        pauseButton.texture = [SKTexture textureWithImageNamed:@"pauseButton"];
    }
}

-(void)setupHud {
    self.score = 0;
    self.bonus = 0;
    self.damage = 1000;
    autoPilotIsOn = NO;
    
    SKSpriteNode *readOutBG = [[SKSpriteNode alloc]initWithColor:[SKColor colorWithHue:0.573 saturation:0.510 brightness:0.882 alpha:0.5] size:CGSizeMake(self.size.width, self.size.height/20)];
    readOutBG.zPosition = 5;
    readOutBG.anchorPoint = CGPointMake(0, 0);
    readOutBG.position = CGPointMake(0, 0);
    [self addChild:readOutBG];
    
    autoPilotButton = [[SKSpriteNode alloc]initWithImageNamed:@"apOff"];
    //autoPilotButton.anchorPoint = CGPointZero;
    autoPilotButton.position = CGPointMake(autoPilotButton.size.width/2 +5, readOutBG.size.height/2);
    autoPilotButton.name = @"autoPilot";
    [readOutBG addChild:autoPilotButton];
    
    pauseButton = [[SKSpriteNode alloc]initWithImageNamed:@"pauseButton"];
    //pauseButton.anchorPoint = CGPointZero;
    pauseButton.position = CGPointMake(autoPilotButton.size.width + pauseButton.size.width, readOutBG.size.height/2);
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
    
    bonusLabel = [scoreLabel copy];
    //safeTimeLabel.text = [NSString stringWithFormat:@"%04f",_safeTime];
    bonusLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    bonusLabel.position = CGPointMake(scoreLabel.position.x, readOutBG.size.height+5);
    bonusLabel.alpha=.5;
    [readOutBG addChild:bonusLabel];
    }


- (void)didMoveToView:(SKView *)view
{
    [super didMoveToView:view];
    damageIndicator = [[UIProgressView alloc]initWithFrame:CGRectMake(50, 20, self.size.width-100, 20)];
    damageIndicator.progressViewStyle = UIProgressViewStyleBar;
    damageIndicator.alpha = .5;
    damageIndicator.progress = 1;
    damageIndicator.trackTintColor = [SKColor redColor];
    [self.view addSubview:damageIndicator];
    
     }

// method to interpret motion data

-(void)processUserMotionForUpdate:(NSTimeInterval)currentTime {
    float forceFactor = 1000.0;
    CMAccelerometerData* data = self.myMotionManager.accelerometerData;
    if (fabs(data.acceleration.x) > 0.2||fabs(data.acceleration.y) > 0.5) {
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

- (int)calcBonus{
    int bonus = _bonus/30 * 50;
    return bonus;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if (!self.isPaused) {
        _bonus++;
        //_score++;
        
        bonusLabel.text = [NSString stringWithFormat:@"Bonus: %04U",[self calcBonus]];
        scoreLabel.text = [NSString stringWithFormat:@"Score: %04D",_score];
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
    
    if (saucer.position.y<self.size.height*.55) {
        //NSLog(@"Saucer dropped too low!");
        [saucer.physicsBody applyForce:CGVectorMake(0, 200)];
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
        SKAction *bounce =[SKAction sequence:@[[SKAction moveToX:0 + saucer.size.width/2 duration:3],
                                               [SKAction moveToX:self.size.width - saucer.size.width/2 duration:3],
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

- (void) doGameOver
{
    GameOver *gameOver = [[GameOver alloc]initWithSize:self.size];
    [self.view presentScene:gameOver transition:[SKTransition fadeWithColor:[SKColor blackColor] duration:2]];
    [damageIndicator removeFromSuperview];
}

- (void)adjustScore
{
    //subtract for rock hit
    
    _score = _score - 200 + [self calcBonus];
    if (_score < 0) {
        scoreLabel.fontColor = [SKColor redColor];
    }
    //update indicator
    _damage = _damage + _score;
    NSLog(@"Damage progress is: %f",_damage/1000);
    damageIndicator.progress = _damage/1000;
    if (_damage/1000 < 0) {
        
        [self doGameOver];
    
    }
    _bonus = 0;
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
        SKLabelNode *hitDamage = [[SKLabelNode alloc]initWithFontNamed:@"Courier"];
        hitDamage.position = boom.position;
        hitDamage.fontSize = 10;
        hitDamage.fontColor = [SKColor redColor];
        SKAction *scaleDissolve = [SKAction group:@[
                                                    [SKAction scaleBy:2 duration:.75],
                                                    [SKAction fadeAlphaTo:0 duration:.75]]];
        hitDamage.text = @"-200";
        [self addChild:hitDamage];
        [hitDamage runAction:scaleDissolve completion:^(void){[hitDamage removeFromParent];}];
        
        [saucer.physicsBody applyForce:CGVectorMake(0, -contact.bodyB.velocity.dy)];
        //NSLog(@"Compensating for movement %f",contact.bodyB.velocity.dy);
        
        
        [contact.bodyB.node.children[0] removeFromParent];
        [contact.bodyB.node removeFromParent];
        [self adjustScore];
        
    }
}

-(void)didEndContact:(SKPhysicsContact *)contact
{
    
}

@end
