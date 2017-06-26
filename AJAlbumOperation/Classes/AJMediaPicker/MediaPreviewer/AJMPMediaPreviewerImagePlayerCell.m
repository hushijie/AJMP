//
//  AJMPMediaPreviewerImagePlayerCell.m
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/21.
//  Copyright © 2017年 AJ. All rights reserved.
//

#define MaxScale 2.0  //最大缩放比例
#define MinScale 0.5  //最小缩放比例

#define ChooseBtnWidthHeight (80*Ratio_Width)

#import "AJMPMediaPreviewerImagePlayerCell.h"
#import "AJMPDefinitionHeader.h"

@interface AJMPMediaPreviewerImagePlayerCell ()

@property (nonatomic ,weak)UIImageView * picImageView;
@property (nonatomic ,weak)UIButton * chooseBtn;

//缩放比例
@property (nonatomic,assign) CGFloat totalScale;

@property (nonatomic ,retain)AJMPMediaInfoModel * mediaInfoModel;
@property (nonatomic ,copy)void(^chooseBtnClickBlock)(AJMPMediaInfoModel * mediaInfoModel);
@property (nonatomic ,assign)int maxNumberOfMedia;
@property (nonatomic ,strong)NSMutableArray * selectedMediaInfoModelArray;

@end

@implementation AJMPMediaPreviewerImagePlayerCell

#pragma mark - 创建视图

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        /*
         创建子控件
         */
        
        //图片
        UIImageView * picImageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        picImageView.contentMode=UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:picImageView];
        _picImageView=picImageView;
        
        //捏合手势的添加
//        self.totalScale = 1.0;
//        UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
//        self.picImageView.userInteractionEnabled=YES;
//        [self.picImageView addGestureRecognizer:pinch];

        //勾选按钮
        UIButton * btn=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"AJMP_btn_unchecked"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"AJMP_btn_checked"] forState:UIControlStateSelected];
        btn.frame=CGRectMake(self.bounds.size.width-ChooseBtnWidthHeight, 0, ChooseBtnWidthHeight, ChooseBtnWidthHeight);
        [btn addTarget:self action:@selector(chooseBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:btn];
        _chooseBtn=btn;
        
        
    }
    return self;
}


#pragma mark - 点击事件

-(void)chooseBtnClick
{
    //用户想要勾选&现勾选数已经达到最大
    if (!self.chooseBtn.selected && ((int)self.selectedMediaInfoModelArray.count==self.maxNumberOfMedia)) {
        NSLog(@"最多只能勾选%d个",self.maxNumberOfMedia);
    }
    //还能够勾选
    else{
        
        if (!self.chooseBtn.selected) {
            //由非勾选到勾选，需要显示动画
            CABasicAnimation * pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            pulse.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            pulse.duration = 0.15;
            pulse.repeatCount= 1;
            pulse.autoreverses= YES;//是否需要反弹效果
            pulse.fromValue= [NSNumber numberWithFloat:1.0];
            pulse.toValue= [NSNumber numberWithFloat:1.2];
            [[self.chooseBtn layer] addAnimation:pulse forKey:nil];
        }
        
        self.chooseBtn.selected=!self.chooseBtn.selected;
        
        self.mediaInfoModel.isChooseStatus=self.chooseBtn.selected;
        
        //更新“已勾选数组”
        BOOL isHadStatus=NO;//记录是否在“已选择数组”中
        for (AJMPMediaInfoModel * model in self.selectedMediaInfoModelArray) {
            if (self.mediaInfoModel==model) {
                isHadStatus=YES;
                //取消勾选
                if (!self.mediaInfoModel.isChooseStatus) {
                    [self.selectedMediaInfoModelArray removeObject:self.mediaInfoModel];
                    break;
                }
            }
        }
        //不在“已选择数组”
        if (!isHadStatus) {
            if (self.mediaInfoModel.isChooseStatus) {
                [self.selectedMediaInfoModelArray addObject:self.mediaInfoModel];
            }
        }
        
        //勾选block回调
        if (self.chooseBtnClickBlock) {
            self.chooseBtnClickBlock(self.mediaInfoModel);
        }
    }
}


#pragma mark - 捏合手势

- (void)pinch:(UIPinchGestureRecognizer *)recognizer
{
    
    CGFloat scale = recognizer.scale;
    
    //放大情况
    if(scale > 1.0){
        if(self.totalScale > MaxScale) return;
    }
    //缩小情况
    if (scale < 1.0) {
        if (self.totalScale < MinScale) return;
    }
    
    self.picImageView.transform = CGAffineTransformScale(self.picImageView.transform, scale, scale);
   
    self.totalScale *=scale;
    
    recognizer.scale = 1.0;
    
}


#pragma mark - 清除缩放效果

-(void)clearZoom
{
    //避免复用导致的缩放效果
    self.picImageView.transform = CGAffineTransformIdentity;
    self.totalScale=1.0f;
}


#pragma mark - setter

-(void)setMediaInfoModel:(AJMPMediaInfoModel *)mediaInfoModel maxNumberOfMedia:(int)maxNumberOfMedia selectedMediaInfoModelArray:(NSMutableArray *)selectedMediaInfoModelArray chooseBtnClickBlock:(void(^)(AJMPMediaInfoModel * mediaInfoModel))chooseBtnClickBlock;
{
    _mediaInfoModel=mediaInfoModel;
    _maxNumberOfMedia=maxNumberOfMedia;
    _selectedMediaInfoModelArray=selectedMediaInfoModelArray;
    _chooseBtnClickBlock=chooseBtnClickBlock;
    
    self.chooseBtn.selected=_mediaInfoModel.isChooseStatus;
    
//    [self clearZoom];
    
    [[PHImageManager defaultManager] requestImageForAsset:_mediaInfoModel.asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage *result, NSDictionary *info) {
        
        //必须加入主线程，才能及时更新UI！！
        dispatch_async(dispatch_get_main_queue(),^{
            
            self.picImageView.image=result;
            
            //添加缩放动画
            CABasicAnimation * pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            pulse.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            pulse.duration = 0.2;
            pulse.repeatCount= 1;
            pulse.autoreverses= NO;//是否需要反弹效果
            pulse.fromValue= [NSNumber numberWithFloat:0.5];
            pulse.toValue= [NSNumber numberWithFloat:1.0];
            [[self.picImageView layer] addAnimation:pulse forKey:nil];
            
        });
        
    }];
    
}


@end
