//
//  CardLayer.m
//  Tarot
//
//  Created by huangyimin on 12-12-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "CardLayer.h"
#import "TarotCard.h"
#import "HelloWorldLayer.h"
#import "SimpleAudioEngine.h"
#define CARD_SCALE 0.16
enum {
	kTagParentNode = 1,
};

@implementation CardLayer

- (id)init
{
    self = [super init];
    if (self) {
        [self initPhysics];

        // CCSpriteBatchNode 中的所有CCSprite只会被渲染1次，因此可以提高游戏的FPS，但所有纹理图必须是一张
        // 广泛应用于纹理切割，这里不进行切割，纹理仅是卡背图
        CCSpriteBatchNode *parent = [CCSpriteBatchNode batchNodeWithFile:@"cardBG.png" capacity:50];
        [self addChild:parent z:0 tag:kTagParentNode];
        
        // 接受加速度和触摸
        self.isTouchEnabled = YES;
        self.isAccelerometerEnabled = YES;
        touchBody = NULL;
        
        gamePhase = kStandbyPhase;
        
        [self initCards];
    }
    return self;
}

-(void)initPhysics
{
    b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
    world = new b2World(gravity);
    
    contactListener = new ContactListener();
    world->SetContactListener(contactListener);
    
    // allowSleeping必须设为false，否则达到稳定状态时所有刚体会睡眠，不响应加速计对box2d的加速度调整
	world->SetAllowSleeping(false);
	world->SetContinuousPhysics(true);
    
    CGSize s = [[CCDirector sharedDirector] winSize];
    float widthInMeters = s.width / PTM_RATIO;
    float heightInMeters = s.height / PTM_RATIO;
    b2Vec2 lowerLeftCorner = b2Vec2(0, 0);
    b2Vec2 lowerRightCorner = b2Vec2(widthInMeters, 0);
    b2Vec2 upperLeftCorner = b2Vec2(0, heightInMeters);
    b2Vec2 upperRightCorner = b2Vec2(widthInMeters, heightInMeters);
    
    // 静态刚体桌面边界
    b2BodyDef tableBodyDef;
    b2Body *tableBody = world->CreateBody(&tableBodyDef);
    
    b2EdgeShape tableBox;
	
	// bottom 底
	tableBox.Set(lowerLeftCorner, lowerRightCorner);
	tableBody->CreateFixture(&tableBox, 0);
	
	// top 顶
	tableBox.Set(upperLeftCorner, upperRightCorner);
	tableBody->CreateFixture(&tableBox, 0);
	
	// left 左
	tableBox.Set(upperLeftCorner, lowerLeftCorner);
	tableBody->CreateFixture(&tableBox, 0);
	
	// right 右
	tableBox.Set(upperRightCorner, lowerRightCorner);
	tableBody->CreateFixture(&tableBox, 0);
    
}

- (void)initCards
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    // 每张卡片与中心位置的偏移量
    float dHeight = 0.0f;
    float dWidth = 0.0f;
    
    CCNode *parent = [self getChildByTag:kTagParentNode];
    
    
    for (int i = 0; i < 22; i ++) {
        // 初始化卡片精灵
        CCSprite *cardSprite = [CCSprite spriteWithFile:@"cardBG.png"];
        cardSprite.scale = size.width / cardSprite.textureRect.size.width * CARD_SCALE;
        cardSprite.position = ccp(size.width/2 - dWidth, size.height/2 - 10 + dHeight);
        [parent addChild:cardSprite z:i];
        // 设置下张卡片距离第一张卡片的位偏移
        ++ dHeight;
        dWidth += 0.2;
        
        // 创建刚体
        // userData存放卡片精灵，令刚体与精灵产生关联
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody;
        bodyDef.position = [CommonFunc toMeters:cardSprite.position];
        bodyDef.userData = cardSprite;
        b2Body *body = world->CreateBody(&bodyDef);
        
        // 定义一个shape，并绑定至fixture容器
        CGRect rect = [cardSprite textureRect];
        float scale = [cardSprite scale];
        b2PolygonShape dynamicCard;
        dynamicCard.SetAsBox(rect.size.width * scale * .3f / PTM_RATIO, rect.size.width * scale * .3f / PTM_RATIO);
        
        b2FixtureDef fixtureDef;
        fixtureDef.shape = &dynamicCard;
        // 密度
        fixtureDef.density = 0.6f;
        // 摩擦力
        fixtureDef.friction = 0.8f;
        body->CreateFixture(&fixtureDef);
    }
    
}

