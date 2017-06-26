//
//  AJImageCropperViewController.m
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/19.
//  Copyright © 2017年 AJ. All rights reserved.
//

#define BottomToolBarHeight 44.0f
#define BottomBtnWidth 60.0f

#import "AJImageCropperViewController.h"
#import "AJImageCropperTouchView.h"
#import "AJImageCropperScrollView.h"
#import "UIImage+FixOrientation.h"

@interface AJImageCropperViewController ()

<UICollectionViewDelegate,UICollectionViewDataSource>
{
    CGFloat _aspectRatioWidth;  //宽高比例中的宽
    CGFloat _aspectRatioHeight; //宽高比例中的高
}

@property (strong, nonatomic) UIImage *originalImage;
@property (strong, nonatomic) NSArray *images;
@property (weak, nonatomic) id<AJImageCropperViewControllerDelegate> delegate;

@property (strong, nonatomic) UIColor *originalNavigationControllerViewBackgroundColor;
@property (assign, nonatomic) BOOL originalNavigationControllerNavigationBarHidden;
@property (assign, nonatomic) BOOL originalStatusBarHidden;

@property (strong, nonatomic) AJImageCropperScrollView *imageScrollView;
@property (strong, nonatomic) AJImageCropperTouchView *overlayView;
@property (strong, nonatomic) CAShapeLayer *maskLayer;

@property (strong, nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;

@property (assign, nonatomic) BOOL didSetupConstraints;

// 底部“取消”&“选取”视图
@property (nonatomic ,weak)UIView * bottomToolBar;

@property (weak, nonatomic) UICollectionView *collectionview;

@end

@implementation AJImageCropperViewController

#pragma mark - Lifecycle

-(UIView *)bottomToolBar
{
    if (!_bottomToolBar) {
        
        UIView * view=[[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - BottomToolBarHeight, [UIScreen mainScreen].bounds.size.width, BottomToolBarHeight)];
        
        //取消按钮
        UIButton * cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(0, 0, BottomBtnWidth, BottomToolBarHeight);
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [cancelButton addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:cancelButton];
        
        //选取按钮
        UIButton * confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        confirmButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-BottomBtnWidth, 0, BottomBtnWidth, BottomToolBarHeight);
        [confirmButton setTitle:@"选取" forState:UIControlStateNormal];
        [confirmButton setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
        confirmButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [confirmButton addTarget:self action:@selector(confirmBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:confirmButton];
        
        [self.view addSubview:view];
        _bottomToolBar=view;
    }
    return _bottomToolBar;
}


- (UICollectionView *)collectionview {
    
    if (!_collectionview) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
        //item大小
        layout.itemSize = CGSizeMake(60, 60);
        //左右2个item的空隙
        layout.minimumLineSpacing = 5;
        //上下左右的空隙
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        //滚动方向
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        CGRect frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44 - 70, [UIScreen mainScreen].bounds.size.width, 70);
        //创建一个collectionView
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor whiteColor];
        
        [collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:@"Cell"];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [self.view addSubview:collectionView];
        _collectionview = collectionView;
        
        
        
    }
    return _collectionview;
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        //宽高比例 默认是1:1
        _aspectRatioWidth=1;
        _aspectRatioHeight=1;
        
    }
    return self;
}

- (instancetype)initWithImages:(NSMutableArray *)images {
    
    self = [super init];
    if (self) {
        if (images.count != 0) {
            _originalImage = images.firstObject;
            _images = images;
        }
        
    }
    return self;
    
}

- (instancetype)initWithImage:(UIImage *)originalImage
{
    self = [super init];
    if (self) {
        _originalImage = originalImage;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.clipsToBounds = YES;
    [self.view addSubview:self.imageScrollView];
    [self.view addSubview:self.overlayView];
    [self.view addGestureRecognizer:self.doubleTapGestureRecognizer];
    [self bottomToolBar];
    
    //如果有image数组：默认打开第一张图，并布局collectionView
    if (self.images.count>0) {
        self.originalImage=self.images[0];
        [self.collectionview reloadData];
    }
    
    if (!self.imageScrollView.zoomView) {
        [self displayImage];
    }
}


#pragma mark - Custom Accessors

- (AJImageCropperScrollView *)imageScrollView
{
    if (!_imageScrollView) {
        _imageScrollView = [[AJImageCropperScrollView alloc] init];
        _imageScrollView.layer.borderWidth = 1;
        _imageScrollView.layer.borderColor = [UIColor clearColor].CGColor;
        _imageScrollView.clipsToBounds = NO;
        _imageScrollView.frame = [self maskRect];
    }
    return _imageScrollView;
}

- (AJImageCropperTouchView *)overlayView
{
    if (!_overlayView) {
        _overlayView = [[AJImageCropperTouchView alloc] init];
        _overlayView.receiver = self.imageScrollView;
        _overlayView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [_overlayView.layer addSublayer:self.maskLayer];
    }
    return _overlayView;
}

- (CAShapeLayer *)maskLayer
{
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.fillRule = kCAFillRuleEvenOdd;
        _maskLayer.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor;
        
        UIBezierPath *clipPath = [UIBezierPath bezierPathWithRect:self.overlayView.frame];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:[self maskRect]];
        
        [clipPath appendPath:maskPath];
        
        _maskLayer.path = [clipPath CGPath];
    }
    return _maskLayer;
}



