//
//  AJMPAuthorizationTool.h
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/2.
//  Copyright © 2017年 AJ. All rights reserved.
//

/*
 授权工具类
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AJMPAuthorizationTool : NSObject

/**
 相册权限的判断（点击相册按钮后 即将推出相册列表VC之前的操作）
 
 @param authorized “已授权”回调
 @param deniedAuth “已拒绝”回调
 */
+(void)photoAlbumAuthorityJudgementAuthorized:(void (^)())authorized deniedAuth:(void (^)())deniedAuth;


/**
 相机权限的判断（点击相机按钮后 即将推出相机VC之前的操作）
 
 @param authorized “已授权”回调
 @param deniedAuth “已拒绝”回调
 */
+(void)cameraAuthorityJudgementAuthorized:(void (^)())authorized deniedAuth:(void (^)())deniedAuth;


@end
