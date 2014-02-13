//
//  MyScene.m
//  SpaceRocks
//
//  Created by James Burns on 2/13/14.
//  Copyright (c) 2014 James Burns. All rights reserved.
//

#import "MyScene.h"

@implementation MyScene


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
    rock.position = CGPointMake(skRand(0, self.size.width), self.size.height-50);
    rock.name = @"rock";
    rock.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rock.size];
    rock.physicsBody.restitution = .5;
    rock.physicsBody.usesPreciseCollisionDetection = YES;
    [self addChild:rock];
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        SKAction *makeRocks = [SKAction sequence: @[
                                                    [SKAction performSelector:@selector(addRock) onTarget:self],
                                                    [SKAction waitForDuration:0.50 withRange:0.15]
                                                    ]];
        [self runAction: [SKAction repeatActionForever:makeRocks]];
        
        
        SKSpriteNode *myBG = [SKSpriteNode spriteNodeWithImageNamed:@"SpaceBG"];
        myBG.position=CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:myBG];
        
        //make path to emitter file
        NSString *myFile = [[NSBundle mainBundle] pathForResource:@"RockEmitter" ofType:@"sks"];
        //extract emitter
        SKEmitterNode *myRocks = [NSKeyedUnarchiver unarchiveObjectWithFile:myFile];
        myRocks.position = CGPointMake(self.size.width/2, self.size.height);
        SKEmitterNode *rocksFlipped= [myRocks copy];
        rocksFlipped.xScale=-1;
        //add emitter
        [self addChild:myRocks];
        [self addChild:rocksFlipped];
        
        //add saucer
        SKSpriteNode *saucer = [SKSpriteNode spriteNodeWithImageNamed:@"saucer"];
        saucer.size = saucer.texture.size;
        saucer.position = CGPointMake(self.size.width, 500);
        saucer.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(200, 90)];
        saucer.physicsBody.dynamic = NO;
        [self addChild:saucer];
        
        //add action to oscillate saucer
        SKAction *saucerMove = [SKAction sequence:@[[SKAction moveToX:0 duration:2], [SKAction moveToX:self.size.width duration:2]]];
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

@end
