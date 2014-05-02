//
//  GameScene.m
//  SKInvaders
//

//  Copyright (c) 2013 RepublicOfApps, LLC. All rights reserved.
//

#import "GameScene.h"
#import <CoreMotion/CoreMotion.h>

#pragma mark - Custom Type Definitions
//invader defs
typedef enum InvaderType{
	InvaderTypeA,
	InvaderTypeB,
	InvaderTypeC
} InvaderType;

#define kInvaderSize CGSizeMake(24, 16)
#define kInvaderGridSpacing CGSizeMake(12,12)
#define kInvaderRowCount 6
#define kInvaderColCount 6

#define kInvaderName @"invader"

//ship defs
#define kShipSize CGSizeMake(30,16)
#define kShipName @"ship"

//HUD defs
#define kScoreHUDName @"scoreHud"
#define kHealthHUDName @"healthHUD"

#pragma mark - Private GameScene Properties

@interface GameScene ()
@property BOOL contentCreated;
@end


@implementation GameScene

#pragma mark Object Lifecycle Management

#pragma mark - Scene Setup and Content Creation
//init
- (void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated) {
        [self createContent];
        self.contentCreated = YES;
    }
}

//Create Content
- (void)createContent
{
	[self setupHud];
	[self setupInvaders];
	[self setupShip];
}

//Create invader using enum invaderType
-(SKNode *)makeInvaderOfType:(InvaderType)invaderType{
	
	//define invader colors based on invader type
	SKColor* invaderColor;
	switch (invaderType){
		case InvaderTypeA:
			invaderColor = [SKColor redColor];
			break;
		case InvaderTypeB:
			invaderColor = [SKColor greenColor];
			break;
		case InvaderTypeC:
		default:
			invaderColor = [SKColor blueColor];
			break;
	}
	
	//Create invader with color and size
	SKSpriteNode* invader = [SKSpriteNode spriteNodeWithColor:invaderColor size:kInvaderSize];
	//name invader
	invader.name = kInvaderName;
	
	return invader;
}

-(void)setupInvaders{
	//set up the origin point of the group of invaders
	CGPoint baseOrigin = CGPointMake(kInvaderSize.width/2, 130);
	
	//For each row...
	for (NSUInteger row = 0; row < kInvaderRowCount; ++row){
		//get invader type enum
		InvaderType invaderType;
		
		//set color of invaders for each row
        if (row % 3 == 0) {
			invaderType = InvaderTypeA;
		}
		else if (row % 3 == 1){
			invaderType = InvaderTypeB;
		}
		else {
			invaderType = InvaderTypeC;
		}
		
		//position first invader in row based on baseOrigin
		CGPoint invaderPosition = CGPointMake(baseOrigin.x, row * (kInvaderGridSpacing.height + kInvaderSize.height) + baseOrigin.y);
		
		//for each column...
		for (NSUInteger col = 0; col < kInvaderColCount; ++col) {
			//create invader instance
			SKNode* invader = [self makeInvaderOfType:invaderType];
			//position invader
			invader.position = invaderPosition;
			//add invader to view
			[self addChild:invader];
			//modify invaderPosition for the next invader
			invaderPosition.x += kInvaderSize.width + kInvaderGridSpacing.width;
		}
	}
}

-(void)setupShip{
	//create new node called ship
	SKNode* ship = [self makeShip];
	//set position of ship to
	ship.position = CGPointMake(self.size.width/2.0f, kShipSize.height/2.0f);
	//add ship to view
	[self addChild:ship];
}

-(SKNode*)makeShip{
	//create SKNode of Ship
	SKNode* ship = [SKSpriteNode spriteNodeWithColor:[SKColor greenColor] size:kShipSize];
	ship.name = kShipName;
	return ship;
}

-(void)setupHud{
	//Score label name, positioning, etc.
	SKLabelNode* scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
	
	scoreLabel.name = kScoreHUDName;
	scoreLabel.fontSize = 15;
	
	scoreLabel.fontColor = [SKColor greenColor];
	scoreLabel.text = [NSString stringWithFormat:@"Score: %04u", 0];
	
	scoreLabel.position = CGPointMake(20 + scoreLabel.frame.size.width/2, self.size.height - (20 + scoreLabel.frame.size.height/2));
	[self addChild:scoreLabel];
	
	//Health label name, positioning, etc.
	SKLabelNode* healthLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
	healthLabel.name = kHealthHUDName;
	healthLabel.fontSize = 15;
	
	healthLabel.fontColor = [SKColor redColor];
	healthLabel.text = [NSString stringWithFormat:@"Health: %.1f%%", 100.0f];
	
	healthLabel.position = CGPointMake(self.size.width - healthLabel.frame.size.width/2 - 20, self.size.height - (20 + healthLabel.frame.size.height/2));
    [self addChild:healthLabel];
}

#pragma mark - Scene Update

- (void)update:(NSTimeInterval)currentTime
{
}

#pragma mark - Scene Update Helpers

#pragma mark - Invader Movement Helpers

#pragma mark - Bullet Helpers

#pragma mark - User Tap Helpers

#pragma mark - HUD Helpers

#pragma mark - Physics Contact Helpers

#pragma mark - Game End Helpers

@end
