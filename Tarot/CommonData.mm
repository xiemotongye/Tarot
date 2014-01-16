//
//  CommonData.m
//  Tarot
//
//  Created by huangyimin on 12-12-21.
//
//

#import "CommonData.h"

static CommonData *commonData = nil;

@implementation CommonData

- (id)init
{
    self = [super init];
    if (self) {
        self.tarotDeck = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    self.tarotDeck = nil;
    [super dealloc];
}

//获取单例
+(CommonData *)sharedData
{
    @synchronized(self) {
        if (commonData == nil){
            commonData = [[self alloc] init];
        }
    }
    return commonData;
}
//copy返回单例本身
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}
//retain返回单例本身
- (id)retain
{
    return self;
}
//引用计数总是为1
- (unsigned)retainCount
{
    return 1;
}
//release不做任何处理
-(oneway void)release
{
    
}
//autorelease返回单例本身
- (id)autorelease
{
    return self;
}

@end
