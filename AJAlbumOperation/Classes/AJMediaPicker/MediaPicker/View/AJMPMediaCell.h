//
//  AJMPMediaCell.h
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/5/28.
//  Copyright © 2017年 AJ. All rights reserved.
//

/*
 展示媒体的 CollectionViewCell
 */

#import <UIKit/UIKit.h>
#import "AJMPMediaInfoModel.h"
#import "AJMPMultipleImageSelectViewController.h"

@interface AJMPMediaCell : UICollectionViewCell

#pragma mark -

/**
 媒体资源
 */
@property (nonatomic ,retain)AJMPMediaInfoModel * mediaInfoModel;

/*
 整个相册的数据源（用来遍历相同的图片）
 */
@property (nonatomic ,retain)NSMutableArray * albumInfoModelArray;



#pragma mark -

/**
 相机按钮点击时，回调的block
 */
@property (nonatomic ,copy)void(^cameraBtnClickBlock)();

/**
 选择图片 时候的回调
 */
@property (nonatomic ,copy)void(^choosePicBlock)(BOOL isChoose);



#pragma mark - 按钮点击

/**
 是否是第一个相机cell
 */
@property (nonatomic ,assign)BOOL isCameraCellStatus;


/**
 是否点击了选择按钮
 */
@property (nonatomic ,assign)BOOL isCheckChooseBtnStatus;


#pragma mark -

/**
 选择资源的类型
 */
@property (nonatomic ,assign)AJMediaPickerType mediaPickerType;


#pragma mark -

/**
 单选图片选择器(并裁剪)-图片点击手势回调
 */
@property (nonatomic ,copy)void(^singleImageSelectWithCropperTapGestureBlock)(UIImage * originalImage);



@end
