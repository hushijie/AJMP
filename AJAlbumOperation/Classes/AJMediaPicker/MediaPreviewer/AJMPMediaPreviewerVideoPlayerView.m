//
//  AJMPMediaPreviewerVideoPlayerView.m
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/20.
//  Copyright © 2017年 AJ. All rights reserved.
//

#define ChooseBtnWidthHeight (80*Ratio_Width)

#import "AJMPMediaPreviewerVideoPlayerView.h"
#import "AJMPDefinitionHeader.h"
#import <AVFoundation/AVFoundation.h>

@interface AJMPMediaPreviewerVideoPlayerView ()

@property (nonatomic ,weak)UIButton * playBtn;//播放按钮

@property (nonatomic ,weak)UIButton * chooseBtn;

@property (nonatomic ,strong)AVPlayerLayer * playerLayer;

@property (nonatomic ,strong)AVPlayer * player;

@property (nonatomic ,strong)AVPlayerItem * playerItem;


@property (nonatomic ,retain)AJMPMediaInfoModel * mediaInfoModel;
@property (nonatomic ,copy)void(^chooseBtnClickBlock)(AJMPMediaInfoModel * mediaInfoModel);
@property (nonatomic ,assign)int maxNumberOfMedia;
@property (nonatomic ,strong)NSMutableArray * selectedMediaInfoModelArray;

@end

@implementation AJMPMediaPreviewerVideoPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor=AJMPContentViewBackgroundColor;
        
        /*
         创建子视图
         */
        
        //播放按钮
        UIButton * playBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [playBtn setImage:nil forState:UIControlStateNormal];
        [playBtn setImage:[UIImage imageNamed:@"AJMP_icon_video_pause"] forState:UIControlStateSelected];
        playBtn.frame=self.bounds;
        [playBtn addTarget:self action:@selector(playBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:playBtn];
        _playBtn=playBtn;
        
        
        //勾选按钮
        UIButton * chooseBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [chooseBtn setImage:[UIImage imageNamed:@"AJMP_btn_unchecked"] forState:UIControlStateNormal];
        [chooseBtn setImage:[UIImage imageNamed:@"AJMP_btn_checked"] forState:UIControlStateSelected];
        chooseBtn.frame=CGRectMake(self.bounds.size.width-ChooseBtnWidthHeight, 0, ChooseBtnWidthHeight, ChooseBtnWidthHeight);
        [chooseBtn addTarget:self action:@selector(chooseBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:chooseBtn];
        _chooseBtn=chooseBtn;
        
    }
    return self;
}


-(void)dealloc
{
//    [self disappearAction];
}


#pragma mark - 视图消失时候做的操作

-(void)disappearAction
{
    //如果player正在播放，暂停
    //rate == 1.0，表示正在播放；rate == 0.0，暂停；rate == -1.0，播放失败
    if (self.player.rate==1) {
        [self.player pause];
    }
    
    //移除监听
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}


#pragma mark - 点击事件

-(void)playBtnClick
{
    if (self.player) {
        
        //暂停状态
        if (self.playBtn.isSelected) {
            [self.player play];
        }
        //正在播放状态
        else{
            [self.player pause];
        }
        
        self.playBtn.selected=!self.playBtn.selected;
    }
}

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



#pragma mark - setter

-(void)setVideoPreviewerMediaInfoModel:(AJMPMediaInfoModel *)mediaInfoModel maxNumberOfMedia:(int)maxNumberOfMedia selectedMediaInfoModelArray:(NSMutableArray *)selectedMediaInfoModelArray chooseBtnClickBlock:(void (^)(AJMPMediaInfoModel *))chooseBtnClickBlock
{
    _mediaInfoModel=mediaInfoModel;
    _maxNumberOfMedia=maxNumberOfMedia;
    _selectedMediaInfoModelArray=selectedMediaInfoModelArray;
    _chooseBtnClickBlock=chooseBtnClickBlock;
    
    _mediaInfoModel=mediaInfoModel;
    
    //设置勾选状态
    self.chooseBtn.selected=_mediaInfoModel.isChooseStatus;
    
    //解析video
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:_mediaInfoModel.asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        
        NSLog(@"---资源已获取！！！");
        
        //video播放器
        self.playerItem=[AVPlayerItem playerItemWithAsset:asset];
        self.player= [AVPlayer playerWithPlayerItem:self.playerItem];
        
        //设置监听
        [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
        
        //可播放可录音，更可以后台播放，还可以在其他程序播放的情况下暂停播放
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:nil];
        
        //必须加入主线程，才能及时更新UI！！
        dispatch_async(dispatch_get_main_queue(),^{
            
            //video播放器层
            AVPlayerLayer * playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
            playerLayer.frame = self.bounds;
            [self.layer insertSublayer:playerLayer atIndex:0];
            self.playerLayer=playerLayer;
            
            //添加缩放动画
            CABasicAnimation * pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            pulse.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            pulse.duration = 0.2;
            pulse.repeatCount= 1;
            pulse.autoreverses= NO;//是否需要反弹效果
            pulse.fromValue= [NSNumber numberWithFloat:0.5];
            pulse.toValue= [NSNumber numberWithFloat:1.0];
            [self.playerLayer addAnimation:pulse forKey:nil];
            
        });
        
    }];
    
}


#pragma mark - AVPlayerItem的status监听

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
 
    if([keyPath isEqualToString:@"status"]) {
        
        AVPlayerItemStatus status= [[change objectForKey:@"new"]intValue];
        
        if(status==AVPlayerItemStatusReadyToPlay){
            
            [self.player play];//开始播放
            self.playBtn.selected=NO;
            
        }
        else if(status==AVPlayerItemStatusFailed || status==AVPlayerItemStatusUnknown){
            
            self.playBtn.selected=YES;
        }
    }
    
}

#pragma mark - video播放完成的通知

-(void)playFinished:(NSNotification*)notification
{
    NSLog(@"视频播放完成.");
    
    //回退到0s，并暂停
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        self.playBtn.selected=YES;
    }];
}


@end
