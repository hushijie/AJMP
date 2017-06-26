//
//  AJImageCropperScrollView.h
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/19.
//  Copyright © 2017年 AJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AJImageCropperScrollView : UIScrollView

@property (nonatomic, strong) UIImageView *zoomView;

- (void)displayImage:(UIImage *)image;

@end
