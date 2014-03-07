//
//  StartupScene.m
//  SpaceRocks
//
//  Created by James Burns on 3/7/14.
//  Copyright (c) 2014 James Burns. All rights reserved.
//

#import "StartupScene.h"
#import "MyScene.h"

@implementation StartupScene

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        
        /* Setup your scene here */
        
        //detirmine iPad or iPhone object sizes
        
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone) {
        }else{
            //if an iPad
        }
        //add bg
        SKSpriteNode *myBG = [SKSpriteNode spriteNodeWithImageNamed:@"startup"];
        myBG.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:myBG];
        
        //add help screen
        SKSpriteNode *help = [SKSpriteNode spriteNodeWithImageNamed:@"helpScreen"];
        help.position = CGPointMake(self.size.width/2, 0);
        help.alpha = 0;
        [self addChild:help];
        SKAction *moveInHelp = [SKAction group:@[
                                                 [SKAction moveTo:CGPointMake(self.size.width/2, self.size.height * .20) duration:1],
                                                 [SKAction fadeAlphaTo:1 duration:1]]];
        [help runAction:moveInHelp];
        
        //add start type
        SKLabelNode *startButton = [[SKLabelNode alloc] initWithFontNamed:@"Courier"];
        startButton.text = @"Start";
        startButton.name = startButton.text;
        startButton.fontSize = self.size.width/18;
        startButton.fontColor = [SKColor colorWithHue:0.573 saturation:0.510 brightness:0.882 alpha:1];
        startButton.alpha = 1;
        startButton.position = CGPointMake(self.size.width/2, self.size.height * .45);
        [self addChild:startButton];
        
    }
    return self;
}

- (void)startGame{
    NSLog(@"Started Game!");
    MyScene *newScene = [[MyScene alloc]initWithSize:self.size];
    [self.view presentScene:newScene transition:[SKTransition flipHorizontalWithDuration:1]];

}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    //
    UITouch *touch = [touches anyObject];
    // CGPoint location = [touch locationInNode:self];
    NSArray *nodes = [self nodesAtPoint:[touch locationInNode:self]];
    for (SKNode *node in nodes) {
        if ([node.name isEqual:@"Start"]) {
            [self startGame];
        }
    }
}

@end
