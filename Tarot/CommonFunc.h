//
//  CommonFunc.h
//  Tarot
//
//  Created by huangyimin on 12-12-19.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#define PTM_RATIO 32
@interface CommonFunc : NSObject

+ (b2Vec2)toMeters:(CGPoint)point;
+ (CGPoint)toPixels:(b2Vec2)vec;

@end
