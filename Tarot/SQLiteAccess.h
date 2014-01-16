//
//  SQLiteAccess.h
//  Tarot
//
//  Created by huangyimin on 12-12-24.
//
//

#import <Foundation/Foundation.h>

@interface SQLiteAccess : NSObject

/*
 * 方法名：filePath
 * 参数：-
 * 返回值：nsstring
 * 功能：返回sqlite路径
 */
+ (NSString *)filePath;

+ (void)loadAllCardsInfo;
@end
