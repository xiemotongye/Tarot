//
//  MainScene.h
//  TarotCardGame
//
//  Created by huangyimin on 12-12-18.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "CommonFunc.h"
#import "CardLayer.h"

@interface MainScene : CCScene {

    // 桌布背景精灵
    CCSprite *_tableSprite;
    
    // 卡组层，存放所有卡片精灵
    CardLayer *deckLayer;
    BOOL hasStartedShuffle;
    
    CCMenuItem *itemStartShuffle;
    CCMenuItem *itemShuffleFinished;
}

@end
