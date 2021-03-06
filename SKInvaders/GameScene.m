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

typedef enum InvaderMovementDirection{
	InvaderMovementDirectionRight,
    InvaderMovementDirectionLeft,
    InvaderMovementDirectionDownThenRight,
    InvaderMovementDirectionDownThenLeft,
    InvaderMovementDirectionNone
} InvaderMovementDirection;

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
@property InvaderMovementDirection invaderMovementDirection;
@property NSTimeInterval timeOfLastMove;
@property NSTimeInterval timePerMove;
@property BOOL contentCreated;
//get accelerometer data
@property (strong) CMMotionManager* motionManager;
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
		//accelerometer
		self.motionManager = [[CMMotionManager alloc] init];
		[self.motionManager startAccelerometerUpdates];
    }
}

//Create Content
- (void)createContent
{
	self.invaderMovementDirection = InvaderMovementDirectionRight;
	//pause for one second for each move
	self.timePerMove = 1.0;
	//set time to 0
	self.timeOfLastMove = 0.0;
	
	[self setupHud];
	[self setupInvaders];
	[self setupShip];
	//body boundaries
	self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
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
	
	//Ship physics for accelerometer
	ship.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ship.frame.size];
	ship.physicsBody.dynamic = YES;
	ship.physicsBody.affectedByGravity = NO;
	ship.physicsBody.mass = 0.02;
	
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
//Game loop
- (void)update:(NSTimeInterval)currentTime
{
	//get accelerometer
	[self processUserMotionForUpdate:currentTime];
	[self moveInvadersForUpdate:currentTime];
}

#pragma mark - Scene Update Helpers
-(void)moveInvadersForUpdate:(NSTimeInterval)currentTime{
	//check if
	if (currentTime - self.timeOfLastMove < self.timePerMove) return;
	
	//loop over nodes that are named kInvaderName, then move each based on invaderMovementDirection
	[self enumerateChildNodesWithName:kInvaderName usingBlock:^(SKNode *node, BOOL *stop){
		switch (self.invaderMovementDirection) {
            case InvaderMovementDirectionRight:
                node.position = CGPointMake(node.position.x + 10, node.position.y);
                break;
            case InvaderMovementDirectionLeft:
                node.position = CGPointMake(node.position.x - 10, node.position.y);
                break;
            case InvaderMovementDirectionDownThenLeft:
            case InvaderMovementDirectionDownThenRight:
                node.position = CGPointMake(node.position.x, node.position.y - 10);
                break;
            InvaderMovementDirectionNone:
            default:
                break;
		}
	}];
	//update timing
	self.timeOfLastMove = currentTime;
	//update direction
	[self determineInvaderMovementDirection];
}

-(void)processUserMotionForUpdate:(NSTimeInterval)currentTime {
	//get ship with ship name
    SKSpriteNode* ship = (SKSpriteNode*)[self childNodeWithName:kShipName];
	//set accelerometer data
    CMAccelerometerData* data = self.motionManager.accelerometerData;

    if (fabs(data.acceleration.x) > 0.2) {
		//Use ship physics to dictate motion based on accelerometer data
      [ship.physicsBody applyForce:CGVectorMake(40.0 * data.acceleration.x, 0)];
    }
}

#pragma mark - Invader Movement Helpers
-(void)determineInvaderMovementDirection{

	//__block allows proposedMovementDirection to be able to change InvaderMovementDirection const
	__block InvaderMovementDirection proposedMovementDirection = self.invaderMovementDirection;
	
	//loop over all invaders, test for edges of scene and change proposedMovementDirection accordingly
    [self enumerateChildNodesWithName:kInvaderName usingBlock:^(SKNode *node, BOOL *stop) {
        switch (self.invaderMovementDirection) {
			//when invader hits right edge, go DownThenLeft
            case InvaderMovementDirectionRight:
                if (CGRectGetMaxX(node.frame) >= node.scene.size.width - 1.0f) {
                    proposedMovementDirection = InvaderMovementDirectionDownThenLeft;
                    *stop = YES;
                }
                break;
			//when invader hits left edge, go DownThenRight
            case InvaderMovementDirectionLeft:
                if (CGRectGetMinX(node.frame) <= 1.0f) {
                    proposedMovementDirection = InvaderMovementDirectionDownThenRight;
                    *stop = YES;
                }
                break;
			//if invader has already gone down, it needs to go left
            case InvaderMovementDirectionDownThenLeft:
                proposedMovementDirection = InvaderMovementDirectionLeft;
                *stop = YES;
                break;
			//if invader has already gone down, it needs to go right
            case InvaderMovementDirectionDownThenRight:
                proposedMovementDirection = InvaderMovementDirectionRight;
                *stop = YES;
                break;
            default:
                break;
        }
    }];
	
	//if proposed direction is different from current movement direction, set to proposed
	if (proposedMovementDirection != self.invaderMovementDirection) {
        self.invaderMovementDirection = proposedMovementDirection;
    }
}

#pragma mark - Bullet Helpers

#pragma mark - User Tap Helpers

#pragma mark - HUD Helpers

#pragma mark - Physics Contact Helpers

#pragma mark - Game End Helpers

@end
