//
//  AJMPMediaInfoModel.h
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/5/28.
//  Copyright © 2017年 AJ. All rights reserved.
//

/**
 媒体资源信息model
 */

//上传状态类型
typedef enum{
    AJMPMediaInfoModelUploadState_NotUploaded=0,  //未上传（默认）
    AJMPMediaInfoModelUploadState_Uploading,      //上传中
    AJMPMediaInfoModelUploadState_UploadFail,     //上传失败
    AJMPMediaInfoModelUploadState_UploadSuccess   //上传成功
} AJMPMediaInfoModelUploadState;

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface AJMPMediaInfoModel : NSObject

/**
 媒体信息资源
 */
@property (nonatomic ,retain)PHAsset * asset;

/**
 是否选中该资源
 */
@property (nonatomic ,assign)BOOL isChooseStatus;



#pragma mark - image

/**
 原图
 */
@property (nonatomic ,retain)UIImage * originalImage;

/**
 原图上传后的图片地址
 */
@property (nonatomic ,copy)NSString * originalImageURLString;



#pragma mark - video

/**
 视频data
 */
@property (nonatomic ,retain)NSData * videoData;

/**
 视频格式
 */
@property (nonatomic ,retain)NSString * videoFileFormat;

/**
 视频上传后的图片地址
 */
@property (nonatomic ,copy)NSString * videoURLString;



#pragma mark - 媒体资源上传的状态

@property (nonatomic ,assign)AJMPMediaInfoModelUploadState uploadState;


@end
