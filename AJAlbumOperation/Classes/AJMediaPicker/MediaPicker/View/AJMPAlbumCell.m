//
//  AJMPAlbumCell.m
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/5/29.
//  Copyright © 2017年 AJ. All rights reserved.
//

#define PaddingX_10 10.0f
#define PaddingY_6 6.0f
#define FontSize_16 16
#define FontSize_12 12

#define CellHeight ((60*Ratio_Width)+PaddingY_6*2)
#define PicImageViewWidthHeight (60*Ratio_Width)
#define AlbumNameLabelHeight 20.0f
#define AlbumPicNumLabelHeight 12.0f

#import "AJMPAlbumCell.h"
#import "AJMPDefinitionHeader.h"

@implementation AJMPAlbumCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(id)albumCellWithTableView:(UITableView *)tableView
{
    NSString * ID=NSStringFromClass([self class]);
    AJMPAlbumCell * cell=[tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell=[[AJMPAlbumCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    return  cell;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //        self.selectionStyle=UITableViewCellSelectionStyleNone;
        
        /*
         创建子控件对象，并加入内容视图
         */
        
        //相册封面图
        UIImageView * picImageView=[[UIImageView alloc]initWithFrame:CGRectMake(PaddingX_10, PaddingY_6, PicImageViewWidthHeight, PicImageViewWidthHeight)];
        [picImageView setImage:[UIImage imageNamed:@"AJMP_placeholder_picture"]];
        picImageView.contentMode = UIViewContentModeScaleAspectFill;
        picImageView.clipsToBounds = YES;
        [self.contentView addSubview:picImageView];
        _picImageView=picImageView;
        
        
        //相册名
        UILabel * albumNameLabel=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_picImageView.frame)+PaddingX_10, (PaddingY_6+PicImageViewWidthHeight/2)-AlbumNameLabelHeight, SCREEN_WIDTH-(CGRectGetMaxX(_picImageView.frame)+PaddingX_10)-PaddingX_10, AlbumNameLabelHeight)];
        albumNameLabel.textColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.80];
        albumNameLabel.textAlignment=NSTextAlignmentLeft;
        albumNameLabel.font=[UIFont systemFontOfSize:16];
        [self.contentView addSubview:albumNameLabel];
        _albumNameLabel=albumNameLabel;
        
        
        //相册照片数
        UILabel * albumPicNumLabel=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_picImageView.frame)+PaddingX_10, (PaddingY_6+PicImageViewWidthHeight/2), SCREEN_WIDTH-(CGRectGetMaxX(_picImageView.frame)+PaddingX_10)-PaddingX_10, AlbumPicNumLabelHeight)];
        albumPicNumLabel.textColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.48];
        albumPicNumLabel.textAlignment=NSTextAlignmentLeft;
        albumPicNumLabel.font=[UIFont systemFontOfSize:12];
        [self.contentView addSubview:albumPicNumLabel];
        _albumPicNumLabel=albumPicNumLabel;
        
        
    }
    return self;
}


@end