- (void)dealloc
{
    delete contactListener;
    delete world;
    [super dealloc];
}

// 判断触摸点是否有精灵被选中
- (BOOL)theSpriteHasBeenChossen:(CCSprite *)sprite WithTouchPoint:(CGPoint)touchPoint
{
    float touchX = touchPoint.x;
    float touchY = touchPoint.y;
    
    float spriteX = sprite.position.x;
    float spriteY = sprite.position.y;
    
    // 以牌中心为极点x轴为极轴，旋转坐标系，得到旋转后触摸点的极坐标
    float distance = sqrt(pow((touchX - spriteX), 2.0) + pow((touchY - spriteY), 2.0));
    float radians = acos((spriteX - touchX) / distance);
    radians = radians + CC_DEGREES_TO_RADIANS(sprite.rotation);
    
    if (ABS(distance * cos(radians)) < sprite.textureRect.size.width * sprite.scale / 2
        && ABS(distance * sin(radians)) < sprite.textureRect.size.height * sprite.scale / 2) {
        if (sprite != choosenCard) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"se_cardFlow.mp3"];
            choosenCard = sprite;
        }

        return YES;
    }
    else {
        return NO;
    }
}

#pragma mark - accelerometer
// 获得加速度并调整box2D世界的加速度
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    // 因为应用是左横屏，加速度的x,y分别取加速计的y轴加速度和-x加速度
    b2Vec2 gravity = b2Vec2(acceleration.y * PTM_RATIO, -acceleration.x * PTM_RATIO);
    
    // 调整box2D世界的加速度
    world->SetGravity(gravity);
}

#pragma mark - touches
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    switch (gamePhase) {
        case kStandbyPhase: {
            CGPoint touchPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
            [self startShuffleAtPoint:touchPoint];
            break;
        }
            
        case kShufflePhase: {
            firstTouchPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
            lastTouchPoint = firstTouchPoint;
            break;
        }

        case kDrawPhase: {
            CGPoint touchPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
            [self chooseCardAtPoint:touchPoint];
            break;
        }
            
        case kOpenCardPhase: {
            CGPoint touchPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
            [self openCardAtPoint:touchPoint];
            break;
        }
            
        default:
            break;
    }
    
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    switch (gamePhase) {
        case kShufflePhase: {
            currentTouchPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
            if (NO == touchBodyIsAlive) {
                [self createTouchBody];
            }
            else {
                [self moveTouchBody];
            }
            lastTouchPoint = currentTouchPoint;
            break;
        }
        
        case kDrawPhase: {
            CGPoint touchPoint = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
            [self chooseCardAtPoint:touchPoint];
            break;
        }
            
        case kShowCardInfoPhase: {

        }
        default:
            break;
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    switch (gamePhase) {
        case kShufflePhase: {
            if (NULL != touchBody) {
                world->DestroyBody(touchBody);
                touchBody = NULL;
            }
            
            touchBodyIsAlive = NO;
            break;
        }

        case kDrawPhase: {
            if (nil != choosenCard) {
                [self selectOneCard];
                gamePhase = kAnimationPhase;
            }
            
            break;
        }
        default:
            break;
    }
    
    
}

#pragma mark - shufflePhase
- (void)startShuffleAtPoint:(CGPoint)touchPoint
{
    for (b2Body *body = world->GetBodyList(); body != nil; body = body->GetNext())
    {
        CCSprite *sprite = (CCSprite *)body->GetUserData();
        if (sprite != nil) {
            if ([self theSpriteHasBeenChossen:sprite WithTouchPoint:touchPoint]) {
                gamePhase = kShufflePhase;
                [self scheduleUpdate];
                
                [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(showItemContinue) userInfo:nil repeats:NO];
                break;
            }
            
        }
    }
}

