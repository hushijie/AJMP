//
//  AJMediaSaveTool.m
//  AJAlbumOperation
//
//  Created by JasonHu on 2017/6/19.
//  Copyright © 2017年 AJ. All rights reserved.
//

#import "AJMediaSaveTool.h"

@implementation AJMediaSaveTool

#pragma mark - 单例创建

static AJMediaSaveTool * _mediaSaveTool = nil;

/**
 单例对象
 */
+ (instancetype)sharedTool
{
    //对象锁,避免多个线程同时访问这个创建多个对象
    @synchronized(self)
    {
        //线程安全的
        if (!_mediaSaveTool)
        {
            //创建单例对象
            _mediaSaveTool = [[AJMediaSaveTool alloc] init];
        }
        
        return _mediaSaveTool;
    }
    
}

/*
 alloc出触发,重写方法的目的:防止通过alloc返回一个新的实例
 */
+ (instancetype) allocWithZone:(struct _NSZone *)zone
{
    if (!_mediaSaveTool)
    {
        //如果当前单例对象不存在，调用父类方法创建
        _mediaSaveTool = [super allocWithZone:zone];
    }
    
    return _mediaSaveTool;
}


#pragma mark - 获取自定义相册（如果没有，则创建）


-(PHAssetCollection *)getAssetCollectionWithAppNameAndCreateIfNo
{
    //1 获取以 APP 的名称 （[NSBundle mainBundle].infoDictionary[(__bridge NSString *)kCFBundleNameKey]）
    //注：kCFBundleNameKey（xcode项目名称） 与 CFBundleDisplayName（手机上的app名称）不同！
    NSString *title = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    //2 获取与 APP 同名的自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collections) {
        //遍历
        if ([collection.localizedTitle isEqualToString:title]) {
            //找到了同名的自定义相册--返回
            return collection;
        }
    }
    
    //说明没有找到，需要创建
    NSError *error = nil;
    __block NSString *createID = nil; //用来获取创建好的相册
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //发起了创建新相册的请求，并拿到ID，当前并没有创建成功，待创建成功后，通过 ID 来获取创建好的自定义相册
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
        createID = request.placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (error) {
        NSLog(@"相册创建失败");
        return nil;
    }else{
        NSLog(@"相册创建成功");
        //通过 ID 获取创建完成的相册 -- 是一个数组
        return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createID] options:nil].firstObject;
    }
    
}



#pragma mark - 相册的授权访问

-(void)getSystemAlbumAuthorizationStatusWithSuccess:(void (^)())success
{
    //(1) 获取当前的授权状态
    PHAuthorizationStatus lastStatus = [PHPhotoLibrary authorizationStatus];
    
    //(2) 请求授权
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        //回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //用户拒绝（可能是之前拒绝的，有可能是刚才在系统弹框中选择的拒绝）
            if(status == PHAuthorizationStatusDenied)
            {
                if (lastStatus == PHAuthorizationStatusNotDetermined) {
                    //说明，用户之前没有做决定，在弹出授权框中，选择了拒绝
                    NSLog(@"资源保存失败");
                    return;
                }
                //说明，之前用户选择拒绝过，现在又点击保存按钮，说明想要使用该功能，需要提示用户打开授权
                NSLog(@"资源保存失败！请在系统设置中开启访问相册权限");
                
            }
            else if(status == PHAuthorizationStatusAuthorized) //用户允许
            {
                
                //用户允许之后的回调
                if (success) {
                    success();
                }
                
            }
            else if (status == PHAuthorizationStatusRestricted)
            {
                NSLog(@"系统原因，无法访问相册");
            }
        });
    }];
}



#pragma mark - 保存图片（同步方式）

/**
 保存图片
 */
-(void)saveImage:(UIImage *)image success:(void (^)(PHAsset * asset))success failure:(void (^)())failure
{
    [self getSystemAlbumAuthorizationStatusWithSuccess:^{
        
        PHAsset * asset=[self saveImageToCustomAblum:image];
        
        if (asset) {
            if (success) {
                success(asset);
            }
        }
        else{
            if (failure) {
                failure();
            }
        }
        
    }];
}


/**
 将图片保存到自定义相册中
 */
