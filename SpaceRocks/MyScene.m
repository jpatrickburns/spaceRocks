//
//  MyScene.m
//  SpaceRocks
//
//  Created by James Burns on 2/13/14.
//  Copyright (c) 2014 James Burns. All rights reserved.
//

#import "MyScene.h"

@implementation MyScene


static const uint32_t rockCategory     =  0x1 << 0;
static const uint32_t shipCategory        =  0x1 << 1;


static inline CGFloat skRandf() {
    return rand() / (CGFloat) RAND_MAX;
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
    return skRandf() * (high - low) + low;
}


- (void)addRock
{
    SKSpriteNode *rock = [SKSpriteNode spriteNodeWithImageNamed:@"rock"];
    rock.size = CGSizeMake(64, 64);
    rock.position = CGPointMake(skRand(0, self.size.width), self.size.height+50);
    rock.name = @"rock";
    rock.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rock.size];
    rock.physicsBody.angularVelocity = 5;
    rock.physicsBody.restitution = .5;
    rock.physicsBody.contactTestBitMask=0;
    rock.physicsBody.usesPreciseCollisionDetection = YES;
    rock.physicsBody.node.name = @"rock";
    [self addChild:rock];
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        
        
        self.physicsWorld.gravity = CGVectorMake(0,-2);
        self.physicsWorld.contactDelegate = self;
        
        SKAction *makeRocks = [SKAction sequence: @[
                                                    [SKAction performSelector:@selector(addRock) onTarget:self],
                                                    [SKAction waitForDuration:0.50 withRange:0.15]
                                                    ]];
        [self runAction: [SKAction repeatActionForever:makeRocks]];
        
        
        SKSpriteNode *myBG = [SKSpriteNode spriteNodeWithImageNamed:@"SpaceBG"];
        myBG.position=CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:myBG];
        
        //make path to emitter file
        NSString *myFile = [[NSBundle mainBundle] pathForResource:@"fallingStars" ofType:@"sks"];
        //extract emitter
        SKEmitterNode *myRocks = [NSKeyedUnarchiver unarchiveObjectWithFile:myFile];
        myRocks.position = CGPointMake(self.size.width/2, self.size.height/2);
               //add emitter
        [self addChild:myRocks];
        
        //add saucer
        SKTextureAtlas *flyingSaucer = [SKTextureAtlas atlasNamed:@"FlyingSaucer"];
        SKTexture *f1 = [flyingSaucer textureNamed:@"saucer001.png"];
        SKTexture *f2 = [flyingSaucer textureNamed:@"saucer002.png"];
        SKTexture *f3 = [flyingSaucer textureNamed:@"saucer003.png"];
        SKTexture *f4 = [flyingSaucer textureNamed:@"saucer004.png"];
        NSArray *saucerTextures = @[f1,f2,f3,f4];

        SKAction *flyin = [SKAction animateWithTextures:saucerTextures timePerFrame:.1];
        SKSpriteNode *saucer = [[SKSpriteNode alloc] initWithTexture:[flyingSaucer textureNamed:@"saucer001.png"]color:nil size:CGSizeMake(180, 90)];
        [saucer runAction:flyin];
        saucer.position = CGPointMake(self.size.width, 500);
        saucer.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(180, 90)];
        saucer.physicsBody.affectedByGravity = NO;
        saucer.physicsBody.angularDamping = 1;
        saucer.physicsBody.linearDamping = .5;
        saucer.physicsBody.density = 2;
        saucer.physicsBody.contactTestBitMask=1;
        saucer.physicsBody.node.name = @"saucer";
        [self addChild:saucer];
        
        //add action to oscillate saucer
        SKAction *straighten = [SKAction rotateToAngle:0 duration:2];
        SKAction *elevate = [SKAction moveToY:500 duration:2];
        SKAction *bounce =[SKAction sequence:@[[SKAction moveToX:0 duration:2],
                                               [SKAction moveToX:self.size.width duration:2],
                                               ]];
        SKAction *saucerMove = [SKAction group:@[straighten,elevate,bounce]];

        [saucer runAction:[SKAction repeatActionForever:saucerMove]];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        
        sprite.position = location;
        
        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
        
        [sprite runAction:[SKAction repeatActionForever:action]];
        
        [self addChild:sprite];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

-(void)didSimulatePhysics
{
    [self enumerateChildNodesWithName:@"rock" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y < 0)
            [node removeFromParent];
    }];
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    NSString *myFile = [[NSBundle mainBundle] pathForResource:@"explosion" ofType:@"sks"];
    SKEmitterNode *boom = [NSKeyedUnarchiver unarchiveObjectWithFile:myFile];
    // NSLog(@"%@ hit %@",contact.bodyA.node.name, contact.bodyB.node.name);
    boom.position = contact.contactPoint;
    [self addChild:boom];
    [contact.bodyB.node setHidden:YES];
}

@end
