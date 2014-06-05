//
//  HelloWorldLayer.m
//  TaroCardGame
//
//  Created by huangyimin on 12-12-18.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "MainScene.h"
#import "SimpleAudioEngine.h"
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {

		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
		
        // 背景精灵
        CCSprite *bgSprite = [CCSprite spriteWithFile:@"Default.png"];
        bgSprite.rotation = 90;
        bgSprite.position = ccp(size.width / 2, size.height / 2 + 20.0f);
        bgSprite.scale = size.width / bgSprite.textureRect.size.height * 1.2f;
		[self addChild:bgSprite z:0];
		
		// Default font size will be 28 points.
		[CCMenuItemFont setFontSize:28];
		
		// 开始游戏
		CCMenuItem *itemSingleCard = [CCMenuItemFont itemWithString:NSLocalizedString(@"begin", @"Begin") block:^(id sender) {
            MainScene *mainScene = [MainScene node];
            [[SimpleAudioEngine sharedEngine] playEffect:@"se_zoom.mp3"];
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bgm_fortune.mp3" loop:YES];
            CCTransitionFade *tran = [CCTransitionFade transitionWithDuration:1 scene:mainScene withColor:ccBLACK];
            [[CCDirector sharedDirector] replaceScene:tran];
		}];
		
		CCMenu *menu = [CCMenu menuWithItems:itemSingleCard, nil];
		
		[menu alignItemsHorizontallyWithPadding:20];
		[menu setPosition:ccp(size.width / 2 + 10, size.height / 2 - 50)];
        
		// Add the menu to the layer
		[self addChild:menu];

	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
