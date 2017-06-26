//
//  AJMPMediaPreviewerViewController.m
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/20.
//  Copyright © 2017年 AJ. All rights reserved.
//

#import "AJMPMediaPreviewerViewController.h"
#import "AJMPBottomView.h"
#import "AJMPDefinitionHeader.h"
#import "AJMPMediaPreviewerVideoPlayerView.h"
#import "AJMPMediaPreviewerImagePlayerView.h"

@interface AJMPMediaPreviewerViewController ()

@property (nonatomic ,weak)UILabel * navTitleLabel;

@property (nonatomic ,weak)AJMPBottomView * bottomView;

//预览器类型
@property (nonatomic ,assign)AJMPMediaPreviewerType mediaPreviewerType;

@property (nonatomic ,copy)void(^confirmSelectedMediaInfoArrayBlock)(NSMutableArray * mediaInfoModelArray);

//video相关
@property (nonatomic ,weak)AJMPMediaPreviewerVideoPlayerView * videoPlayerView;
@property (nonatomic ,retain)AJMPMediaInfoModel * mediaInfoModel;
@property (nonatomic ,copy)void(^chooseBtnClickBlock)(AJMPMediaInfoModel * mediaInfoModel);
@property (nonatomic ,assign)int maxNumberOfMedia;
@property (nonatomic ,strong)NSMutableArray * selectedMediaInfoModelArray;

//image相关
@property (nonatomic ,weak)AJMPMediaPreviewerImagePlayerView * imagePlayerView;
@property (nonatomic ,assign)int currentIndex;//当前选中的图片的index
@property (nonatomic ,retain)NSArray * allMediaInfoModelArray;

@end

@implementation AJMPMediaPreviewerViewController

#pragma mark - vc生命周期

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        /*
         返回按钮
         */
        UIBarButtonItem * leftItem=[[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(leftBtnClick)];
        NSMutableDictionary * leftItemAttrs = [NSMutableDictionary dictionary];
        leftItemAttrs[NSForegroundColorAttributeName] = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.80];
        leftItemAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:15];
        [leftItem setTitleTextAttributes:leftItemAttrs forState:UIControlStateNormal];
        
        self.navigationItem.leftBarButtonItem = leftItem;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor=AJMPContentViewBackgroundColor;
    
    [self.bottomView class];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - 懒加载

-(UILabel *)navTitleLabel
{
    if (!_navTitleLabel) {
        
        UILabel * label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 130, 30)];
        label.textColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.80];
        label.font=[UIFont systemFontOfSize:17];//[UIFont fontWithName:@"Helvetica-Bold" size:17]
        label.textAlignment=NSTextAlignmentCenter;
        
        self.navigationItem.titleView=label;
        _navTitleLabel=label;
        
    }
    return _navTitleLabel;
}

-(AJMPBottomView *)bottomView
{
    if (!_bottomView) {
        
        AJMPBottomView * bottomView=[AJMPBottomView bottomView];
        
        [bottomView.cancelBtn setTitle:@"返回" forState:UIControlStateNormal];
        
        __weak __typeof__(self)weakSelf=self;
        
        //“返回”按钮回调
        [bottomView setCancelBtnClickBlock:^{
            
            [weakSelf leftBtnClick];
            
        }];
        
        //"完成"按钮回调
        [bottomView setConfirmBtnClickBlock:^{
            
            if (weakSelf.confirmSelectedMediaInfoArrayBlock) {
                weakSelf.confirmSelectedMediaInfoArrayBlock(weakSelf.selectedMediaInfoModelArray);
                [weakSelf leftBtnClick];
            }
            
        }];
        
        [self.view addSubview:bottomView];
        _bottomView=bottomView;
    }
    return _bottomView;
}

-(AJMPMediaPreviewerVideoPlayerView *)videoPlayerView
{
    if (!_videoPlayerView) {
        
        AJMPMediaPreviewerVideoPlayerView * videoPlayerView=[[AJMPMediaPreviewerVideoPlayerView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREENH_HEIGHT-64-self.bottomView.bounds.size.height)];

        [self.view addSubview:videoPlayerView];
        _videoPlayerView=videoPlayerView;
    }
    return _videoPlayerView;
}


-(AJMPMediaPreviewerImagePlayerView *)imagePlayerView
{
    if (!_imagePlayerView) {
        
        AJMPMediaPreviewerImagePlayerView * imagePlayerView=[[AJMPMediaPreviewerImagePlayerView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREENH_HEIGHT-64-self.bottomView.bounds.size.height)];
        
        [self.view addSubview:imagePlayerView];
        _imagePlayerView=imagePlayerView;
    }
    return _imagePlayerView;
}



