//
//  AJMPNavBarTitleView.m
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/1.
//  Copyright © 2017年 AJ. All rights reserved.
//

#define TitleViewWidth 130.0f
#define TitleViewHeight 30.0f
#define ArrowBtnWidthHeight 25.0f

#import "AJMPNavBarTitleView.h"

@interface AJMPNavBarTitleView ()

/**
 相册名
 */
@property (nonatomic ,weak)UILabel * titleNameLabel;

@end

@implementation AJMPNavBarTitleView

#pragma mark - 创建视图

+(id)titleView
{
    return [[self alloc]initWithFrame:CGRectMake(0, 0, TitleViewWidth, TitleViewHeight)];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        /*
         创建子视图
         */
        
        UILabel * titleNameLabel=[[UILabel alloc]init];
        titleNameLabel.textColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.80];
        titleNameLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:17];
        titleNameLabel.textAlignment=NSTextAlignmentLeft;
        [self addSubview:titleNameLabel];
        _titleNameLabel=titleNameLabel;
        
        UIButton * btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.userInteractionEnabled=NO;
        [btn setImage:[UIImage imageNamed:@"AJMP_arrow_down"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"AJMP_arrow_up"] forState:UIControlStateSelected];
        [self addSubview:btn];
        _upDownArrowBtn=btn;
        
        //添加点击手势
        UITapGestureRecognizer * tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture)];
        [self addGestureRecognizer:tapGesture];
        
    }
    return self;
}



/**
 手势的点击事件
 */
-(void)tapGesture
{
    
    if (self.isSelectArrowBlock) {
        self.isSelectArrowBlock(!self.upDownArrowBtn.selected);
    }
}


#pragma mark - setter

-(void)setAlbumInfoModel:(AJMPAlbumInfoModel *)albumInfoModel
{
    _albumInfoModel=albumInfoModel;
    
    CGFloat maxAlbumNameLabelWidth=TitleViewWidth-ArrowBtnWidthHeight;
    
    UIFont * nameLabelFont=[UIFont fontWithName:@"Helvetica-Bold" size:17];
    CGRect nameLabelTextRect = [albumInfoModel.albumName boundingRectWithSize:CGSizeMake(MAXFLOAT, nameLabelFont.pointSize) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:nameLabelFont} context:nil];
    CGFloat needAlbumNameLabelWidth=nameLabelTextRect.size.width;
    
    CGFloat realAlbumNameLabelWidth=0;
    if (needAlbumNameLabelWidth>maxAlbumNameLabelWidth) {
        realAlbumNameLabelWidth=maxAlbumNameLabelWidth;
    }
    else{
        realAlbumNameLabelWidth=needAlbumNameLabelWidth;
    }
    
    _titleNameLabel.frame=CGRectMake((TitleViewWidth-realAlbumNameLabelWidth-ArrowBtnWidthHeight)/2, 0, realAlbumNameLabelWidth, TitleViewHeight);
    _upDownArrowBtn.frame=CGRectMake(CGRectGetMaxX(_titleNameLabel.frame), (TitleViewHeight-ArrowBtnWidthHeight)/2, ArrowBtnWidthHeight, ArrowBtnWidthHeight);
    
    _titleNameLabel.text=albumInfoModel.albumName;
}


@end
