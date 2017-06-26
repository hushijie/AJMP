//
//  AJMPDeniedAuthViewController.h
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/2.
//  Copyright © 2017年 AJ. All rights reserved.
//

/*
 已拒绝授权展示的VC
 */

typedef enum {
    
    DeniedAuthType_PhotoAlbum,  //相册
    DeniedAuthType_Camera       //相机
    
}DeniedAuthType;    //拒绝授权的类型

#import <UIKit/UIKit.h>

@interface AJMPDeniedAuthViewController : UIViewController

//拒绝授权的类型
@property (nonatomic ,assign)DeniedAuthType deniedAuthType;

@end
