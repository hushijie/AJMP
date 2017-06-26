//
//  AJMPMediaPreviewerImagePlayerView.h
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/21.
//  Copyright © 2017年 AJ. All rights reserved.
//

/*
 图片、视频 预览器vc - 图片展示view（可滚动，多选图片）
 */

#import <UIKit/UIKit.h>
#import "AJMPMediaInfoModel.h"

@interface AJMPMediaPreviewerImagePlayerView : UIView

-(void)setImagePreviewerWithCurrentIndex:(int)currentIndex maxNumberOfMedia:(int)maxNumberOfMedia selectedMediaInfoModelArray:(NSMutableArray *)selectedMediaInfoModelArray allMediaInfoModelArray:(NSArray *)allMediaInfoModelArray chooseBtnClickBlock:(void(^)(AJMPMediaInfoModel * mediaInfoModel))chooseBtnClickBlock itemScrollBlock:(void(^)(int indexRow))itemScrollBlock;

@end
