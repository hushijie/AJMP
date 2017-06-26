//
//  AJMPMultipleImageSelectViewController.m
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/1.
//  Copyright © 2017年 AJ. All rights reserved.
//

#define BottomViewHeight (48*Ratio_Height)
#define AJMPMediaCellIdentifier @"AJMPMediaCell"

#import "AJMPMultipleImageSelectViewController.h"
#import <Photos/Photos.h>
#import "AJMPAlbumListView.h"
#import "AJMPAlbumInfoModel.h"
#import "AJMPMediaInfoModel.h"
#import "AJMPNavBarTitleView.h"
#import "AJMPAlbumCell.h"
#import "AJMPMediaCell.h"
#import "AJMPBottomView.h"
#import "AJMPDefinitionHeader.h"
#import "AJMPAuthorizationTool.h"
#import "AJMPDeniedAuthViewController.h"
#import "AJMediaSaveTool.h"
#import "AJImageCropperViewController.h"
#import "AJMPMediaPreviewerViewController.h"

@interface AJMPMultipleImageSelectViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,AJImageCropperViewControllerDelegate>


@property (nonatomic ,assign)AJMediaPickerType mediaPickerType;

/**
 图片的最大选中数量 (maxNumberOfMedia=0:表示可以选择无穷个媒体资源)
 */
@property (nonatomic ,assign)int maxNumberOfMedia;

@property (nonatomic ,copy)void(^confirmSelectedMediaInfoArrayBlock)(NSMutableArray * mediaInfoModelArray);

@property (nonatomic ,retain)NSMutableArray * currentSelectedMediaInfoModelArray;

/*
 单图选择并裁剪类型-相关属性
 */
@property (nonatomic ,assign)CGFloat widthRatio;

@property (nonatomic ,assign)CGFloat heightRatio;

@property (nonatomic ,copy)void(^backCroppedImageBlock)(UIImage * croppedImage);

/*
 储存相册分类，包含三大分类：allPhotos,SmartAlbum,userAlbum
 其中SmartAlbum,userAlbum 会有子相册,
 #注：这里存储的是有图片的全部子相册!
 */
@property (nonatomic, strong) NSMutableArray * albumInfoModelArray;


/**
 当前选中相册 的数据源
 */
@property (nonatomic ,retain)NSArray * mediaInfoModelArray;


/**
 当前视图控制器中的选中的picInfoModel数组
 */
@property (nonatomic ,strong)NSMutableArray * selectedMediaInfoModelArray;


/**
 navBar上的标题视图（可点击选择相册）
 */
@property (nonatomic ,weak)AJMPNavBarTitleView * titleView;


/**
 相册列表的视图
 */
@property (nonatomic ,weak)AJMPAlbumListView * albumListView;


/**
 相册列表下面的遮罩视图
 */
@property (nonatomic ,weak)UIView * maskView;


/**
 底部 “取消／完成”视图
 */
@property (nonatomic ,weak)AJMPBottomView * bottomView;


/**
 多选图片内容视图
 */
@property (nonatomic ,weak)UICollectionView * collectionView;


///**
// 空视图
// */
//@property (nonatomic ,weak)OWEmptyView * emptyView;

@end

@implementation AJMPMultipleImageSelectViewController


#pragma mark - vc生命周期

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        /*
         取消按钮
         */
        UIBarButtonItem * leftItem=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(leftBtnClick)];
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
    
    //设置背景颜色为白色
    self.view.backgroundColor=[UIColor whiteColor];
    //将自动调整间距的属性关闭
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    
    if (self.albumInfoModelArray.count) {
        
        [self collectionView];
        [self bottomView];
        [self maskView];
        [self albumListView];
        [self titleView];
        
        //初始化，赋值第一个fetchResult
        self.mediaInfoModelArray=((AJMPAlbumInfoModel *)(self.albumInfoModelArray[0])).mediaInfoModelArray;
        
    }
    else{
        self.title=@"相册";
        
        /*
         无照片 拍点照片与朋友们分享吧 view
         */
        //        [self.emptyView class];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{

}



#pragma mark - 懒加载


//-(OWEmptyView *)emptyView
//{
//    if (!_emptyView) {
//        
//        OWEmptyView * view=[[OWEmptyView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREENH_HEIGHT-64)];
//        view.emptyTitle=@"无照片，你可以使用相机拍摄照片";
//        [self.view addSubview:view];
//        _emptyView=view;
//    }
//    return _emptyView;
//}


