//
//  AJMPMediaCell.m
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/5/28.
//  Copyright © 2017年 AJ. All rights reserved.
//

#define DurationLabelHeight (20.0*Ratio_Width)
#define ChooseBtnWidthHeight (35*Ratio_Width)

#import "AJMPMediaCell.h"
#import "AJMPAlbumInfoModel.h"
#import "AJMPDefinitionHeader.h"

@interface AJMPMediaCell ()

@property (nonatomic ,weak)UIButton * cameraBtn;

@property (nonatomic ,weak)UIImageView * picImageView;

//展示video时长
@property (nonatomic ,weak)UIView * durationBgView;
@property (nonatomic ,weak)UILabel * durationLabel;
@property (nonatomic ,weak)CAGradientLayer * durationBgViewLayer;

@property (nonatomic ,weak)UIImageView * shadeImageView;

@property (nonatomic ,weak)UIButton * chooseBtn;

/**
 资源重用标识
 资源重用标识的作用是在请求图片到图片后匹配Cell
 */
@property (nonatomic, copy) NSString *representedAssetIdentifier;

@end

static CGSize AssetGridThumbnailSize;

@implementation AJMPMediaCell

#pragma mark - 创建视图

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        /*
         创建子控件
         */
        
        
        //相机按钮
        UIButton * cameraBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        cameraBtn.frame=CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        [cameraBtn setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.4]];
        [cameraBtn setImage:[UIImage imageNamed:@"AJMP_icon_camera_default"] forState:UIControlStateNormal];
        [cameraBtn addTarget:self action:@selector(cameraBtnClick) forControlEvents:UIControlEventTouchUpInside];
        cameraBtn.hidden=YES;
        [self.contentView addSubview:cameraBtn];
        _cameraBtn=cameraBtn;
        
        
        //图片
        UIImageView * picImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        picImageView.contentMode=UIViewContentModeScaleAspectFill;
        picImageView.clipsToBounds=YES;
        [self.contentView addSubview:picImageView];
        _picImageView=picImageView;
        
        
        //展示video时长
        
        //durationBgView
        UIView * durationBgView=[[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height-DurationLabelHeight, self.bounds.size.width, DurationLabelHeight)];
        durationBgView.hidden=YES;//默认隐藏
        [self.contentView addSubview:durationBgView];
        _durationBgView=durationBgView;
        //渐变层
        CAGradientLayer * layer = [CAGradientLayer layer];
        layer.colors = [NSArray arrayWithObjects:(id)AJRGBAColor(0, 0, 0, 0).CGColor,(id)AJRGBAColor(0, 0, 0, 0.08).CGColor,(id)AJRGBAColor(0, 0, 0, 0.16).CGColor,(id)AJRGBAColor(0, 0, 0, 0.24).CGColor, (id)AJRGBAColor(0, 0, 0, 0.32).CGColor, (id)AJRGBAColor(0, 0, 0, 0.40).CGColor, nil];
        layer.frame = _durationBgView.bounds;
        //给label的父视图的layer添加渐变layer
        [_durationBgView.layer insertSublayer:layer atIndex:0];
        _durationBgViewLayer=layer;
        //durationLabel
        UILabel * durationLabel=[[UILabel alloc]initWithFrame:CGRectMake(4*Ratio_Width, 0, _durationBgView.bounds.size.width-(4*Ratio_Width)*2, _durationBgView.bounds.size.height)];
        durationLabel.textColor=[UIColor whiteColor];
        durationLabel.font=[UIFont systemFontOfSize:12];
        durationLabel.textAlignment=NSTextAlignmentRight;
        [_durationBgView addSubview:durationLabel];
        _durationLabel=durationLabel;
        
        
        //黑色遮罩
        UIImageView * shadeImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        shadeImageView.image=[UIImage imageNamed:@"AJMP_list_chb_opacity0.4"];
        shadeImageView.hidden=YES;//默认是隐藏的
        [self.contentView addSubview:shadeImageView];
        _shadeImageView=shadeImageView;
        
        
        //勾选按钮
        UIButton * btn=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"AJMP_btn_unchecked"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"AJMP_btn_checked"] forState:UIControlStateSelected];
        btn.frame=CGRectMake(self.bounds.size.width-ChooseBtnWidthHeight, 0, ChooseBtnWidthHeight, ChooseBtnWidthHeight);
        [btn addTarget:self action:@selector(chooseBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btn];
        _chooseBtn=btn;
        
        
        /*
         初始化 cell的size:
         根据流布局获取Cell的尺寸，初始化常量AssetGridThumbnailSize
         */
        CGFloat itemWidthHeight = ((self.bounds.size.width - AJMPMediaCellCountOneLine + 1) / AJMPMediaCellCountOneLine)*1.5;
        CGFloat scale = [UIScreen mainScreen].scale;
        AssetGridThumbnailSize = CGSizeMake(itemWidthHeight * scale, itemWidthHeight * scale);
        
    }
    return self;
}

#pragma mark - 按钮点击事件


/**
 选择按钮
 */
-(void)chooseBtnClick
{

    if (self.choosePicBlock) {
        self.choosePicBlock(!_isCheckChooseBtnStatus);
    }
    
}



/**
 第一个cell 相机点击事件
 */
-(void)cameraBtnClick
{
    
    if (self.cameraBtnClickBlock) {
        self.cameraBtnClickBlock();
    }
    
}


