//
//  CommonData.h
//  Tarot
//
//  Created by huangyimin on 12-12-21.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    kStandbyPhase = 0,
    kShufflePhase,
    kDrawPhase,
    kOpenCardPhase,
    kShowCardInfoPhase,
    kAnimationPhase
}
GamePhase;

@interface CommonData : NSObject

@property(retain, nonatomic)NSMutableArray *tarotDeck;

//获取单例
+(CommonData *)sharedData;
@end
