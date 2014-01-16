//
//  TarotCard.h
//  TarotCardGame
//
//  Created by huangyimin on 12-12-18.
//
//

#import <Foundation/Foundation.h>

@interface TarotCard : NSObject

@property int cardID;
@property (nonatomic, copy) NSString *cardSequence;
@property (nonatomic, copy) NSString *cardPicName;
@property (nonatomic, retain) UIImage *cardPic;
@property (nonatomic, copy) NSString *cardName;
@property (nonatomic, copy) NSString *normalMean;
@property (nonatomic, copy) NSString *inverseMean;
@property BOOL isReversed;

@end