-(NSMutableArray *)albumInfoModelArray
{
    if (!_albumInfoModelArray) {
        
        _albumInfoModelArray=[NSMutableArray array];
        
        //获取有图片或视频资源的相册！
        
        /*
         所有图片或视频
         */
        PHFetchOptions * allPhotosOptions = [[PHFetchOptions alloc] init];
        allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];//图片配置设置排序规则(时间倒序)
        
        if (_mediaPickerType==AJMediaPickerType_MultipleImageSelect || _mediaPickerType==AJMediaPickerType_SingleImageSelectWithCropper) {
            allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];//只获取图片
        }
        else if (_mediaPickerType==AJMediaPickerType_VideoSelect){
            allPhotosOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];//只获取video
        }
        
        //获取所有图片资源
        PHFetchResult *allPhotos = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
        
        if (allPhotos.count>0) {
            
            //组装mediaInfoModel
            NSMutableArray * allPhotosAlbumMediaInfoModelArray=[NSMutableArray array];
            
            for (PHAsset * asset in allPhotos) {
                
                AJMPMediaInfoModel * mediaInfoModel=[[AJMPMediaInfoModel alloc]init];
                mediaInfoModel.asset=asset;
                [allPhotosAlbumMediaInfoModelArray addObject:mediaInfoModel];
                
                //重装数据
                [self ergodicCurrentSelectedMediaInfoModelArrayWithMediaInfoModel:mediaInfoModel];
                
            }
            
            //组装相册model
            AJMPAlbumInfoModel * allPhotosAlbumInfoModel=[[AJMPAlbumInfoModel alloc]init];
            allPhotosAlbumInfoModel.albumName=@"相机胶卷";
            allPhotosAlbumInfoModel.mediaInfoModelArray=allPhotosAlbumMediaInfoModelArray;
            [_albumInfoModelArray addObject:allPhotosAlbumInfoModel];
        }
        
        
        /*
         智能相册 (“最近添加”)
         */
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded options:nil];
        
        if (smartAlbums && smartAlbums.count>0) {
            
            for (PHCollection * collection in smartAlbums) {
                
                if ([collection isKindOfClass:[PHAssetCollection class]]) {
                    
                    PHFetchResult *fetchResult=[PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:nil];
                    if (fetchResult.count>0) {
                    
                        //组装mediaInfoModel
                        NSMutableArray * smartAlbumMediaInfoModelArray=[NSMutableArray array];
                        
                        for (PHAsset * asset in fetchResult) {
                            
                            if (((_mediaPickerType==AJMediaPickerType_MultipleImageSelect || _mediaPickerType==AJMediaPickerType_SingleImageSelectWithCropper) && asset.mediaType==PHAssetMediaTypeImage) || (_mediaPickerType==AJMediaPickerType_VideoSelect && asset.mediaType==PHAssetMediaTypeVideo)) {

                                AJMPMediaInfoModel * mediaInfoModel=[[AJMPMediaInfoModel alloc]init];
                                mediaInfoModel.asset=asset;
                                [smartAlbumMediaInfoModelArray addObject:mediaInfoModel];
                                
                                //重装数据
                                [self ergodicCurrentSelectedMediaInfoModelArrayWithMediaInfoModel:mediaInfoModel];
                                
                            }
                            
                        }
                        
                        if (smartAlbumMediaInfoModelArray.count>0) {
                            //组装相册model
                            AJMPAlbumInfoModel * smartAlbumInfoModel=[[AJMPAlbumInfoModel alloc]init];
                            smartAlbumInfoModel.albumName=collection.localizedTitle;
                            smartAlbumInfoModel.mediaInfoModelArray=smartAlbumMediaInfoModelArray;
                            [_albumInfoModelArray addObject:smartAlbumInfoModel];
                        }
                        
                    }
                }
            }
        }
        
        
        /*
         获取用户自定义相册
         */
        PHFetchResult * topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
        
        if (topLevelUserCollections && topLevelUserCollections.count>0) {
            
            for (PHCollection * collection in topLevelUserCollections) {
                
                if ([collection isKindOfClass:[PHAssetCollection class]]) {
                    
                    PHFetchResult *fetchResult=[PHAsset fetchAssetsInAssetCollection:(PHAssetCollection *)collection options:nil];
                    if (fetchResult.count>0) {
                        
                        //组装mediaInfoModel
                        NSMutableArray * userAlbumMediaInfoModelArray=[NSMutableArray array];
                        
                        for (PHAsset * asset in fetchResult) {
                            
                            if (((_mediaPickerType==AJMediaPickerType_MultipleImageSelect || _mediaPickerType==AJMediaPickerType_SingleImageSelectWithCropper) && asset.mediaType==PHAssetMediaTypeImage) || (_mediaPickerType==AJMediaPickerType_VideoSelect && asset.mediaType==PHAssetMediaTypeVideo)) {
                                
                                AJMPMediaInfoModel * mediaInfoModel=[[AJMPMediaInfoModel alloc]init];
                                mediaInfoModel.asset=asset;
                                [userAlbumMediaInfoModelArray addObject:mediaInfoModel];
                                
                                //重装数据
                                [self ergodicCurrentSelectedMediaInfoModelArrayWithMediaInfoModel:mediaInfoModel];
                                
                            }
                            
                        }
                        
                        if (userAlbumMediaInfoModelArray.count>0) {
                            
                            //组装相册model
                            AJMPAlbumInfoModel * userAlbumInfoModel=[[AJMPAlbumInfoModel alloc]init];
                            userAlbumInfoModel.albumName=collection.localizedTitle;
                            userAlbumInfoModel.mediaInfoModelArray=userAlbumMediaInfoModelArray;
                            [_albumInfoModelArray addObject:userAlbumInfoModel];
                            
                        }
                        
                    }
                }
            }
        }
    
        
    }
    
    return _albumInfoModelArray;
}


