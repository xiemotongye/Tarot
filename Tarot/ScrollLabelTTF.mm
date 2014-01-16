//
//  ScrollLabelTTF.m
//  ScrollLabel
//
//  Created by huangyimin on 12-12-25.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "ScrollLabelTTF.h"

#define AutoMoveSpeed 0.5f  //自动移动速度
@implementation ScrollLabelTTF


+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size
{
    ScrollLabelTTF* label  = [self labelWithString:string dimensions:dimensions alignment:alignment fontName:name fontSize:size background:ccc4(255, 255, 255, 0)];
    return label;
}


+ (id) labelWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size background:(ccColor4B)background
{
    ScrollLabelTTF* label  =[[[self alloc]initWithString:string dimensions:dimensions alignment:alignment fontName:name fontSize:size background:background]autorelease];
    return label;
    
}


-  (id) initWithString:(NSString*)string dimensions:(CGSize)dimensions alignment:(CCTextAlignment)alignment fontName:(NSString*)name fontSize:(CGFloat)size background:(ccColor4B)background
{
    if (self = [super initWithColor:background]) {
        self.contentSize = dimensions;
        alignment_ = alignment;
        fontName_ = name;
        fontSize_ = size;
        label_ = [CCLabelTTF labelWithString:string
                                  dimensions:CGSizeMake(self.contentSize.width, 1000)
                                   hAlignment:alignment
                                    fontName:name
                                    fontSize:size];
        label_.anchorPoint = ccp(0, 1);
        label_.color = ccc3(255, 255, 255);
        [self addChild:label_];
    }
    return self;
}

/** 设置显示的文本 */
- (void)setString:(NSString*)string
{
    [self stopAllActions];
    [self unscheduleUpdate];
    self.isTouchEnabled = NO;
    
    [label_ setString:string];
    
    label_.position = ccp(0, self.contentSize.height-5);
    
    //计算字符串的长度和宽度
    UIFont *font = [UIFont fontWithName:fontName_ size:fontSize_];
    CGSize asize = CGSizeMake(self.contentSize.width,9999);
    textSize_ = [string sizeWithFont:font constrainedToSize:asize lineBreakMode:UILineBreakModeCharacterWrap];
    
    if (textSize_.height > self.contentSize.height) {
        self.isTouchEnabled = YES;
    }
    
}


-(CGRect) rect
{
	return CGRectMake( position_.x - contentSize_.width*anchorPoint_.x,
					  position_.y - contentSize_.height*anchorPoint_.y,
					  contentSize_.width, contentSize_.height);
}

- (void)registerWithTouchDispatcher
{
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
    
}

/** 触摸屏幕时，停止文字自动滚动效果，转到手动滚动功能 */
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInView: [touch view]];
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    CGRect r = [self rect];
    r.origin = self.position;
    if( CGRectContainsPoint( r, touchLocation ) ){
        return YES;
    }
    return NO;
}

/** 文本跟着手指滚动 */
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event;
{
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    CGPoint previousLocation = [touch previousLocationInView:[touch view]];
    previousLocation = [[CCDirector sharedDirector] convertToGL:previousLocation];
    
    CGFloat moved = location.y-previousLocation.y;
    if (label_) {
        CGFloat newY = label_.position.y + moved;
        if (newY < contentSize_.height ) {
            newY = contentSize_.height;
        } else if (newY > textSize_.height){
            newY = textSize_.height;
        }
        label_.position = ccp(label_.position.x, newY);
    }
}


/** 重写visit方法，裁剪，只显示当前控件指定的ContentSize区域，超出该区域的不显示 */
- (void)visit
{
    CGFloat scale = [[CCDirector sharedDirector] contentScaleFactor];
    CGPoint pos = self.position;
    
    glEnable(GL_SCISSOR_TEST);
    glScissor(pos.x*scale,
              pos.y*scale,
              self.contentSize.width*scale,
              self.contentSize.height*scale);
	[super visit];
	glDisable(GL_SCISSOR_TEST);
    
}
@end
