//
//  ScrollLabelTTF.h
//  ScrollLabel
//
//  Created by huangyimin on 12-12-25.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/** 可循环滚动的文字 */
@interface ScrollLabelTTF : CCLayerColor {
    CCLabelTTF  *label_;
    CGSize      textSize_;
    
    CCTextAlignment alignment_;
	NSString * fontName_;
	CGFloat fontSize_;
	CCLineBreakMode lineBreakMode_;    
}

+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size;

+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size background:(ccColor4B)background;

- (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size background:(ccColor4B)background;

/** 设置显示的文本 */
- (void)setString:(NSString*)string;
@end