-(NSMutableArray *)selectedMediaInfoModelArray
{
    if (!_selectedMediaInfoModelArray) {
        
        _selectedMediaInfoModelArray=[NSMutableArray array];
    }
    return _selectedMediaInfoModelArray;
}



-(AJMPNavBarTitleView *)titleView
{
    if (!_titleView) {
        
        AJMPNavBarTitleView * titleView=[AJMPNavBarTitleView titleView];
        
        //初始化标题
        titleView.albumInfoModel=self.albumInfoModelArray[0];
        
        __weak __typeof__(AJMPNavBarTitleView *) weakTitleView = titleView;
        
        [titleView setIsSelectArrowBlock:^(BOOL isSelectArrowStatus) {
            
            weakTitleView.upDownArrowBtn.selected=isSelectArrowStatus;
            
            //展开相册列表
            if (isSelectArrowStatus) {
                
                _maskView.hidden=NO;
                
                [UIView animateWithDuration:0.2 animations:^{
                    
                    _albumListView.frame=CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height/2);
                    
                } completion:^(BOOL finished) {
                    
                }];
                
            }
            //隐藏相册列表
            else{
                
                _maskView.hidden=YES;
                
                [UIView animateWithDuration:0.2 animations:^{
                    
                    _albumListView.frame=CGRectMake(0, -(self.view.bounds.size.height/2)+64, self.view.bounds.size.width, self.view.bounds.size.height/2);
                    
                } completion:^(BOOL finished) {
                    
                }];
                
            }
            
        }];
        
        self.navigationItem.titleView=titleView;
        _titleView=titleView;
    }
    return _titleView;
}



-(AJMPAlbumListView *)albumListView
{
    if (!_albumListView) {
        
        AJMPAlbumListView * listView=[[AJMPAlbumListView alloc]initWithFrame:CGRectMake(0, -(self.view.bounds.size.height/2)+64, self.view.bounds.size.width, self.view.bounds.size.height/2)];
        
        //给相册列表view传递数据源
        listView.dataSource=self.albumInfoModelArray;
        
        __weak __typeof__(self) weakSelf = self;
        
        //设置选择相册之后的block回调
        [listView setDidSelectAlbumBlock:^(AJMPAlbumInfoModel * albumInfoModel) {
            
            //刷新选择图片的collectionView
            NSArray * mediaInfoModelArray=albumInfoModel.mediaInfoModelArray;
            weakSelf.mediaInfoModelArray=mediaInfoModelArray;
            
            //刷新titleView
            weakSelf.titleView.albumInfoModel=albumInfoModel;
            
            //收起相册列表
            weakSelf.titleView.isSelectArrowBlock(NO);
            
        }];
        
        [self.view addSubview:listView];
        _albumListView=listView;
    }
    return _albumListView;
}


