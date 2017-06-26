//
//  AJMPDeniedAuthViewController.m
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/2.
//  Copyright © 2017年 AJ. All rights reserved.
//

#define TitleLabellHeight 44.0f
#define SummaryLabelHeight 60.0f

#import "AJMPDeniedAuthViewController.h"
#import "AJMPDefinitionHeader.h"

@interface AJMPDeniedAuthViewController ()

@property (nonatomic ,weak)UILabel * titleLabel;
@property (nonatomic ,weak)UILabel * summaryLabel;

@end

@implementation AJMPDeniedAuthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor=AJMPContentViewBackgroundColor;
    
    //获取app的名字
    NSString * displayName=[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    
    if (self.deniedAuthType==DeniedAuthType_PhotoAlbum) {
        
        self.navigationItem.title=@"相册";
        self.titleLabel.text=[NSString stringWithFormat:@"%@没有权限访问您的照片",displayName];
        self.summaryLabel.text=[NSString stringWithFormat:@"请进入系统 设置 > 隐私 > 照片\n以允许“%@”访问您的照片",displayName];
        
    }
    else if (self.deniedAuthType==DeniedAuthType_Camera){
        
        self.navigationItem.title=@"相机";
        self.titleLabel.text=[NSString stringWithFormat:@"%@没有权限访问您的相机",displayName];
        ;
        self.summaryLabel.text=[NSString stringWithFormat:@"请进入系统 设置 > 隐私 > 相机\n以允许“%@”访问您的相机",displayName];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - 懒加载

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        
        UILabel * label=[[UILabel alloc]init];
        label.frame=CGRectMake(0, 64+20, SCREEN_WIDTH, TitleLabellHeight);
        label.font=[UIFont fontWithName:@"Helvetica-Bold" size:16];
        label.textColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.80];
        label.textAlignment=NSTextAlignmentCenter;
        
        [self.view addSubview:label];
        _titleLabel=label;
    }
    return _titleLabel;
}

-(UILabel *)summaryLabel
{
    if (!_summaryLabel) {
        
        UILabel * label=[[UILabel alloc]init];
        label.frame=CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), SCREEN_WIDTH, SummaryLabelHeight);
        label.font=[UIFont systemFontOfSize:16];
        label.textColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.48];
        label.textAlignment=NSTextAlignmentCenter;
        label.numberOfLines=0;
        
        [self.view addSubview:label];
        _summaryLabel=label;
    }
    return _summaryLabel;
}

@end
