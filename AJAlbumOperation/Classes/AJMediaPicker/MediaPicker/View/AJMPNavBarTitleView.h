//
//  AJMPNavBarTitleView.h
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/1.
//  Copyright © 2017年 AJ. All rights reserved.
//

/*
 图片选择器navigationBar上的标题view
 */

#import <UIKit/UIKit.h>
#import "AJMPAlbumInfoModel.h"

@interface AJMPNavBarTitleView : UIView


/**
 上下箭头
 */
@property (nonatomic ,weak)UIButton * upDownArrowBtn;


/**
 相册信息model
 */
@property (nonatomic ,retain)AJMPAlbumInfoModel * albumInfoModel;


/**
 点击上下箭头时候的回调：isSelectArrow=YES:选择了、isSelectArrow=No:没有选择
 */
@property (nonatomic ,copy)void(^isSelectArrowBlock)(BOOL isSelectArrowStatus);


#pragma mark -

+(id)titleView;

@end