- (UITapGestureRecognizer *)doubleTapGestureRecognizer
{
    if (!_doubleTapGestureRecognizer) {
        _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        _doubleTapGestureRecognizer.delaysTouchesEnded = NO;
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    }
    return _doubleTapGestureRecognizer;
}

#pragma mark - Action handling


- (void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    [self resetZoomScale:YES];
    [self resetContentOffset:YES];
}


#pragma mark - 设置裁剪器的宽高比例


-(void)setImage:(UIImage *)image cropperWidthRatio:(CGFloat)cropperWidthRatio cropperHeightRatio:(CGFloat)cropperHeightRatio delegate:(id<AJImageCropperViewControllerDelegate>)delegate
{
    _originalImage=image;
    _aspectRatioWidth=cropperWidthRatio;
    _aspectRatioHeight=cropperHeightRatio;
    _delegate=delegate;
}



#pragma mark - Private

- (void)resetZoomScale:(BOOL)animated
{
    CGFloat zoomScale;
    if (CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) {
        zoomScale = CGRectGetHeight(self.view.bounds) / self.originalImage.size.height;
    } else {
        zoomScale = CGRectGetWidth(self.view.bounds) / self.originalImage.size.width;
    }
    [self.imageScrollView setZoomScale:zoomScale animated:animated];
}

- (void)resetContentOffset:(BOOL)animated
{
    CGSize boundsSize = self.imageScrollView.bounds.size;
    CGRect frameToCenter = self.imageScrollView.zoomView.frame;
    CGPoint contentOffset = self.imageScrollView.contentOffset;
    contentOffset.x = (frameToCenter.size.width - boundsSize.width) / 2.0;
    contentOffset.y = (frameToCenter.size.height - boundsSize.height) / 2.0;
    [self.imageScrollView setContentOffset:contentOffset animated:animated];
}

- (void)displayImage
{
    if (self.originalImage) {
        [self.imageScrollView displayImage:self.originalImage];
        [self resetZoomScale:NO];
    }
}


/**
 裁剪空白区域的frame设置
 
 @return frame
 */
- (CGRect)maskRect
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = (width/_aspectRatioWidth)*_aspectRatioHeight;
    //居中显示
    CGFloat originY=(bounds.size.height-height)/2;
    
    CGRect maskRect = CGRectMake(0, originY, width, height);
    return maskRect;
}

- (CGRect)cropRect
{
    CGRect cropRect = CGRectZero;
    float zoomScale = 1.0 / self.imageScrollView.zoomScale;
    
    cropRect.origin.x = self.imageScrollView.contentOffset.x * zoomScale;
    cropRect.origin.y = self.imageScrollView.contentOffset.y * zoomScale;
    cropRect.size.width = CGRectGetWidth(self.imageScrollView.bounds) * zoomScale;
    cropRect.size.height = CGRectGetHeight(self.imageScrollView.bounds) * zoomScale;
    
    CGSize imageSize = self.originalImage.size;
    CGFloat x = CGRectGetMinX(cropRect);
    CGFloat y = CGRectGetMinY(cropRect);
    CGFloat width = CGRectGetWidth(cropRect);
    CGFloat height = CGRectGetHeight(cropRect);
    
    UIImageOrientation imageOrientation = self.originalImage.imageOrientation;
    if (imageOrientation == UIImageOrientationRight || imageOrientation == UIImageOrientationRightMirrored) {
        cropRect.origin.x = y;
        cropRect.origin.y = imageSize.width - CGRectGetWidth(cropRect) - x;
        cropRect.size.width = height;
        cropRect.size.height = width;
    } else if (imageOrientation == UIImageOrientationLeft || imageOrientation == UIImageOrientationLeftMirrored) {
        cropRect.origin.x = imageSize.height - CGRectGetHeight(cropRect) - y;
        cropRect.origin.y = x;
        cropRect.size.width = height;
        cropRect.size.height = width;
    } else if (imageOrientation == UIImageOrientationDown || imageOrientation == UIImageOrientationDownMirrored) {
        cropRect.origin.x = imageSize.width - CGRectGetWidth(cropRect) - x;;
        cropRect.origin.y = imageSize.height - CGRectGetHeight(cropRect) - y;
    }
    
    return cropRect;
}

- (UIImage *)croppedImage:(UIImage *)image cropRect:(CGRect)cropRect
{
    CGImageRef croppedCGImage = CGImageCreateWithImageInRect(image.CGImage, cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedCGImage scale:1.0f orientation:image.imageOrientation];
    CGImageRelease(croppedCGImage);
    return [croppedImage fixOrientation];
}

- (void)cropImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *croppedImage = [self croppedImage:self.originalImage cropRect:[self cropRect]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(imageCropperViewController:didCropImage:)]) {
                [self.delegate imageCropperViewController:self didCropImage:croppedImage];
            }
        });
    });
}

- (void)confirmBtnClick {
    [self cropImage];
}


-(void)cancelBtnClick
{
    //回退上级VC
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}



#pragma mark - UICollectionViewDelegate

/**
 每组显示的item的个数
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     复用机制
     */
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    UIImage * image = self.images[indexPath.item];
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:image];
    
    return cell;
    
    
    
}


/**
 点击了某个item会调用
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UIImage * image = self.images[indexPath.item];
    self.originalImage = image;
    
    [self displayImage];
}

@end