-(UIView *)maskView
{
    if (!_maskView) {
        
        UIView * view=[[UIView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64)];
        view.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        view.hidden=YES;
        
        //点击手势（隐藏maskView、收起相册列表）
        UITapGestureRecognizer * tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(maskViewTapGestureAction)];
        [view addGestureRecognizer:tapGesture];
        
        [self.view addSubview:view];
        _maskView=view;
    }
    return _maskView;
}


-(AJMPBottomView *)bottomView
{
    if (!_bottomView) {
        
        AJMPBottomView * bottomView=[AJMPBottomView bottomView];
        
        __weak __typeof__(self)weakSelf=self;
        
        //“取消”按钮回调
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
        
        if (_mediaPickerType==AJMediaPickerType_SingleImageSelectWithCropper) {
            bottomView.hidden=YES;
        }
        else if (_mediaPickerType==AJMediaPickerType_MultipleImageSelect || _mediaPickerType==AJMediaPickerType_VideoSelect){
            bottomView.hidden=NO;
        }
        
        [self.view addSubview:bottomView];
        _bottomView=bottomView;
    }
    return _bottomView;
}




-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 1.0;
        layout.minimumInteritemSpacing = 1.0;
        CGFloat itemWidth = (SCREEN_WIDTH - AJMPMediaCellCountOneLine + 1) / AJMPMediaCellCountOneLine;
        layout.itemSize = CGSizeMake(itemWidth, itemWidth);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        UICollectionView * collectionView = nil;
        
        if (_mediaPickerType==AJMediaPickerType_SingleImageSelectWithCropper) {
            collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREENH_HEIGHT-64) collectionViewLayout:layout];
        }
        else if (_mediaPickerType==AJMediaPickerType_MultipleImageSelect || _mediaPickerType==AJMediaPickerType_VideoSelect){
            collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREENH_HEIGHT-64-BottomViewHeight) collectionViewLayout:layout];
        }
        
        collectionView.backgroundColor = AJMPContentViewBackgroundColor;
        
        [collectionView registerClass:[AJMPMediaCell class] forCellWithReuseIdentifier:AJMPMediaCellIdentifier];
        
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        
        [self.view addSubview:collectionView];
        _collectionView=collectionView;
    }
    return _collectionView;
}


#pragma mark - 点击事件

/**
 取消按钮点击事件
 */
-(void)leftBtnClick
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

/**
 maskView点击事件
 */
-(void)maskViewTapGestureAction
{
    self.titleView.upDownArrowBtn.selected=NO;
    
    //隐藏相册列表
    
    _maskView.hidden=YES;
    
    [UIView animateWithDuration:0.2 animations:^{
        
        _albumListView.frame=CGRectMake(0, -(self.view.bounds.size.height/2)+64, self.view.bounds.size.width, self.view.bounds.size.height/2);
        
    } completion:^(BOOL finished) {
        
    }];
    
}




#pragma mark - setter

-(void)setMediaPickerType:(AJMediaPickerType)mediaPickerType maxNumberOfMedia:(int)maxNumberOfMedia currentSelectedMediaInfoModelArray:(NSMutableArray *)currentSelectedMediaInfoModelArray confirmSelectedMediaInfoArrayBlock:(void(^)(NSMutableArray * mediaInfoModelArray))confirmSelectedMediaInfoArrayBlock
{
    _mediaPickerType=mediaPickerType;
    _maxNumberOfMedia=maxNumberOfMedia;
    _currentSelectedMediaInfoModelArray=currentSelectedMediaInfoModelArray;
    _confirmSelectedMediaInfoArrayBlock=confirmSelectedMediaInfoArrayBlock;
}


-(void)setSingleImageSelectWithCropperWidthRatio:(CGFloat)widthRatio heightRatio:(CGFloat)heightRatio backCroppedImageBlock:(void (^)(UIImage *))backCroppedImageBlock
{
    _mediaPickerType=AJMediaPickerType_SingleImageSelectWithCropper;
    _widthRatio=widthRatio;
    _heightRatio=heightRatio;
    _backCroppedImageBlock=backCroppedImageBlock;
}


-(void)setMediaInfoModelArray:(NSArray *)mediaInfoModelArray
{
    if (_mediaInfoModelArray!=mediaInfoModelArray) {
        
        _mediaInfoModelArray=mediaInfoModelArray;
        
        [self.collectionView reloadData];
        self.collectionView.contentOffset=CGPointMake(0, 0);
        
    }
}