-(PHAsset *)saveImageToCustomAblum:(UIImage *)image
{
    //1 将图片保存到系统的【相机胶卷】中
    PHFetchResult<PHAsset *> *assets = [self syncSaveImage:image];
    if (assets == nil)
    {
        NSLog(@"图片保存失败");
        return nil;
    }
    
    //2 拥有自定义相册（与 APP 同名，如果没有则创建）--调用刚才的方法
    PHAssetCollection *assetCollection = [self getAssetCollectionWithAppNameAndCreateIfNo];
    if (assetCollection == nil) {
        NSLog(@"相册创建失败");
        return nil;
    }
    
    
    //3 将刚才保存到相机胶卷的图片添加到自定义相册中 --- 保存带自定义相册--属于增的操作，需要在PHPhotoLibrary的block中进行
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //--告诉系统，要操作哪个相册
        PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        //--添加图片到自定义相册--追加--就不能成为封面了
        //--[collectionChangeRequest addAssets:assets];
        //--插入图片到自定义相册--插入--可以成为封面
        [collectionChangeRequest insertAssets:assets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    
    
    if (error) {
        NSLog(@"图片保存失败");
        return nil;
    }
    
    NSLog(@"图片保存成功");
    return (PHAsset *)[assets lastObject];
}



/**
 异步方式 - 保存图片到系统相册
 (但是保存图片的操作性能消耗不大，所以可以直接使用同步方式)
 */
-(void)asyncSaveImage:(UIImage *)image
{
    //1 必须在 block 中调用
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //2 异步执行保存图片操作
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        //3 保存结束后，回调
        if (error) {
            NSLog(@"图片保存失败");
        }else{
            NSLog(@"图片保存成功");
        }
    }];
}

/**
 同步方式 - 保存图片到系统的相机胶卷中
 （返回的是当前保存成功后相册图片对象集合）
 */
-(PHFetchResult<PHAsset *> *)syncSaveImage:(UIImage *)image
{
    //--1 创建 ID 这个参数可以获取到图片保存后的 asset对象
    __block NSString *createdAssetID = nil;
    
    //--2 保存图片
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        
        //----block 执行的时候还没有保存成功--获取占位图片的 id，通过 id 获取图片---同步
        createdAssetID = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
        
    } error:&error];
    
    //--3 如果失败，则返回空
    if (error) {
        return nil;
    }
    
    //--4 成功后，返回对象
    //获取保存到系统相册成功后的 asset 对象集合，并返回
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetID] options:nil];
    return assets;
    
}



#pragma mark - 将缓存在沙盒中的媒体资源保存到自定义相册（异步方式）

/**
 先保存到相机胶卷、后保存到自定义相册
 */
-(void)saveMediaWithMediaType:(AJMediaSaveType)mediaType fileURL:(NSURL *)fileURL success:(void (^)(PHAsset * asset))success failure:(void (^)())failure
{
    //获取访问权限情况
    [self getSystemAlbumAuthorizationStatusWithSuccess:^{
        
        
        if (mediaType==AJMediaSaveType_Video) {
            
            //用户允许访问，异步保存视频
            [self asyncSaveMediaWithMediaType:mediaType fileURL:fileURL saveSuccess:^(PHFetchResult<PHAsset *> * assets){
                
                if (success) {
                    success((PHAsset *)[assets lastObject]);
                }
                
            } saveFailure:^{
                
                if (failure) {
                    failure();
                }
                
            }];
            
        }
        else if (mediaType==AJMediaSaveType_Image){
            
            //用户允许访问，异步保存图片
            [self asyncSaveMediaWithMediaType:mediaType fileURL:fileURL saveSuccess:^(PHFetchResult<PHAsset *> * assets){
                
                if (success) {
                    success((PHAsset *)[assets lastObject]);
                }
                
            } saveFailure:^{
                
                if (failure) {
                    failure();
                }
                
            }];
            
        }
        
    }];
}




#pragma mark - 保存媒体资源（图片、视频）到自定义相册（异步方式）


