//
//  AJMPBottomView.h
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/1.
//  Copyright © 2017年 AJ. All rights reserved.
//

/*
 媒体选择器-底部view
 */

#import <UIKit/UIKit.h>

@interface AJMPBottomView : UIView

#pragma mark -

@property (nonatomic ,weak)UIButton * cancelBtn;

#pragma mark -

@property (nonatomic ,copy)void(^cancelBtnClickBlock)();

@property (nonatomic ,copy)void(^confirmBtnClickBlock)();


#pragma mark -

+(id)bottomView;

/**
 设置“完成”按钮的文字
 
 @param currentCount 现在的数量
 @param maxCount 最大数量(maxCount=0,表示没有限制，即无穷大)
 */
-(void)setConfirmBtnCurrentCount:(long)currentCount maxCount:(long)maxCount;

@end