#pragma mark - 遍历上级视图中已选中的图片,组装选中相片数据源


-(void)ergodicCurrentSelectedMediaInfoModelArrayWithMediaInfoModel:(AJMPMediaInfoModel *)mediaInfoModel
{
    
    /*
     遍历上级VC已经有选中的图片
     */
    if (self.currentSelectedMediaInfoModelArray.count) {
        
        for (AJMPMediaInfoModel * currentMediaInfoModel in self.currentSelectedMediaInfoModelArray) {
            
            //找到相同的照片:设置选中状态、加入选中图片数组
            if ([mediaInfoModel.asset.localIdentifier isEqualToString:currentMediaInfoModel.asset.localIdentifier]) {
                
                mediaInfoModel.isChooseStatus=YES;
                
                int i=0;
                for (AJMPMediaInfoModel * model in self.selectedMediaInfoModelArray) {
                    
                    //如果已经有该图片，不重复添加
                    if ([model.asset.localIdentifier isEqualToString:mediaInfoModel.asset.localIdentifier]) {
                        i++;
                    }
                }
                
                if (i==0) {
                    [self.selectedMediaInfoModelArray addObject:mediaInfoModel];
                }
                
                //设置底部“完成”按钮的显示
                [self.bottomView setConfirmBtnCurrentCount:self.selectedMediaInfoModelArray.count maxCount:self.maxNumberOfMedia];
                
                break;
            }
        }
        
    }
    
}





