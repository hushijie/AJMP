//
//  AJMPMediaPreviewerViewController.h
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/20.
//  Copyright © 2017年 AJ. All rights reserved.
//

/*
 图片、视频 预览器vc
 */

//媒体预览类型
typedef enum{
    AJMPMediaPreviewerType_Image=0, //图片（默认）
    AJMPMediaPreviewerType_Video    //视频
} AJMPMediaPreviewerType;

#import <UIKit/UIKit.h>
#import "AJMPMediaInfoModel.h"

@interface AJMPMediaPreviewerViewController : UIViewController


#pragma mark - 视频预览器初始化设置

/**
 视频预览器初始化设置
 
 @param mediaInfoModel 媒体资源model
 @param maxNumberOfMedia 最大资源选择数量
 @param selectedMediaInfoModelArray 已勾选的媒体资源数组
 @param chooseBtnClickBlock “勾选”按钮点击block
 @param confirmSelectedMediaInfoArrayBlock “完成”按钮点击block
 */
-(void)setVideoPreviewerMediaInfoModel:(AJMPMediaInfoModel *)mediaInfoModel maxNumberOfMedia:(int)maxNumberOfMedia selectedMediaInfoModelArray:(NSMutableArray *)selectedMediaInfoModelArray chooseBtnClickBlock:(void(^)(AJMPMediaInfoModel * mediaInfoModel))chooseBtnClickBlock confirmSelectedMediaInfoArrayBlock:(void(^)(NSMutableArray * mediaInfoModelArray))confirmSelectedMediaInfoArrayBlock;



#pragma mark - 图片预览器初始化设置

/**
 图片预览器初始化设置

 @param currentIndex 当前点击图片的下标
 @param maxNumberOfMedia 最大资源选择数量
 @param selectedMediaInfoModelArray 已勾选的媒体资源数组
 @param allMediaInfoModelArray 所有的媒体资源数组
 @param chooseBtnClickBlock “勾选”按钮点击block
 @param confirmSelectedMediaInfoArrayBlock “完成”按钮点击block
 */
-(void)setImagePreviewerWithCurrentIndex:(int)currentIndex maxNumberOfMedia:(int)maxNumberOfMedia selectedMediaInfoModelArray:(NSMutableArray *)selectedMediaInfoModelArray allMediaInfoModelArray:(NSArray *)allMediaInfoModelArray chooseBtnClickBlock:(void(^)(AJMPMediaInfoModel * mediaInfoModel))chooseBtnClickBlock confirmSelectedMediaInfoArrayBlock:(void(^)(NSMutableArray * mediaInfoModelArray))confirmSelectedMediaInfoArrayBlock;



@end
