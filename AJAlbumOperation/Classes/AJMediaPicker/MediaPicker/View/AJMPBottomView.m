//
//  AJMPBottomView.m
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/1.
//  Copyright © 2017年 AJ. All rights reserved.
//

#define BottomViewHeight (48*Ratio_Height)
#define PaddingX_12 12
#define PaddingX_20 20
#define CancelBtnWidth 40.0f
#define ConfirmBtnWidth 150.0f

#import "AJMPBottomView.h"
#import "AJMPDefinitionHeader.h"

@interface AJMPBottomView ()

/**
 完成按钮(“（1/9）完成”)
 */
@property (nonatomic ,weak)UIButton * confirmBtn;

@end

@implementation AJMPBottomView

+(id)bottomView
{
    return [[self alloc]initWithFrame:CGRectMake(0, SCREENH_HEIGHT-BottomViewHeight, SCREEN_WIDTH, BottomViewHeight)];
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        /*
         创建子视图
         */
        
        //细线
        UIView * thinLineView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0.5)];
        thinLineView.backgroundColor=[UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1];
        [self addSubview:thinLineView];
        
        
        UIButton * cancelBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.frame=CGRectMake(PaddingX_20, 0, CancelBtnWidth, frame.size.height);
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor colorWithRed:68.0/255.0 green:63.0/255.0 blue:63.0/255.0 alpha:1] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font=[UIFont systemFontOfSize:15];
        //cancelBtn.titleLabel.textAlignment=NSTextAlignmentLeft;//没有效果
        cancelBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentLeft;
        [cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelBtn];
        _cancelBtn=cancelBtn;
        
        
        UIButton * confirmBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        confirmBtn.frame=CGRectMake(frame.size.width-PaddingX_20-ConfirmBtnWidth, 0, ConfirmBtnWidth, frame.size.height);
        [confirmBtn setTitle:@"完成" forState:UIControlStateNormal];
        [confirmBtn setTitleColor:[UIColor colorWithRed:255.0/255.0 green:104.0/255.0 blue:119.0/255.0 alpha:0.32] forState:UIControlStateDisabled];
        [confirmBtn setTitleColor:[UIColor colorWithRed:255.0/255.0 green:104.0/255.0 blue:120.0/255.0 alpha:1] forState:UIControlStateNormal];
        confirmBtn.titleLabel.font=[UIFont systemFontOfSize:15];
        //confirmBtn.titleLabel.textAlignment=NSTextAlignmentRight;//没有作用
        confirmBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
        [confirmBtn addTarget:self action:@selector(confirmBtnClick) forControlEvents:UIControlEventTouchUpInside];
        //初始化 失效
        confirmBtn.enabled=NO;
        [self addSubview:confirmBtn];
        _confirmBtn=confirmBtn;
        
    }
    return self;
}


#pragma mark - 按钮点击事件

-(void)cancelBtnClick
{
    if (self.cancelBtnClickBlock) {
        self.cancelBtnClickBlock();
    }
}

-(void)confirmBtnClick
{
    if (self.confirmBtnClickBlock) {
        self.confirmBtnClickBlock();
    }
}


#pragma mark -

-(void)setConfirmBtnCurrentCount:(long)currentCount maxCount:(long)maxCount
{
    if (currentCount==0) {
        self.confirmBtn.enabled=NO;
        [self.confirmBtn setTitle:@"完成" forState:UIControlStateNormal];
    }
    else{
        
        //可以选择无穷多张
        if (maxCount==0) {
            self.confirmBtn.enabled=YES;
            [self.confirmBtn setTitle:[NSString stringWithFormat:@"(%ld)完成",currentCount] forState:UIControlStateNormal];
        }
        //有限数量的媒体资源
        else{
            self.confirmBtn.enabled=YES;
            [self.confirmBtn setTitle:[NSString stringWithFormat:@"(%ld/%ld)完成",currentCount,maxCount] forState:UIControlStateNormal];
        }
        
    }
}


@end