#pragma mark - UICollectionViewDataSource、UICollectionViewDelegate


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //+1:打开相机的cell
    return self.mediaInfoModelArray.count+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    AJMPMediaCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AJMPMediaCellIdentifier forIndexPath:indexPath];
    
    //第1个相机cell
    if (indexPath.row==0) {
        
        cell.isCameraCellStatus=YES;
        
        __weak __typeof__(self)weakSelf=self;
        
        //设置点击相机回调
        [cell setCameraBtnClickBlock:^{
            
            if (weakSelf.maxNumberOfMedia!=0 && weakSelf.selectedMediaInfoModelArray.count>=weakSelf.maxNumberOfMedia) {
                //[OWProgressHUD showMessage:[NSString stringWithFormat:@"最多选择%d张照片",weakSelf.maxNumberOfMedia]];
                NSLog(@"最多选择%d张照片",weakSelf.maxNumberOfMedia);
                return;
            }
            
            [AJMPAuthorizationTool cameraAuthorityJudgementAuthorized:^{
                
                UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
                pickerController.allowsEditing = NO;
                pickerController.delegate = weakSelf;
                pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                
                if (weakSelf.mediaPickerType==AJMediaPickerType_VideoSelect) {
                    pickerController.mediaTypes=@[@"public.movie"];//设置为录制视频类型（默认是拍照类型）
                    //pickerController.videoMaximumDuration=10;//最大录制时长限制(10s)
                }
                
                [weakSelf presentViewController:pickerController animated:YES completion:^{
                    
                }];
                
            } deniedAuth:^{
                
                AJMPDeniedAuthViewController * deniedAuthViewController=[[AJMPDeniedAuthViewController alloc]init];
                deniedAuthViewController.deniedAuthType=DeniedAuthType_Camera;
                [weakSelf.navigationController pushViewController:deniedAuthViewController animated:YES];
                
            }];
            
        }];
        
        
    }
    //其余的是展示图片、视频的cell
    else{
        
        cell.isCameraCellStatus=NO;
        
        AJMPMediaInfoModel * mediaInfoModel=self.mediaInfoModelArray[indexPath.item-1];
        cell.mediaInfoModel=mediaInfoModel;
        cell.albumInfoModelArray=self.albumInfoModelArray;
        cell.mediaPickerType=self.mediaPickerType;
        
        __weak __typeof__(self)weakSelf=self;
        __weak __typeof__(AJMPMediaCell *)weakCell=cell;
        
        
        if (self.mediaPickerType==AJMediaPickerType_MultipleImageSelect || self.mediaPickerType==AJMediaPickerType_VideoSelect) {
            
            //选择图片 时候的回调
            [cell setChoosePicBlock:^(BOOL isChoose) {
                
                //由非选中 变成选中
                if (isChoose) {
                    
                    //超过最大选中数
                    if (weakSelf.maxNumberOfMedia!=0 && weakSelf.selectedMediaInfoModelArray.count>=weakSelf.maxNumberOfMedia) {
                        //[OWProgressHUD showMessage:[NSString stringWithFormat:@"最多选择%d张照片",weakSelf.maxNumberOfMedia]];
                        NSLog(@"最多选择%d张照片",weakSelf.maxNumberOfMedia);
                        return;
                    }
                    //没有超过最大选中数
                    else{
                        weakCell.isCheckChooseBtnStatus=YES;
                        [weakSelf.selectedMediaInfoModelArray addObject:weakCell.mediaInfoModel];
                    }
                }
                
                //由选中 变成非选中
                else{
                    
                    weakCell.isCheckChooseBtnStatus=NO;
                    
                    for (AJMPMediaInfoModel * mediaInfoModel in weakSelf.selectedMediaInfoModelArray) {
                        
                        //找到这个数据，并移除
                        if ([mediaInfoModel.asset.localIdentifier isEqualToString:weakCell.mediaInfoModel.asset.localIdentifier]) {
                            
                            [weakSelf.selectedMediaInfoModelArray removeObject:mediaInfoModel];
                            break;
                        }
                    }
                }
                
                //设置底部“完成”按钮的显示
                [weakSelf.bottomView setConfirmBtnCurrentCount:weakSelf.selectedMediaInfoModelArray.count maxCount:weakSelf.maxNumberOfMedia];
                
            }];
            
        }
        
        else if (self.mediaPickerType==AJMediaPickerType_SingleImageSelectWithCropper){
            
            //图片点击回调
            [cell setSingleImageSelectWithCropperTapGestureBlock:^(UIImage * originalImage) {
                
                AJImageCropperViewController * vc=[[AJImageCropperViewController alloc]init];
                
                [vc setImage:originalImage cropperWidthRatio:weakSelf.widthRatio cropperHeightRatio:weakSelf.heightRatio delegate:weakSelf];
                
                [weakSelf.navigationController presentViewController:vc animated:YES completion:^{
                    
                }];
                
            }];
            
        }
        
    }
    
    return cell;
    
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //第1个相机cell
    if (indexPath.row==0) {
        
    }
    
    //其余的是展示图片、视频的cell
    else{
        
        //video
        if (self.mediaPickerType==AJMediaPickerType_VideoSelect) {
            
            AJMPMediaPreviewerViewController * vc=[[AJMPMediaPreviewerViewController alloc]init];
            
            __weak __typeof__(self)weakSelf=self;
            
            [vc setVideoPreviewerMediaInfoModel:self.mediaInfoModelArray[indexPath.item-1] maxNumberOfMedia:self.maxNumberOfMedia selectedMediaInfoModelArray:self.selectedMediaInfoModelArray chooseBtnClickBlock:^(AJMPMediaInfoModel *mediaInfoModel) {
                
                //点击了“勾选”按钮-刷新view
                [weakSelf.collectionView reloadData];
                [weakSelf.bottomView setConfirmBtnCurrentCount:weakSelf.selectedMediaInfoModelArray.count maxCount:weakSelf.maxNumberOfMedia];
                
            } confirmSelectedMediaInfoArrayBlock:^(NSMutableArray *mediaInfoModelArray) {
                
                //点击了“完成”按钮-返回“已勾选数组”并且退出vc
                if (weakSelf.confirmSelectedMediaInfoArrayBlock) {
                    weakSelf.confirmSelectedMediaInfoArrayBlock(weakSelf.selectedMediaInfoModelArray);
                    [weakSelf leftBtnClick];
                }
                
            }];
            
            [self.navigationController pushViewController:vc animated:NO];
            
        }
        
        //图片
        else if (self.mediaPickerType==AJMediaPickerType_MultipleImageSelect){
            
            AJMPMediaPreviewerViewController * vc=[[AJMPMediaPreviewerViewController alloc]init];
            
            __weak __typeof__(self)weakSelf=self;
            
            [vc setImagePreviewerWithCurrentIndex:((int)(indexPath.item-1)) maxNumberOfMedia:self.maxNumberOfMedia selectedMediaInfoModelArray:self.selectedMediaInfoModelArray allMediaInfoModelArray:self.mediaInfoModelArray chooseBtnClickBlock:^(AJMPMediaInfoModel *mediaInfoModel) {
                
                //点击了“勾选”按钮-刷新view
                [weakSelf.collectionView reloadData];
                [weakSelf.bottomView setConfirmBtnCurrentCount:weakSelf.selectedMediaInfoModelArray.count maxCount:weakSelf.maxNumberOfMedia];
                
            } confirmSelectedMediaInfoArrayBlock:^(NSMutableArray *mediaInfoModelArray) {
                
                //点击了“完成”按钮-返回“已勾选数组”并且退出vc
                if (weakSelf.confirmSelectedMediaInfoArrayBlock) {
                    weakSelf.confirmSelectedMediaInfoArrayBlock(weakSelf.selectedMediaInfoModelArray);
                    [weakSelf leftBtnClick];
                }
                
            }];
            
            [self.navigationController pushViewController:vc animated:NO];
            
        }
    }
}




