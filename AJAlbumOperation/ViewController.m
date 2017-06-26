//
//  ViewController.m
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/5/28.
//  Copyright © 2017年 AJ. All rights reserved.
//

#import "ViewController.h"
#import "AJMediaPickerHeader.h"

@interface ViewController ()

@end

@implementation ViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.title=@"AJAlbumOperation";
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    UIButton * multipleImageSelectbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    multipleImageSelectbtn.frame=CGRectMake(10, 80, 100, 40);
    [multipleImageSelectbtn setTitle:@"多图选择" forState:UIControlStateNormal];
    [multipleImageSelectbtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [multipleImageSelectbtn addTarget:self action:@selector(multipleImageSelectbtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:multipleImageSelectbtn];
    
    UIButton * videoSelectbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    videoSelectbtn.frame=CGRectMake(10, CGRectGetMaxY(multipleImageSelectbtn.frame)+10, 100, 40);
    [videoSelectbtn setTitle:@"视频选择" forState:UIControlStateNormal];
    [videoSelectbtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [videoSelectbtn addTarget:self action:@selector(videoSelectbtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:videoSelectbtn];
    
    
    UIButton * singleImageWithCropSelectbtn=[UIButton buttonWithType:UIButtonTypeCustom];
    singleImageWithCropSelectbtn.frame=CGRectMake(10, CGRectGetMaxY(videoSelectbtn.frame)+10, 100, 40);
    [singleImageWithCropSelectbtn setTitle:@"单图裁剪" forState:UIControlStateNormal];
    [singleImageWithCropSelectbtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [singleImageWithCropSelectbtn addTarget:self action:@selector(singleImageWithCropSelectbtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:singleImageWithCropSelectbtn];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 按钮点击事件

-(void)multipleImageSelectbtnClick
{
    AJMPMultipleImageSelectViewController * vc=[[AJMPMultipleImageSelectViewController alloc]init];
    
    //选择视频
//    [vc setMediaPickerType:AJMediaPickerType_VideoSelect maxNumberOfMedia:1 currentSelectedMediaInfoModelArray:nil confirmSelectedMediaInfoArrayBlock:^(NSMutableArray *mediaInfoModelArray) {
//        
//    }];
    
    //选择图片
    [vc setMediaPickerType:AJMediaPickerType_MultipleImageSelect maxNumberOfMedia:9 currentSelectedMediaInfoModelArray:nil confirmSelectedMediaInfoArrayBlock:^(NSMutableArray *mediaInfoModelArray) {
        
    }];
    
    //单图并裁剪
//    [vc setSingleImageSelectWithCropperWidthRatio:1 heightRatio:1 backCroppedImageBlock:^(UIImage *croppedImage) {
//        
//    }];
    
    UINavigationController * navc=[[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:navc animated:YES completion:^{
        
    }];
}


-(void)videoSelectbtnClick
{
    AJMPMultipleImageSelectViewController * vc=[[AJMPMultipleImageSelectViewController alloc]init];
    
    //选择视频
    [vc setMediaPickerType:AJMediaPickerType_VideoSelect maxNumberOfMedia:1 currentSelectedMediaInfoModelArray:nil confirmSelectedMediaInfoArrayBlock:^(NSMutableArray *mediaInfoModelArray) {

    }];
    
    UINavigationController * navc=[[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:navc animated:YES completion:^{
        
    }];
}

-(void)singleImageWithCropSelectbtnClick
{
    AJMPMultipleImageSelectViewController * vc=[[AJMPMultipleImageSelectViewController alloc]init];
    
    //单图并裁剪
    [vc setSingleImageSelectWithCropperWidthRatio:1 heightRatio:1 backCroppedImageBlock:^(UIImage *croppedImage) {
        
    }];
    
    UINavigationController * navc=[[UINavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:navc animated:YES completion:^{
        
    }];
}



@end
