//
//  AJMPMediaPreviewerVideoPlayerView.h
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/20.
//  Copyright © 2017年 AJ. All rights reserved.
//

/*
 图片、视频 预览器vc - 视频播放view
 */

#import <UIKit/UIKit.h>
#import "AJMPMediaInfoModel.h"

@interface AJMPMediaPreviewerVideoPlayerView : UIView

-(void)setVideoPreviewerMediaInfoModel:(AJMPMediaInfoModel *)mediaInfoModel maxNumberOfMedia:(int)maxNumberOfMedia selectedMediaInfoModelArray:(NSMutableArray *)selectedMediaInfoModelArray chooseBtnClickBlock:(void(^)(AJMPMediaInfoModel * mediaInfoModel))chooseBtnClickBlock;

//视图消失时候做的操作
-(void)disappearAction;

@end
