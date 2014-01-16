//
//  SQLiteAccess.m
//  Tarot
//
//  Created by huangyimin on 12-12-24.
//
//

#import "SQLiteAccess.h"
#import "TarotCard.h"
#import "CommonData.h"
#import <sqlite3.h>

@implementation SQLiteAccess

+ (NSString *)filePath
{
    NSString *fileFullPath = [NSString stringWithFormat:@"%@/Tarot.app/TAROT.db",NSHomeDirectory()];
    return fileFullPath;
}

+ (void)loadAllCardsInfo
{
    sqlite3 *myDBHandle;
    NSString *fileName = [SQLiteAccess filePath];
    
    if (SQLITE_OK != sqlite3_open([fileName UTF8String], &myDBHandle)) {
        sqlite3_close(myDBHandle);
        NSAssert(NO, @"数据库打开失败。");
    }
    else {
        NSString *qsql = [NSString stringWithFormat:@"SELECT a.card_id, card_sequence, card_pic_name, card_name, card_normal_mean, card_inverse_mean FROM TAROT_CARD a, %@ b WHERE a.card_id = b.card_id", NSLocalizedString(@"tableTarotMean", @"TAROT_MEAN_EN")];
        sqlite3_stmt *statement;
        if (SQLITE_OK == sqlite3_prepare_v2(myDBHandle, [qsql UTF8String], -1, &statement, NULL)) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                TarotCard *oneCard = [[TarotCard alloc] init];
                
                char *chCardID = (char *)sqlite3_column_text(statement, 0);
                oneCard.cardID = atoi(chCardID);
                char *chCardSequence = (char *)sqlite3_column_text(statement, 1);
                oneCard.cardSequence = [NSString stringWithUTF8String:chCardSequence];
                char *chCardPicName = (char *)sqlite3_column_text(statement, 2);
                oneCard.cardPicName = [NSString stringWithUTF8String:chCardPicName];
                oneCard.cardPic = [UIImage imageNamed:oneCard.cardPicName];
                char *chCardName = (char *)sqlite3_column_text(statement, 3);
                oneCard.cardName = [NSString stringWithUTF8String:chCardName];
                char *chCardNormalMean = (char *)sqlite3_column_text(statement, 4);
                oneCard.normalMean = [NSString stringWithUTF8String:chCardNormalMean];
                char *chCardInverseMean = (char *)sqlite3_column_text(statement, 5);
                oneCard.inverseMean = [NSString stringWithUTF8String:chCardInverseMean];
                
                [[CommonData sharedData].tarotDeck addObject:oneCard];
            }
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(myDBHandle);
}
@end
