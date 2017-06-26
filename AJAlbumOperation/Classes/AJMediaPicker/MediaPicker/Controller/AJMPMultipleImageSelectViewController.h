//
//  AJMPMultipleImageSelectViewController.h
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/1.
//  Copyright © 2017年 AJ. All rights reserved.
//

/*
 多图选择VC
 */

//媒体选择类型
typedef enum{
    AJMediaPickerType_MultipleImageSelect=0,                //多图选择（默认）
    AJMediaPickerType_SingleImageSelectWithCropper,         //单图裁剪
    AJMediaPickerType_VideoSelect                           //视频选择
} AJMediaPickerType;


#import <UIKit/UIKit.h>

@interface AJMPMultipleImageSelectViewController : UIViewController


/**
 类型：AJMediaPickerType_MultipleImageSelect、AJMediaPickerType_VideoSelect 的初始化设置

 @param mediaPickerType 媒体选择类型
 @param maxNumberOfMedia 媒体资源的最大选择个数
 @param currentSelectedMediaInfoModelArray 当前选中的媒体资源model数组
 @param confirmSelectedMediaInfoArrayBlock 返回选中的媒体资源model数组的block
 */
-(void)setMediaPickerType:(AJMediaPickerType)mediaPickerType maxNumberOfMedia:(int)maxNumberOfMedia currentSelectedMediaInfoModelArray:(NSMutableArray *)currentSelectedMediaInfoModelArray confirmSelectedMediaInfoArrayBlock:(void(^)(NSMutableArray * mediaInfoModelArray))confirmSelectedMediaInfoArrayBlock;



/**
 类型：AJMediaPickerType_SingleImageSelectWithCropper 的初始化设置

 @param widthRatio 宽度比例
 @param heightRatio 高度比例
 @param backCroppedImageBlock 返回裁剪后图片的block
 */
-(void)setSingleImageSelectWithCropperWidthRatio:(CGFloat)widthRatio heightRatio:(CGFloat)heightRatio backCroppedImageBlock:(void(^)(UIImage * croppedImage))backCroppedImageBlock;



@end