- (void)createTouchBody
{
    float dx = 0.0f;
    float dy = 0.0f;

    // 触摸创建的刚体与第一次触摸的位偏移量
    if (0 != firstTouchPoint.x - currentTouchPoint.x) {
        dx = (firstTouchPoint.x - currentTouchPoint.x) / ABS(currentTouchPoint.x - firstTouchPoint.x) * 10;
    }
    if (0 != firstTouchPoint.y - currentTouchPoint.y) {
        dy = (firstTouchPoint.y - currentTouchPoint.y) / ABS(currentTouchPoint.y - firstTouchPoint.y) * 10;
    }    
    
    // 在移动位置的反向创建刚体
    // userData存放卡片精灵，令刚体与精灵产生关联
    b2BodyDef touchBodyDef;
    touchBodyDef.type = b2_dynamicBody;
    touchBodyDef.position = [CommonFunc toMeters:CGPointMake(firstTouchPoint.x + dx, firstTouchPoint.y + dy)];
    touchBody = world->CreateBody(&touchBodyDef);
    
    // 定义一个shape，并绑定至fixture容器
    b2PolygonShape dynamicTouch;
    dynamicTouch.SetAsBox(.3f, .3f);
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &dynamicTouch;
    // 密度
    fixtureDef.density = .6f;
    // 摩擦力
    fixtureDef.friction = .8f;
    touchBody->CreateFixture(&fixtureDef);
    
    touchBodyIsAlive = YES;
}

- (void)moveTouchBody
{
    float dx = 0.0f;
    float dy = 0.0f;
    
    // 触摸创建的刚体与上次触摸点的方向向量
    if (0 != lastTouchPoint.x - currentTouchPoint.x) {
        dx = (currentTouchPoint.x - lastTouchPoint.x) / ABS(lastTouchPoint.x - currentTouchPoint.x);
    }
    if (0 != lastTouchPoint.y - currentTouchPoint.y) {
        dy = (currentTouchPoint.y - lastTouchPoint.y) / ABS(lastTouchPoint.y - currentTouchPoint.y);
    }
    
    b2Vec2 force = b2Vec2(dx * 200, dy * 200);
    touchBody->ApplyForce(force, touchBody->GetWorldCenter());
}

- (void)update:(ccTime)delta
{
    float timeStep = 0.03f;
    int32 velocityIterations = 8;
    int32 positionIterations = 1;
    
    // delta会上下浮动，会造成刚体速度不稳定，不建议用delta作为第一个参数
    // 第二第三参数分别为位置迭代次数和速度迭代次数
    world->Step(timeStep, velocityIterations, positionIterations);
    
    // 遍历刚体，并更新卡片精灵的位置和角度
    for (b2Body *body = world->GetBodyList(); body != nil; body = body->GetNext())
    {
        CCSprite *sprite = (CCSprite *)body->GetUserData();
        if (sprite != nil) {
            sprite.position = [CommonFunc toPixels:body->GetPosition()];
            float angle = body->GetAngle();
            sprite.rotation = CC_RADIANS_TO_DEGREES(angle) * -1;
        }
    }
}

// 延时显示“下一步”menuItem
- (void)showItemContinue
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    [CCMenuItemFont setFontSize:18];
    itemShuffleFinished = [CCMenuItemFont itemWithString:NSLocalizedString(@"next", @"Next") block:^(id sender) {
        if (kShufflePhase == gamePhase) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"se_next.mp3"];
            [self unscheduleUpdate];
            [self finishShuffle];
            
            [itemShuffleFinished removeFromParentAndCleanup:YES];
        }
    }
                           ];
    
    CCMenu *menu = [CCMenu menuWithItems:itemShuffleFinished, nil];
    [menu setPosition:ccp(size.width - 40, 20)];
    [self addChild:menu z:20];
}

