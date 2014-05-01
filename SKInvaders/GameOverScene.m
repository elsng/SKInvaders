//
//  GameOverScene.m
//  SpaceInvadersTraditional
//

//  Copyright (c) 2013 RepublicOfApps, LLC. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScene.h"

@interface GameOverScene ()
@property BOOL contentCreated;
@end

@implementation GameOverScene

- (void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated) {
        [self createContent];
        self.contentCreated = YES;
    }
}

- (void)createContent
{
    SKLabelNode* gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
    gameOverLabel.fontSize = 50;
    gameOverLabel.fontColor = [SKColor whiteColor];
    gameOverLabel.text = @"Game Over!";
    gameOverLabel.position = CGPointMake(self.size.width/2, 2.0 / 3.0 * self.size.height);
    [self addChild:gameOverLabel];
    
    SKLabelNode* tapLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
    tapLabel.fontSize = 25;
    tapLabel.fontColor = [SKColor whiteColor];
    tapLabel.text = @"(Tap to Play Again)";
    tapLabel.position = CGPointMake(self.size.width/2, gameOverLabel.frame.origin.y - gameOverLabel.frame.size.height - 40);
    [self addChild:tapLabel];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Intentional no-op
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Intentional no-op
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Intentional no-op
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    GameScene* gameScene = [[GameScene alloc] initWithSize:self.size];
    gameScene.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:gameScene transition:[SKTransition doorsCloseHorizontalWithDuration:1.0]];
}

@end
