//
//  AJImageCropperViewController.h
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/19.
//  Copyright © 2017年 AJ. All rights reserved.
//

/*
 图片裁剪vc
 */

#import <UIKit/UIKit.h>

@protocol AJImageCropperViewControllerDelegate;

@interface AJImageCropperViewController : UIViewController


#pragma mark -

//- (instancetype)initWithImage:(UIImage *)originalImage;
//- (instancetype)initWithImages:(NSArray *)images;


#pragma mark -


/**
 初始化设置

 @param image 图片
 @param cropperWidthRatio 裁剪的宽度比例（例如：4:3 中的4）
 @param cropperHeightRatio 裁剪的高度比例（例如：4:3 中的3）
 @param delegate 代理
 */
-(void)setImage:(UIImage *)image cropperWidthRatio:(CGFloat)cropperWidthRatio cropperHeightRatio:(CGFloat)cropperHeightRatio delegate:(id<AJImageCropperViewControllerDelegate>)delegate;



@end


#pragma mark -


@protocol AJImageCropperViewControllerDelegate <NSObject>

/**
 裁剪成功之后走的代理
 
 @param controller 裁剪视图控制器
 @param croppedImage 裁剪后的图片
 */
- (void)imageCropperViewController:(AJImageCropperViewController *)controller didCropImage:(UIImage *)croppedImage;

@end
