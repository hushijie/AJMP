//
//  AJMPMediaPreviewerImagePlayerCell.h
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/21.
//  Copyright © 2017年 AJ. All rights reserved.
//

/*
 图片、视频 预览器vc - 图片展示view（可滚动，多选图片）- 自定义cell
 */

#import <UIKit/UIKit.h>
#import "AJMPMediaInfoModel.h"

@interface AJMPMediaPreviewerImagePlayerCell : UICollectionViewCell

-(void)setMediaInfoModel:(AJMPMediaInfoModel *)mediaInfoModel maxNumberOfMedia:(int)maxNumberOfMedia selectedMediaInfoModelArray:(NSMutableArray *)selectedMediaInfoModelArray chooseBtnClickBlock:(void(^)(AJMPMediaInfoModel * mediaInfoModel))chooseBtnClickBlock;


@end