// 完成洗牌
- (void)finishShuffle
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    // 每张卡片与中心位置的偏移量（洗牌完毕时）
    float dHeightHasShuffled = 0.0f;
    float dWidthHasShuffled = 0.0f;
    
    // 每张卡片与中心位置的偏移量（抽牌时）
    float dRotationDrawPhase = 84.0f;
    float dTime = 0.0f;
    float r = 180.0f;
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"se_slidecard.mp3"];
    // 遍历刚体，做洗完牌的动画
    for (b2Body *body = world->GetBodyList(); body != nil; body = body->GetNext())
    {
        CCSprite *sprite = (CCSprite *)body->GetUserData();
        if (sprite != nil) {
            
            CCMoveTo *actionMoveTo1 = [CCMoveTo actionWithDuration:.5f position:ccp(size.width / 2 - dWidthHasShuffled - 10, size.height / 2  + dHeightHasShuffled)];
            CCRotateTo *actionRotateTo1 = [CCRotateTo actionWithDuration:.5f angle:0];
            CCSpawn *actionSpawn1 = [CCSpawn actions:actionMoveTo1, actionRotateTo1, nil];
            
            CCMoveTo *actionMoveTo2 = [CCMoveTo actionWithDuration:.5f position:ccp(size.width / 2 - dWidthHasShuffled - 10, size.height / 2  + dHeightHasShuffled +100)];
            
            int plusOrMinus;
            if (dRotationDrawPhase > 0) {
                plusOrMinus = - 1;
            }
            else {
                plusOrMinus = 1;
            }
            float dx = plusOrMinus * r * sin(CC_DEGREES_TO_RADIANS(ABS(dRotationDrawPhase)));
            float dy = r * cos(CC_DEGREES_TO_RADIANS(ABS(dRotationDrawPhase)));
            CCMoveTo *actionMoveTo3 = [CCMoveTo actionWithDuration:.5f + dTime position:ccp(size.width / 2 + dx, size.height - dy - 40)];
            CCRotateTo *actionRotateTo2 = [CCRotateTo actionWithDuration:.5f + dTime angle:dRotationDrawPhase];
            CCSpawn *actionSpawn2 = [CCSpawn actions:actionMoveTo3, actionRotateTo2, nil];
            
            CCSequence *actionSequence = [CCSequence actions:actionSpawn1, actionMoveTo2, actionSpawn2, nil];
            
            [sprite runAction:actionSequence];
            
            -- dHeightHasShuffled;
            dWidthHasShuffled -= 0.2f;
            
            dRotationDrawPhase -= 8.0f;
            dTime += 0.05f;
        }
    }
    
    // 待动画完成后再改变游戏阶段
    [NSTimer scheduledTimerWithTimeInterval:1.5f + dTime target:self selector:@selector(changeToDrawPhase) userInfo:nil repeats:NO];
}

// 延时变为抽卡阶段
- (void)changeToDrawPhase
{
    gamePhase = kDrawPhase;
}

#pragma mark - drawPhase
// 遍历所有卡片精灵，判断有无精灵被选中
- (void)chooseCardAtPoint:(CGPoint)touchPoint
{
    [self resetShuffledCards];
    BOOL someCardTouched = NO;
    
    for (b2Body *body = world->GetBodyList(); body != nil; body = body->GetNext()) {
        CCSprite *sprite = (CCSprite *)body->GetUserData();
        if (sprite != nil) {
            if ([self theSpriteHasBeenChossen:sprite WithTouchPoint:touchPoint]) {
                // 选中的卡片精灵出列
                sprite.position = ccp(sprite.position.x - 10 * sin(CC_DEGREES_TO_RADIANS(sprite.rotation)), sprite.position.y - 10 * cos(CC_DEGREES_TO_RADIANS(sprite.rotation)));
                someCardTouched = YES;
                break;
            }
        }
    }
    if (!someCardTouched) {
        choosenCard = nil;
    }
}

// 选择卡片时，先将所有卡片恢复原状
- (void)resetShuffledCards
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    // 每张卡片与中心位置的偏移量（抽牌时）
    float dRotationDrawPhase = 84.0f;
    float r = 180.0f;
    
    for (b2Body *body = world->GetBodyList(); body != nil; body = body->GetNext()) {
        CCSprite *sprite = (CCSprite *)body->GetUserData();
        if (sprite != nil) {
            int plusOrMinus;
            if (dRotationDrawPhase > 0) {
                plusOrMinus = - 1;
            }
            else {
                plusOrMinus = 1;
            }
            
            float dx = plusOrMinus * r * sin(CC_DEGREES_TO_RADIANS(ABS(dRotationDrawPhase)));
            float dy = r * cos(CC_DEGREES_TO_RADIANS(ABS(dRotationDrawPhase)));
            sprite.position = ccp(size.width / 2 + dx, size.height - dy - 40);
            sprite.rotation = dRotationDrawPhase;
            dRotationDrawPhase -= 8.0f;
        }
    }
}