/**
 单选图片选择器 图片的点击手势
 */
-(void)singleImgPickerTapGesture
{
    if (self.singleImageSelectWithCropperTapGestureBlock) {
        
        // 请求图片
        [[PHImageManager defaultManager] requestImageForAsset:self.mediaInfoModel.asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
            //判断当前cell的资源是否是当前获取的资源
            if ([self.representedAssetIdentifier isEqualToString:self.mediaInfoModel.asset.localIdentifier]) {
                
                self.singleImageSelectWithCropperTapGestureBlock(result);
            }
        }];
        
    }
}



#pragma mark - setter

-(void)setMediaPickerType:(AJMediaPickerType)mediaPickerType
{
    _mediaPickerType=mediaPickerType;
    
    if (_mediaPickerType==AJMediaPickerType_SingleImageSelectWithCropper) {
        
        self.chooseBtn.hidden=YES;
        self.maskView.hidden=YES;
        
        /*
         设置图片的点击手势
         */
        UITapGestureRecognizer * singleImgPickerTapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleImgPickerTapGesture)];
        self.picImageView.userInteractionEnabled=YES;
        [self.picImageView addGestureRecognizer:singleImgPickerTapGesture];
        
    }
}


-(void)setIsCameraCellStatus:(BOOL)isCameraCellStatus
{
    _isCameraCellStatus=isCameraCellStatus;
    
    //是相机cell
    if (_isCameraCellStatus) {
        self.cameraBtn.hidden=NO;
        self.picImageView.hidden=YES;
        self.chooseBtn.hidden=YES;
        self.durationBgView.hidden=YES;
        self.shadeImageView.hidden=YES;
    }
    //展示照片的cell
    else{
        self.cameraBtn.hidden=YES;
        self.picImageView.hidden=NO;
        self.chooseBtn.hidden=NO;
        self.durationBgView.hidden=YES;
        self.shadeImageView.hidden=YES;
    }
}


-(void)setIsCheckChooseBtnStatus:(BOOL)isCheckChooseBtnStatus
{
    _isCheckChooseBtnStatus=isCheckChooseBtnStatus;
    
    //选择了:遮罩显示、选择按钮选中
    if (_isCheckChooseBtnStatus) {
        
        self.chooseBtn.selected=_isCheckChooseBtnStatus;
        self.shadeImageView.hidden=NO;
        
        /*
         添加动画
         */
        CABasicAnimation * pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        pulse.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        pulse.duration = 0.15;
        pulse.repeatCount= 1;
        pulse.autoreverses= YES;//是否需要反弹效果
        pulse.fromValue= [NSNumber numberWithFloat:1.0];
        pulse.toValue= [NSNumber numberWithFloat:1.2];
        [[self.chooseBtn layer] addAnimation:pulse forKey:nil];
        
    }
    //没有选择：遮罩隐藏、选择按钮不选中
    else{
        
        self.chooseBtn.selected=_isCheckChooseBtnStatus;
        self.shadeImageView.hidden=YES;
        
    }
    
    /*
     遍历整个相册 找出所有相同的照片 并设置选中状态
     */
    [self ergodicAlbumFundSamePicWithIsChoose:_isCheckChooseBtnStatus];
    
}


-(void)setMediaInfoModel:(AJMPMediaInfoModel *)mediaInfoModel
{
    _mediaInfoModel=mediaInfoModel;
    
    PHAsset * asset=_mediaInfoModel.asset;
    
    self.representedAssetIdentifier=asset.localIdentifier;
    self.isCheckChooseBtnStatus=_mediaInfoModel.isChooseStatus;
    
    //视频
    if (asset.mediaType==PHAssetMediaTypeVideo) {
        self.durationBgView.hidden=NO;
        self.durationLabel.text=[self getHMinSWithDuration:asset.duration];
    }
    //非视频
    else{
        self.durationBgView.hidden=YES;
        self.durationLabel.text=nil;
    }
    
    // 请求图片
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:AssetGridThumbnailSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
        
        //判断当前cell的资源是否是当前获取的资源
        if ([self.representedAssetIdentifier isEqualToString:asset.localIdentifier]) {
            self.picImageView.image = result;
        }
        
    }];
}



#pragma mark - 遍历相册所有图片,找出相同的照片


/**
 @param isChoose 是否选中：YES-选中、NO-没有选中
 */
-(void)ergodicAlbumFundSamePicWithIsChoose:(BOOL)isChoose
{
    for (AJMPAlbumInfoModel * albumInfoModel in self.albumInfoModelArray) {
        
        for (AJMPMediaInfoModel * mediaInfoModel in albumInfoModel.mediaInfoModelArray) {
            
            //找到相同的照片
            if ([mediaInfoModel.asset.localIdentifier isEqualToString:self.mediaInfoModel.asset.localIdentifier]) {
                mediaInfoModel.isChooseStatus=isChoose;
            }
        }
    }
}


#pragma mark - 返回video时长的时分秒(00:00:00)

-(NSString *)getHMinSWithDuration:(NSTimeInterval)duration
{
    int totalSecond=(int)duration;
    int min=totalSecond/60;
    int second=totalSecond%60;
    
    //显示小时
    if (min>=60) {
        return [NSString stringWithFormat:@"%02d:%02d:%02d",min/60,min%60,second];
    }
    //不显示小时
    else{
        return [NSString stringWithFormat:@"%02d:%02d",min,second];
    }
}


@end
