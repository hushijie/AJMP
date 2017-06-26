//
//  AJMPAlbumCell.h
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/5/29.
//  Copyright © 2017年 AJ. All rights reserved.
//

/*
 相册选择列表视图中的相册cell
 */

#import <UIKit/UIKit.h>

@interface AJMPAlbumCell : UITableViewCell

/**
 相册封面图
 */
@property (nonatomic ,weak)UIImageView * picImageView;

/**
 相册名
 */
@property (nonatomic ,weak)UILabel * albumNameLabel;

/**
 相册中相片数
 */
@property (nonatomic ,weak)UILabel * albumPicNumLabel;


#pragma mark -

+(id)albumCellWithTableView:(UITableView *)tableView;

@end
