//
//  TarotCard.m
//  TarotCardGame
//
//  Created by huangyimin on 12-12-18.
//
//

#import "TarotCard.h"

@implementation TarotCard

- (void)dealloc
{
    self.cardSequence = nil;
    self.cardName = nil;
    self.cardPicName = nil;
    self.cardPic = nil;
    self.normalMean = nil;
    self.inverseMean = nil;
    
    [super dealloc];
}

@end
