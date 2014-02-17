//
//  MyScene.m
//  SpaceRocks
//
//  Created by James Burns on 2/13/14.
//  Copyright (c) 2014 James Burns. All rights reserved.
//

#import "MyScene.h"

@implementation MyScene

SKSpriteNode *saucer;

//masks for collisions
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
    CGFloat tempSize = skRand(3, self.size.width/15);
    rock.size = CGSizeMake(tempSize, tempSize);
    rock.position = CGPointMake(skRand(0, self.size.width), self.size.height);
    rock.name = @"rock";
    rock.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:rock.size.height];
    rock.physicsBody.angularVelocity = skRand(-20, 20);
    rock.physicsBody.restitution = 1;
    rock.physicsBody.contactTestBitMask=0;
    rock.physicsBody.usesPreciseCollisionDetection = YES;
    rock.physicsBody.node.name = @"rock";
    [self addChild:rock];
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        self.playMySound = [SKAction playSoundFileNamed:@"boom.mp3" waitForCompletion:NO];
        
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
        SKEmitterNode *myStars = [NSKeyedUnarchiver unarchiveObjectWithFile:myFile];
        myStars.position = CGPointMake(self.size.width/2, self.size.height/2);
        //add emitter
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
        
        saucer.position = CGPointMake(self.size.width, self.size.height*.55);
        //physics stuff
        saucer.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:saucer.size];
        saucer.physicsBody.affectedByGravity = NO;
        saucer.physicsBody.angularDamping = 1;
        //saucer.physicsBody.restitution = 0;
        saucer.physicsBody.linearDamping = .5;
        //saucer.physicsBody.usesPreciseCollisionDetection = YES;
        
        saucer.physicsBody.density = 2;
        saucer.physicsBody.contactTestBitMask=1;
        saucer.physicsBody.node.name = @"saucer";
        [self addChild:saucer];
        
        //add action to oscillate saucer
        SKAction *bounce =[SKAction sequence:@[[SKAction moveToX:0 duration:3],
                                               [SKAction moveToX:self.size.width duration:3],
                                               ]];
        [bounce setTimingMode:SKActionTimingEaseInEaseOut];
        [saucer runAction:[SKAction repeatActionForever:bounce]];
        
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
//    
//    for (UITouch *touch in touches) {
//        CGPoint location = [touch locationInNode:self];
    
//        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
//        
//        sprite.position = location;
//        
//        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
//        
//        [sprite runAction:[SKAction repeatActionForever:action]];
//        
//        [self addChild:sprite];
//        }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    //NSLog(@"Rotation is %f",saucer.zRotation);
    SKAction *straighten = [SKAction rotateToAngle:0 duration:.75];
    SKAction *elevate = [SKAction moveToY:self.size.height*.55 duration:.75];
    if (saucer.position.y<self.size.height/4) {
        //NSLog(@"Saucer dropped too low!");
        [saucer runAction:elevate];
    }
    float max = 22.0;
    if (saucer.zRotation>(0.0174532925 * max)||saucer.zRotation<-max * 0.0174532925) {
        [saucer runAction:straighten];

    }

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
    float factor;
    if (self.size.width==360) {
      factor=.5;
    }else{
        factor=1;
    }
    NSString *myFile = [[NSBundle mainBundle] pathForResource:@"explosion" ofType:@"sks"];
    SKEmitterNode *boom = [NSKeyedUnarchiver unarchiveObjectWithFile:myFile];
    //NSLog(@"%@ hit %@",contact.bodyA.node.name, contact.bodyB.node.name);
    boom.position = contact.contactPoint;
    boom.particleScale= factor/2;
    boom.particleSize=CGSizeMake(64*factor, 64*factor);
    [self addChild:boom];
    [self runAction:self.playMySound];
    [contact.bodyB.node removeFromParent];

}

-(void)didEndContact:(SKPhysicsContact *)contact
{
}

@end