// 选中一张卡片后做的动画
- (void)selectOneCard
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"se_slidecard.mp3"];
    // 每张卡片与中心位置的偏移量
    float dHeight = 100.0f;
    float dWidth = 0.0f;
    
    CGSize size = [[CCDirector sharedDirector] winSize];
    for (b2Body *body = world->GetBodyList(); body != nil; body = body->GetNext()) {
        CCSprite *sprite = (CCSprite *)body->GetUserData();
        if (sprite != nil && sprite != choosenCard) {
            CCMoveTo *actionMoveTo1 = [CCMoveTo actionWithDuration:.5f position:ccp(size.width / 2 - dWidth - 10, size.height / 2  + dHeight)];
            CCRotateTo *actionRotateTo1 = [CCRotateTo actionWithDuration:.5f angle:0];
            CCSpawn *actionSpawn1 = [CCSpawn actions:actionMoveTo1, actionRotateTo1, nil];
            
            CCMoveTo *actionMoveTo2 = [CCMoveTo actionWithDuration:.5f position:ccp(size.width / 2 - dWidth - 10, size.height / 2  + dHeight +200)];
            CCSequence *actionSeq = [CCSequence actions:actionSpawn1, actionMoveTo2, nil];
            
            [sprite runAction:actionSeq];
            -- dHeight;
            dWidth -= 0.2f;
        }
        
    }
    
    // 待动画完成后再移动选中卡片
    [NSTimer scheduledTimerWithTimeInterval:.5f target:self selector:@selector(moveChoosedCardToCenter) userInfo:nil repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(changeToOpenCardPhase) userInfo:nil repeats:NO];
}

// 延时做移动选中牌的动画
- (void)moveChoosedCardToCenter
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    CCMoveTo *actionMoveTo = [CCMoveTo actionWithDuration:1.0f position:ccp(size.width / 2, size.height / 2)];
    CCRotateTo *actionRotateTo = [CCRotateTo actionWithDuration:1.0f angle:0];
    CCSpawn *actionSpawn = [CCSpawn actions:actionMoveTo, actionRotateTo, nil];
    
    [choosenCard runAction:actionSpawn];
}

// 延时变为开卡阶段
- (void)changeToOpenCardPhase
{
    gamePhase = kOpenCardPhase;
    
}

#pragma mark - openCardPhase
- (void)openCardAtPoint:(CGPoint)touchPoint
{    
    if (choosenCard != nil) {
        if ([self theSpriteHasBeenChossen:choosenCard WithTouchPoint:touchPoint]) {
            gamePhase = kAnimationPhase;
            
            CCScaleTo *actionScale = [CCScaleTo actionWithDuration:.2 scaleX:0.0 scaleY:choosenCard.scaleY];
            [choosenCard runAction:actionScale];
            
            int choosenCardIndex = arc4random() % 22;
            choosenTarot = [[CommonData sharedData].tarotDeck objectAtIndex:choosenCardIndex];
            
            CGSize size = [[CCDirector sharedDirector] winSize];
            choosenCardFront = [CCSprite spriteWithFile:choosenTarot.cardPicName];
            choosenCardFront.position = ccp(size.width / 2, size.height / 2);
            BOOL isReversed = arc4random() % 2;
            if (isReversed) {
                choosenCardFront.rotation = 180;
                choosenTarot.isReversed = YES;
            }
            else {
                choosenCardFront.rotation = 0;
                choosenTarot.isReversed = NO;
            }
            
            choosenCardFront.scaleX = 0.0;
            choosenCardFront.scaleY = size.width / choosenCardFront.textureRect.size.width * CARD_SCALE;
            [self addChild:choosenCardFront z:20];
            [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(openCardAnimation) userInfo:nil repeats:NO];
        }
    }
}


