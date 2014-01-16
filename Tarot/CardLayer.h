//
//  CardLayer.h
//  Tarot
//
//  Created by huangyimin on 12-12-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "CommonFunc.h"
#import "CommonData.h"
#import "TarotCard.h"
#import "ScrollLabelTTF.h"
#import "ContactListener.h"

@interface CardLayer : CCLayer {
    // box2d世界
    b2World *world;

    // 碰撞监听
    ContactListener *contactListener;
    
    // 第一次触摸点，上次触摸点，当前触摸点
    CGPoint firstTouchPoint;
    CGPoint lastTouchPoint;
    CGPoint currentTouchPoint;
    
    // 触摸时生成的刚体
    b2Body *touchBody;
    BOOL touchBodyIsAlive;
    
    // 卡片精灵（卡背）
    CCSprite *choosenCard;
    // 选卡时新出现的卡正面的精灵
    CCSprite *choosenCardFront;
    // 当前卡片的信息
    TarotCard *choosenTarot;
    
    // 完成洗牌时的按钮和重玩按钮
    CCMenuItem *itemShuffleFinished;
    CCMenuItem *itemRetry;
    
    // 显示塔罗卡片释义的滑动Label
    ScrollLabelTTF *cardMean;
    
    // 当前游戏阶段
    GamePhase gamePhase;
}

@end
