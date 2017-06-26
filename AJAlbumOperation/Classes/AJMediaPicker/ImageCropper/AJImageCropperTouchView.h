//
//  AJImageCropperTouchView.h
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/19.
//  Copyright © 2017年 AJ. All rights reserved.
//

/*
 AJImageCropper-黑色透明遮罩
 作用：操作事件传递给底部scrollerView！
 */

#import <UIKit/UIKit.h>

@interface AJImageCropperTouchView : UIView

@property (weak, nonatomic) UIView *receiver;

@end
