//
//  AJMPAlbumListView.h
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/1.
//  Copyright © 2017年 AJ. All rights reserved.
//

/*
 相册选择列表视图
 */

#import <UIKit/UIKit.h>
#import "AJMPAlbumInfoModel.h"

@interface AJMPAlbumListView : UIView

/**
 所有的相册数据源
 */
@property (nonatomic ,retain)NSArray * dataSource;


/**
 选择相册之后、传递相册数据源
 */
@property (nonatomic ,copy)void(^didSelectAlbumBlock)(AJMPAlbumInfoModel * albumInfoModel);

@end