#pragma mark - UIImagePickerViewControllerDeleate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        //退出picker
        [picker dismissViewControllerAnimated:YES completion:^{
        }];
        
        
        NSString * mediaType=[info objectForKey:UIImagePickerControllerMediaType];
        
        //图片
        if ([mediaType isEqualToString:@"public.image"]) {
    
            UIImage * image = [info valueForKey:UIImagePickerControllerOriginalImage];
            
            //保存图片到自定义相册
            [[AJMediaSaveTool sharedTool] saveImage:image success:^(PHAsset *asset) {
                
                if (self.mediaPickerType==AJMediaPickerType_MultipleImageSelect || self.mediaPickerType==AJMediaPickerType_VideoSelect) {
                    
                    AJMPMediaInfoModel * mediaInfoModel=[[AJMPMediaInfoModel alloc]init];
                    mediaInfoModel.asset=asset;
                    mediaInfoModel.isChooseStatus=YES;
                    [self.selectedMediaInfoModelArray addObject:mediaInfoModel];
                    
                    //设置底部视图（完成按钮）
                    [self.bottomView setConfirmBtnCurrentCount:self.selectedMediaInfoModelArray.count maxCount:self.maxNumberOfMedia];
                    
                    //刷新选中数据源、回退到上级视图
                    if (self.confirmSelectedMediaInfoArrayBlock) {
                        self.confirmSelectedMediaInfoArrayBlock(self.selectedMediaInfoModelArray);
                        [self leftBtnClick];
                    }
                    
                }
                
                else if (self.mediaPickerType==AJMediaPickerType_SingleImageSelectWithCropper){
                    
                    AJImageCropperViewController * vc=[[AJImageCropperViewController alloc]init];
                    
                    [vc setImage:image cropperWidthRatio:self.widthRatio cropperHeightRatio:self.heightRatio delegate:self];
                    
                    [self.navigationController presentViewController:vc animated:YES completion:^{
                        
                    }];
                    
                }
                
            } failure:^{
                
            }];
            
        }
        //视频
        else if ([mediaType isEqualToString:@"public.movie"]){
        
            NSURL * videoURL=[info objectForKey:UIImagePickerControllerMediaURL];
            
            //保存视频到自定义相册
            [[AJMediaSaveTool sharedTool] saveMediaWithMediaType:AJMediaSaveType_Video fileURL:videoURL success:^(PHAsset * asset) {
            
                AJMPMediaInfoModel * mediaInfoModel=[[AJMPMediaInfoModel alloc]init];
                mediaInfoModel.asset=asset;
                mediaInfoModel.isChooseStatus=YES;
                [self.selectedMediaInfoModelArray addObject:mediaInfoModel];
                
                //设置底部视图（完成按钮）
                [self.bottomView setConfirmBtnCurrentCount:self.selectedMediaInfoModelArray.count maxCount:self.maxNumberOfMedia];
                
                //刷新选中数据源、回退到上级视图
                if (self.confirmSelectedMediaInfoArrayBlock) {
                    self.confirmSelectedMediaInfoArrayBlock(self.selectedMediaInfoModelArray);
                    [self leftBtnClick];
                }
                
            } failure:^{
                
            }];
            
        }
    
    }
    
}


#pragma mark - AJImageCropperViewControllerDelegate

-(void)imageCropperViewController:(AJImageCropperViewController *)controller didCropImage:(UIImage *)croppedImage
{
    
    if (self.backCroppedImageBlock) {
        
        //返回裁剪后的图片
        self.backCroppedImageBlock(croppedImage);
        
        [controller dismissViewControllerAnimated:YES completion:^{
            
            [self leftBtnClick];
            
        }];
        
    }
    
}


@end
