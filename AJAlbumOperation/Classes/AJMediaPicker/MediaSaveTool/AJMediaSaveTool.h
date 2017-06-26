//
//  AJMediaSaveTool.h
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/19.
//  Copyright © 2017年 AJ. All rights reserved.
//

/*
 媒体资源（图片、视频）保存工具类
 */

typedef enum {
    AJMediaSaveType_Image,     /** 图片 */
    AJMediaSaveType_Video      /** 视频 */
}AJMediaSaveType;

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface AJMediaSaveTool : NSObject

#pragma mark -

+ (instancetype)sharedTool;


#pragma mark -


/**
 保存图片

 @param image 图片
 @param success 保存成功的回调(返回保存后的asset)
 @param failure 保存失败的回调
 */
-(void)saveImage:(UIImage *)image success:(void (^)(PHAsset * asset))success failure:(void (^)())failure;



#pragma mark -


/**
 保存沙盒中的媒体资源（图片、视频）- 异步方式
 
 @param fileURL 保存在沙盒中的媒体资源地址
 @param success 保存成功的回调(返回保存后的asset)
 @param failure 保存失败的回调
 */
-(void)saveMediaWithMediaType:(AJMediaSaveType)mediaType fileURL:(NSURL *)fileURL success:(void (^)(PHAsset * asset))success failure:(void (^)())failure;

@end
