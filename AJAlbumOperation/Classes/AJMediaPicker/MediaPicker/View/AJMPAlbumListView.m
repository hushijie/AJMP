//
//  AJMPAlbumListView.m
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/1.
//  Copyright © 2017年 AJ. All rights reserved.
//

#define PaddingY_6 6.0f
#define CellHeight ((60*Ratio_Width)+PaddingY_6*2)

#import "AJMPAlbumListView.h"
#import <Photos/Photos.h>
#import "AJMPDefinitionHeader.h"
#import "AJMPAlbumCell.h"
#import "AJMPMediaInfoModel.h"

@interface AJMPAlbumListView ()<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic ,weak)UITableView * tableView;

//cell高度
@property (nonatomic ,assign)CGFloat cellHeight;

@end

@implementation AJMPAlbumListView


#pragma mark - 懒加载


-(UITableView *)tableView
{
    if (!_tableView) {
        UITableView *tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) style:UITableViewStyleGrouped];
        
        [tableView setBackgroundColor:AJMPContentViewBackgroundColor];
        tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLineEtched;
        
        tableView.delegate=self;
        tableView.dataSource=self;
        
        [self addSubview:tableView];
        _tableView=tableView;
    }
    return _tableView;
}


#pragma mark - setter

-(void)setDataSource:(NSArray *)dataSource
{
    _dataSource=dataSource;
    
    [self.tableView reloadData];
}



#pragma mark - tableView的代理方法

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    AJMPAlbumCell * cell=[AJMPAlbumCell albumCellWithTableView:tableView];
    AJMPAlbumInfoModel * albumInfoModel = self.dataSource[indexPath.row];
    
    if (albumInfoModel.mediaInfoModelArray.count>0) {
        //第一张图片资源
        PHAsset * asset=((AJMPMediaInfoModel *)(albumInfoModel.mediaInfoModelArray[0])).asset;
        //相册封面图片
        [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(60, 60) contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            //照片不为空
            if (result) {
                cell.picImageView.image=result;
            }
            //照片为空、加载默认加载失败的图片照片
            else{
                cell.picImageView.image=[UIImage imageNamed:@"AJMP_placeholder_picture"];
            }
        }];
    }
    else{
        cell.picImageView.image=[UIImage imageNamed:@"AJMP_placeholder_picture"];
    }
    
    //相册名
    cell.albumNameLabel.text=albumInfoModel.albumName;
    //图片数
    cell.albumPicNumLabel.text = [NSString stringWithFormat:@"%zi", albumInfoModel.mediaInfoModelArray.count];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CellHeight;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    AJMPAlbumInfoModel * albumInfoModel=self.dataSource[indexPath.row];
    
    if (self.didSelectAlbumBlock) {
        self.didSelectAlbumBlock(albumInfoModel);
    }
    
}




@end
