//
//  AJMPAlbumInfoModel.h
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/5/28.
//  Copyright © 2017年 AJ. All rights reserved.
//

/*
 相册信息model
 */

#import <Foundation/Foundation.h>

@interface AJMPAlbumInfoModel : NSObject

/**
 相册的名
 */
@property (nonatomic ,copy)NSString * albumName;


/**
 AJMediaInfoModel数组
 */
@property (nonatomic ,retain)NSArray * mediaInfoModelArray;

@end