#pragma mark - 点击事件

-(void)leftBtnClick
{
    if (self.mediaPreviewerType==AJMPMediaPreviewerType_Video) {
        [self.videoPlayerView disappearAction];
    }
    
    [self.navigationController popViewControllerAnimated:NO];
}


#pragma mark - setter

-(void)setVideoPreviewerMediaInfoModel:(AJMPMediaInfoModel *)mediaInfoModel maxNumberOfMedia:(int)maxNumberOfMedia selectedMediaInfoModelArray:(NSMutableArray *)selectedMediaInfoModelArray chooseBtnClickBlock:(void (^)(AJMPMediaInfoModel *))chooseBtnClickBlock confirmSelectedMediaInfoArrayBlock:(void(^)(NSMutableArray * mediaInfoModelArray))confirmSelectedMediaInfoArrayBlock
{
    _mediaPreviewerType=AJMPMediaPreviewerType_Video;
    _mediaInfoModel=mediaInfoModel;
    _maxNumberOfMedia=maxNumberOfMedia;
    _selectedMediaInfoModelArray=selectedMediaInfoModelArray;
    _chooseBtnClickBlock=chooseBtnClickBlock;
    _confirmSelectedMediaInfoArrayBlock=confirmSelectedMediaInfoArrayBlock;
    
    [self.bottomView setConfirmBtnCurrentCount:self.selectedMediaInfoModelArray.count maxCount:self.maxNumberOfMedia];
    
    __weak __typeof__(self)weakSelf=self;
    
    //设置video播放器数据
    [self.videoPlayerView setVideoPreviewerMediaInfoModel:_mediaInfoModel maxNumberOfMedia:_maxNumberOfMedia selectedMediaInfoModelArray:_selectedMediaInfoModelArray chooseBtnClickBlock:^(AJMPMediaInfoModel *mediaInfoModel) {
        
        [weakSelf.bottomView setConfirmBtnCurrentCount:weakSelf.selectedMediaInfoModelArray.count maxCount:weakSelf.maxNumberOfMedia];
        
        if (weakSelf.chooseBtnClickBlock) {
            weakSelf.chooseBtnClickBlock(mediaInfoModel);
        }
        
    }];
}


-(void)setImagePreviewerWithCurrentIndex:(int)currentIndex maxNumberOfMedia:(int)maxNumberOfMedia selectedMediaInfoModelArray:(NSMutableArray *)selectedMediaInfoModelArray allMediaInfoModelArray:(NSArray *)allMediaInfoModelArray chooseBtnClickBlock:(void(^)(AJMPMediaInfoModel * mediaInfoModel))chooseBtnClickBlock confirmSelectedMediaInfoArrayBlock:(void(^)(NSMutableArray * mediaInfoModelArray))confirmSelectedMediaInfoArrayBlock
{
    _mediaPreviewerType=AJMPMediaPreviewerType_Image;
    _currentIndex=currentIndex;
    _maxNumberOfMedia=maxNumberOfMedia;
    _selectedMediaInfoModelArray=selectedMediaInfoModelArray;
    _allMediaInfoModelArray=allMediaInfoModelArray;
    _chooseBtnClickBlock=chooseBtnClickBlock;
    _confirmSelectedMediaInfoArrayBlock=confirmSelectedMediaInfoArrayBlock;
    
    [self.bottomView setConfirmBtnCurrentCount:self.selectedMediaInfoModelArray.count maxCount:self.maxNumberOfMedia];
    
    __weak __typeof__(self)weakSelf=self;
    
    [self.imagePlayerView setImagePreviewerWithCurrentIndex:_currentIndex maxNumberOfMedia:_maxNumberOfMedia selectedMediaInfoModelArray:_selectedMediaInfoModelArray allMediaInfoModelArray:_allMediaInfoModelArray chooseBtnClickBlock:^(AJMPMediaInfoModel * mediaInfoModel) {
    
        [weakSelf.bottomView setConfirmBtnCurrentCount:weakSelf.selectedMediaInfoModelArray.count maxCount:weakSelf.maxNumberOfMedia];
        
        if (weakSelf.chooseBtnClickBlock) {
            weakSelf.chooseBtnClickBlock(mediaInfoModel);
        }
        
    } itemScrollBlock:^(int indexRow) {
        
        weakSelf.navTitleLabel.text=[NSString stringWithFormat:@"%d/%d",indexRow,(int)_allMediaInfoModelArray.count];
        
    }];
    
}

@end
