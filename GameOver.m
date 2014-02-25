//
//  GameOver.m
//  SpaceRocks
//
//  Created by James Burns on 2/21/14.
//  Copyright (c) 2014 James Burns. All rights reserved.
//

#import "GameOver.h"
#import "MyScene.h"

SKLabelNode *timeNote;

@implementation GameOver

-(instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor darkGrayColor];
        timeNote = [[SKLabelNode alloc]initWithFontNamed:@"System"];
        timeNote.fontSize = 12;
        timeNote.position = CGPointMake(self.size.width/2, self.size.height/2+30);
        timeNote.name = @"time";
        [self addChild:timeNote];
        
        SKLabelNode *newGame = [[SKLabelNode alloc]initWithFontNamed:@"Courier"];
        newGame.fontSize = 30;
        newGame.text = @"New Game?";
        newGame.position = CGPointMake(self.size.width/2, self.size.height/2);
        newGame.name = @"newGame";
        [self addChild:newGame];
        
    }
    return self;
}

-(void)didMoveToView:(SKView *)view
{
    NSLog(@"Received float: %f from previous scene.",_timeElapsed);
    timeNote.text = [NSString stringWithFormat:@"You lasted for: %.2f seconds",-_timeElapsed];

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    //
    UITouch *touch = [touches anyObject];
    //CGPoint location = [touch locationInNode:self];
    NSArray *nodes = [self nodesAtPoint:[touch locationInNode:self]];
    for (SKNode *node in nodes) {
        if ([node.name isEqual:@"newGame"]) {
            MyScene *newGame = [[MyScene alloc]initWithSize:self.size];
            [self.view presentScene:newGame transition:[SKTransition doorwayWithDuration:1]];
        }
        
    }
}





@end