// 开卡阶段动画
- (void)openCardAnimation
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"se_zoom.mp3"];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bgm_choose.mp3" loop:YES];
    CGSize size = [[CCDirector sharedDirector] winSize];
    float scaleTo = size.height / choosenCardFront.textureRect.size.height;
    CCScaleTo *actionScale1 = [CCScaleTo actionWithDuration:.2 scaleX:choosenCardFront.scaleY scaleY:choosenCardFront.scaleY];
    CCScaleTo *actionScale2 = [CCScaleTo actionWithDuration:.2 scaleX:scaleTo scaleY:scaleTo];
    CGPoint position = ccp(choosenCardFront.textureRect.size.width * scaleTo / 2, choosenCardFront.textureRect.size.height * scaleTo / 2);
    CCMoveTo *actionMove = [CCMoveTo actionWithDuration:.2 position:position];
    CCSpawn *actionSpawn = [CCSpawn actions:actionScale2, actionMove, nil];
    CCSequence *actionSeq = [CCSequence actions:actionScale1, actionSpawn, nil];
    [choosenCardFront runAction:actionSeq];
    
    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(showTarotDetail) userInfo:nil repeats:NO];
}

#pragma mark - showCardInfoPhase
- (void)showTarotDetail
{
    // 开卡阶段
    gamePhase = kShowCardInfoPhase;
    CGSize size = [[CCDirector sharedDirector] winSize];
    // 卡片缩放比例
    float scaleTo = size.height / choosenCardFront.textureRect.size.height;
    
    // 卡片标题
    NSString *title = [NSString stringWithFormat:@"%@  %@", choosenTarot.cardSequence, choosenTarot.cardName];
    CCLabelTTF *cardTitleLb = [CCLabelTTF labelWithString:title fontName:@"Marker Felt" fontSize:30];
    cardTitleLb.position = ccp(size.width / 2 + choosenCardFront.textureRect.size.width * scaleTo / 2, size.height - 25);
    
    NSString *type;
    NSString *mean;
    if (choosenTarot.isReversed) {
        type = [NSString stringWithFormat:@"%@", NSLocalizedString(@"reverse", @"Reversed")];
        mean = choosenTarot.inverseMean;
    }
    else {
        type = [NSString stringWithFormat:@"%@", NSLocalizedString(@"normal", @"Normal")];
        mean = choosenTarot.normalMean;
    }
    // 卡片朝向（正或逆）
    CCLabelTTF *cardTypeLb = [CCLabelTTF labelWithString:type fontName:@"Marker Felt" fontSize:20];
    cardTypeLb.position = ccp(size.width / 2 + choosenCardFront.textureRect.size.width * scaleTo / 2, size.height - 55);
    
    // 卡片内容
    float meanWidth = size.width - choosenCardFront.textureRect.size.width * choosenCardFront.scaleX - 15;
    float meanHeight = size.height - 80;
    cardMean = [ScrollLabelTTF labelWithString:mean dimensions:CGSizeMake(meanWidth, meanHeight) alignment:kCCTextAlignmentLeft fontName:@"Marker Felt" fontSize:20];
    cardMean.position = ccp(choosenCardFront.textureRect.size.width * scaleTo + 10, 10);
    [cardMean setString:mean];
    
    CCSprite *textView = [CCSprite spriteWithFile:@"myTextBG.png"];
    textView.scaleY = size.height / textView.textureRect.size.height;
    textView.scaleX = .83f * textView.scaleY;
    textView.position = ccp(size.width / 2 + choosenCardFront.textureRect.size.width * scaleTo / 2, size.height / 2);
    [self addChild:textView z:0];
    
    [CCMenuItemFont setFontSize:18];
    itemRetry = [CCMenuItemFont itemWithString:NSLocalizedString(@"retry", @"retry") block:^(id sender) {
        [[SimpleAudioEngine sharedEngine] playEffect:@"se_back.mp3"];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bgm_opening.mp3" loop:YES];
        CCTransitionFade *tran = [CCTransitionFade transitionWithDuration:1 scene:[HelloWorldLayer scene] withColor:ccBLACK];
        [[CCDirector sharedDirector] replaceScene:tran];
    }
                           ];
    CCMenu *menu = [CCMenu menuWithItems:itemRetry, nil];
    [menu setPosition:ccp(size.width - 25, size.height - 20)];
    

    [self addChild:cardTitleLb];
    [self addChild:cardTypeLb];
    [self addChild:cardMean z:30];
    [self addChild:menu z:20];
}

@end