-(void)asyncSaveMediaWithMediaType:(AJMediaSaveType)mediaType fileURL:(NSURL *)fileURL saveSuccess:(void (^)(PHFetchResult<PHAsset *> * assets))saveSuccess saveFailure:(void (^)())saveFailure
{
    
    NSURL *url = fileURL;
    
    //标识保存到系统相册中的标识
    __block NSString *localIdentifier;
    
    //获取自定义相册
    PHAssetCollection * assetCollection=[self getAssetCollectionWithAppNameAndCreateIfNo];
    
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        //请求创建一个Asset
        PHAssetChangeRequest * assetRequest = nil;
        
        //图片
        if (mediaType==AJMediaSaveType_Image) {
            
            assetRequest=[PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:url];
        }
        //视频
        else if (mediaType==AJMediaSaveType_Video) {
            
            assetRequest=[PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
        }
        else{
            
        }
        
        if (assetRequest) {
            
            //请求编辑相册
            PHAssetCollectionChangeRequest * collectonRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
            //为Asset创建一个占位符，放到相册编辑请求中
            PHObjectPlaceholder * placeHolder = [assetRequest placeholderForCreatedAsset];
            
            //相册中添加视频
            //[collectonRequest addAssets:@[placeHolder]];//这个方法是插入到相册最后
            [collectonRequest insertAssets:@[placeHolder] atIndexes:[NSIndexSet indexSetWithIndex:0]];
            
            localIdentifier = placeHolder.localIdentifier;
            
        }
        
    } completionHandler:^(BOOL success, NSError *error) {
        
        if (success) {
            
            //图片
            if (mediaType==AJMediaSaveType_Image) {
                NSLog(@"图片保存成功");
            }
            //视频
            else if (mediaType==AJMediaSaveType_Video) {
                NSLog(@"视频保存成功");
            }
            
            if (saveSuccess) {
                //获取保存到系统相册成功后的 asset 对象集合，并返回
                PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil];
                saveSuccess(assets);
            }
            
        }
        else {
            
            NSLog(@"error---%@",error);
            
            //图片
            if (mediaType==AJMediaSaveType_Image) {
                NSLog(@"图片保存失败");
            }
            //视频
            else if (mediaType==AJMediaSaveType_Video) {
                NSLog(@"视频保存失败");
            }
            
            if (saveFailure) {
                saveFailure();
            }
            
        }
        
    }];
    
}


#pragma mark - 保存媒体资源（图片、视频）到自定义相册（同步方式）


-(void)syncSaveMediaWithMediaType:(AJMediaSaveType)mediaType fileURL:(NSURL *)fileURL saveSuccess:(void (^)())saveSuccess saveFailure:(void (^)())saveFailure
{
    NSURL *url = fileURL;
    
    //标识保存到系统相册中的标识
    __block NSString *localIdentifier;
    
    //获取自定义相册
    PHAssetCollection * assetCollection=[self getAssetCollectionWithAppNameAndCreateIfNo];
    
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        
        //请求创建一个Asset
        PHAssetChangeRequest * assetRequest = nil;
        
        //图片
        if (mediaType==AJMediaSaveType_Image) {
            
            assetRequest=[PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:url];
        }
        //视频
        else if (mediaType==AJMediaSaveType_Video) {
            
            assetRequest=[PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
        }
        else{
            
        }
        
        if (assetRequest) {
            
            //请求编辑相册
            PHAssetCollectionChangeRequest * collectonRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
            //为Asset创建一个占位符，放到相册编辑请求中
            PHObjectPlaceholder * placeHolder = [assetRequest placeholderForCreatedAsset];
            
            //相册中添加视频
            //[collectonRequest addAssets:@[placeHolder]];//这个方法是插入到相册最后
            [collectonRequest insertAssets:@[placeHolder] atIndexes:[NSIndexSet indexSetWithIndex:0]];
            
            localIdentifier = placeHolder.localIdentifier;
            
        }
        
    } error:&error];
    
    
    //保存失败
    if (error) {
        
        //图片
        if (mediaType==AJMediaSaveType_Image) {
            NSLog(@"图片保存失败");
        }
        //视频
        else if (mediaType==AJMediaSaveType_Video) {
            NSLog(@"视频保存失败");
        }
        
        if (saveFailure) {
            saveFailure();
        }
        
    }
    //保存成功
    else{
        
        //图片
        if (mediaType==AJMediaSaveType_Image) {
            NSLog(@"图片保存成功");
        }
        //视频
        else if (mediaType==AJMediaSaveType_Video) {
            NSLog(@"视频保存成功");
        }
        
        if (saveSuccess) {
            saveSuccess();
        }
        
    }
    
}

@end
