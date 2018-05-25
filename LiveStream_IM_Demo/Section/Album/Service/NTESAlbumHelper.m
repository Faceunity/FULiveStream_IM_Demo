//
//  NTESAlbumHelper.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/4/24.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESAlbumHelper.h"

@implementation NTESAlbumHelper

#pragma mark - 获取相册所有Asset
+ (NSArray <PHAsset *> *)requestAllAssetsWithAscending:(BOOL)ascending
{
    NSMutableArray <PHAsset *>*assetsTemp = [NSMutableArray array];
    
    //所有智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                          subtype:PHAssetCollectionSubtypeAlbumRegular
                                                                          options:nil];
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL *stop) {
        
        if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumVideos) {
            NSArray<PHAsset *> *assets = [NTESAlbumHelper requestAssetsInCollection:collection ascending:ascending];
            [assetsTemp addObjectsFromArray:assets];
        }
    }];
    
    return assetsTemp;
}

+ (NSArray<PHAsset *> *)requestAssetsInCollection:(PHAssetCollection *)assetCollection
                                        ascending:(BOOL)ascending
{
    NSMutableArray<PHAsset *> *arr = [NSMutableArray array];
    
    PHFetchResult *result = [NTESAlbumHelper fetchAssetsInAssetCollection:assetCollection ascending:ascending];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (((PHAsset *)obj).mediaType == PHAssetMediaTypeVideo) {
            [arr addObject:obj];
        }
    }];
    return arr;
}


+ (PHFetchResult *)fetchAssetsInAssetCollection:(PHAssetCollection *)assetCollection
                                      ascending:(BOOL)ascending
{
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    return result;
}

#pragma mark - 获取PHAsset对应的视频文件的信息
+ (void)requestVideoInfoForAsset:(PHAsset *)asset
                        complete:(void (^)(NSString *name, CGFloat size))complete
{
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset
                                                    options:nil
                                              resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        
        CGFloat fileSize = 0;
        NSString *fileName = nil;
        
        if ([asset isKindOfClass:[AVURLAsset class]])
        {
            AVURLAsset *URLAsset = (AVURLAsset *)asset;
            NSNumber *size;
            [URLAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
            fileSize = [size floatValue] / (1024.0 * 1024.0);
            fileName = [URLAsset.URL.absoluteString lastPathComponent];
        }
        
        if (complete) {
            complete(fileName, fileSize);
        }
    }];
}

#pragma makr - 获取PHAsset对应的视频文件原始名称
+ (NSString *)requestVideoNameForAsset:(PHAsset *)asset
{
    //查找video
        NSArray *assetResources = [PHAssetResource assetResourcesForAsset:asset];
        PHAssetResource *resource = nil;
        for (PHAssetResource *assetRes in assetResources) {
            if (assetRes.type == PHAssetResourceTypePairedVideo ||
                assetRes.type == PHAssetResourceTypeVideo) {
                resource = assetRes;
                break;
            }
        }
        return resource.originalFilename;
}

#pragma mark - 获取PHAsset对应视频的微缩图
+ (void)requestVideoThumbForAsset:(PHAsset *)asset complete:(void (^)(UIImage *thumb))complete
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width / 2;
    CGSize size = CGSizeMake(width, width);
    
    [NTESAlbumHelper requestImageForAsset:asset
                                     size:size
                               resizeMode:PHImageRequestOptionsResizeModeFast
                               completion:^(UIImage *image, NSDictionary *info) {
        if (complete) {
            complete(image);
        }
    }];
}

#pragma mark - 获取PHAsset对应的视频图片
+ (void)requestImageForAsset:(PHAsset *)asset
                        size:(CGSize)size
                  resizeMode:(PHImageRequestOptionsResizeMode)resizeMode
                  completion:(void (^)(UIImage *, NSDictionary *))completion
{
    //请求大图界面，当切换图片时，取消上一张图片的请求，对于iCloud端的图片，可以节省流量
    static PHImageRequestID requestID = -1;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = MIN([[UIScreen mainScreen] bounds].size.width, 500);
    if (requestID >= 1 && size.width/width==scale) {
        [[PHCachingImageManager defaultManager] cancelImageRequest:requestID];
    }
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    /**
     resizeMode：对请求的图像怎样缩放。有三种选择：None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
     deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
     这个属性只有在 synchronous 为 true 时有效。
     */
    
    option.resizeMode = resizeMode;//控制照片尺寸
    //option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;//控制照片质量
    option.networkAccessAllowed = YES;
    
    /*
     info字典提供请求状态信息:
     PHImageResultIsInCloudKey：图像是否必须从iCloud请求
     PHImageResultIsDegradedKey：当前UIImage是否是低质量的，这个可以实现给用户先显示一个预览图
     PHImageResultRequestIDKey和PHImageCancelledKey：请求ID以及请求是否已经被取消
     PHImageErrorKey：如果没有图像，字典内的错误信息
     */
    
    requestID = [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        BOOL
        
        downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
        //BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey];
        //不要该判断，即如果该图片在iCloud上时候，会先显示一张模糊的预览图，待加载完毕后会显示高清图
        // && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]
        if (downloadFinined && completion) {
            completion(image, info);
        }
    }];
}

@end
