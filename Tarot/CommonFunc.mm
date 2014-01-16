//
//  CommonFunc.m
//  Tarot
//
//  Created by huangyimin on 12-12-19.
//
//

#import "CommonFunc.h"

@implementation CommonFunc

+ (b2Vec2)toMeters:(CGPoint)point
{
    return b2Vec2(point.x / PTM_RATIO, point.y / PTM_RATIO);
}

+ (CGPoint)toPixels:(b2Vec2)vec
{
    return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}
@end
