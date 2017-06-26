//
//  AJMPAuthorizationTool.m
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/2.
//  Copyright © 2017年 AJ. All rights reserved.
//

#import "AJMPAuthorizationTool.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@implementation AJMPAuthorizationTool

#pragma mark - 相册

//相册权限是否“已拒绝”
+ (BOOL)isPhotoAlbumDenied
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied)
    {
        return YES;
    }
    return NO;
}


//相册权限是否“未确定”
+ (BOOL)isPhotoAlbumNotDetermined
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusNotDetermined)
    {
        return YES;
    }
    return NO;
}


+(void)photoAlbumAuthorityJudgementAuthorized:(void (^)())authorized deniedAuth:(void (^)())deniedAuth
{
    /*
     当前设备支持打开相册
     */
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        
        // 第一次安装App，还未确定权限，调用这里
        if ([self isPhotoAlbumNotDetermined])
        {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
            {
                // 该API从iOS8.0开始支持
                // 系统弹出授权对话框
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied)
                        {
                            // 用户拒绝，跳转到自定义提示页面
                            if (deniedAuth) {
                                deniedAuth();
                            }
                            
                        }
                        else if (status == PHAuthorizationStatusAuthorized)
                        {
                            // 用户授权，弹出相册对话框
                            if (authorized) {
                                authorized();
                            }
                        }
                    });
                }];
            }
            else
            {
                // 以上requestAuthorization接口只支持8.0以上，如果App支持7.0及以下，就只能调用这里。(直接跳至授权成功之后的VC)
                if (authorized) {
                    authorized();
                }
                
            }
        }
        else if ([self isPhotoAlbumDenied])
        {
            // 如果已经拒绝，则弹出对话框
            if (deniedAuth) {
                deniedAuth();
            }
            
        }
        else
        {
            // 已经授权，跳转到相册页面
            if (authorized) {
                authorized();
            }
            
        }
    }
    
    /*
     当前设备不支持打开相册
     */
    else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前设备不支持相册" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}


#pragma mark - 相机

//相机权限是否“已拒绝”
+ (BOOL)isCameraDenied
{
    ALAuthorizationStatus author = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied)
    {
        return YES;
    }
    return NO;
}


//相机权限是否“未确定”
+ (BOOL)isCameraNotDetermined
{
    ALAuthorizationStatus author = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (author == ALAuthorizationStatusNotDetermined)
    {
        return YES;
    }
    return NO;
}




+(void)cameraAuthorityJudgementAuthorized:(void (^)())authorized deniedAuth:(void (^)())deniedAuth
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // 应用第一次申请权限调用这里
        if ([self isCameraNotDetermined])
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (granted)
                    {
                        // 用户授权
                        if (authorized) {
                            authorized();
                        }
                        
                    }
                    else
                    {
                        // 用户拒绝授权
                        if (deniedAuth) {
                            deniedAuth();
                        }
                        
                    }
                });
            }];
        }
        // 用户已经拒绝访问摄像头
        else if ([self isCameraDenied])
        {
            
            if (deniedAuth) {
                deniedAuth();
            }
            
        }
        
        // 用户允许访问摄像头
        else
        {
            
            if (authorized) {
                authorized();
            }
            
        }
    }
    else
    {
        // 当前设备不支持摄像头，比如模拟器
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前设备不支持拍照" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}




@end
