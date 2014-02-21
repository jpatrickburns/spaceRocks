//
//  GameOver.m
//  SpaceRocks
//
//  Created by James Burns on 2/21/14.
//  Copyright (c) 2014 James Burns. All rights reserved.
//

#import "GameOver.h"
#import "MyScene.h"

@implementation GameOver

-(instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor greenColor];
        SKLabelNode *newGame = [[SKLabelNode alloc]initWithFontNamed:@"Courier"];
        newGame.fontSize = 30;
        newGame.text = @"New Game?";
        newGame.position = CGPointMake(self.size.width/2, self.size.height/2);
        newGame.name = @"newGame";
        [self addChild:newGame];
        
        
    }
    return self;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    //
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    NSArray *nodes = [self nodesAtPoint:[touch locationInNode:self]];
    for (SKNode *node in nodes) {
        if ([node.name isEqual:@"newGame"]) {
            MyScene *newGame = [[MyScene alloc]initWithSize:self.size];
            [self.view presentScene:newGame transition:[SKTransition doorwayWithDuration:2]];
        }
        
    }
}





@end
