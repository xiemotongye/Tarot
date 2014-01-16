//
//  MainScene.m
//  TarotCardGame
//
//  Created by huangyimin on 12-12-18.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "MainScene.h"
#import "CommonData.h"
#import "SQLiteAccess.h"

@implementation MainScene

- (id)init
{
    self = [super init];
    if (self) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        [SQLiteAccess loadAllCardsInfo];
        
        // 桌布精灵
        _tableSprite = [CCSprite spriteWithFile:@"table.png"];
        _tableSprite.rotation = 90;
        _tableSprite.scale = size.width / _tableSprite.textureRect.size.height;
        _tableSprite.position = ccp(size.width/2, size.height/2);
        [self addChild:_tableSprite z:0];
        
        // 卡组层
        deckLayer = [CardLayer node];
        [self addChild:deckLayer z:5];
    }
    return self;
}

@end
