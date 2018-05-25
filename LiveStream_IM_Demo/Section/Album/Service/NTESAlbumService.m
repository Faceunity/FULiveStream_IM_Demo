//
//  NTESAlbumService.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/4/24.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESAlbumService.h"
#import "NTESAlbumHelper.h"
#import <pthread.h>

@interface NTESAlbumService ()<NSStreamDelegate>
{
    pthread_mutex_t _cache_lock;
}
@property (nonatomic, strong) NSMutableDictionary *assetDic;
@property (nonatomic, strong) dispatch_queue_t loadAlbumQueue;

@property (nonatomic, strong) dispatch_queue_t writeAlbumQueue;
@property (nonatomic, strong) NSFileHandle *handle;
@property (nonatomic, copy) NTESAlbumCacheCancelBlock cancelCache;
@property (nonatomic, copy) NTESAlbumCacheCompleteBlock completeCache;
@property (nonatomic, copy) NSString *dstFilePath;

@end

@implementation NTESAlbumService

+ (instancetype)shareInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NTESAlbumService new];
    });
    
    return instance;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _assetDic = [NSMutableDictionary dictionary];
        _loadAlbumQueue = dispatch_queue_create("ntes.load.album.queue", NULL);
        _writeAlbumQueue = dispatch_queue_create("ntes.load.album.queue", NULL);
        pthread_mutex_init(&_cache_lock, NULL);
    }
    return self;
}

#pragma mark - 查询相册
- (void)videoGroupsWithAscending:(BOOL)ascending
                 withMinDuration:(CGFloat)duration
                        complete:(NTESAlbumQueryCompleteBlock)complete
{
    __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    WEAK_SELF(weakSelf);
    __block NSString *lastDateStr = nil;
    NSMutableArray <NTESAlbumGroupEntity *>*groups = [NSMutableArray array];
    
    dispatch_async(_loadAlbumQueue, ^{
        
        NSArray *assets = [NTESAlbumHelper requestAllAssetsWithAscending:ascending];
        
        //清空asset缓存
        [weakSelf.assetDic removeAllObjects];
        
        //分组
        [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //获取videoItem
            [weakSelf videoItemWithAsset:obj index:idx complete:^(NTESAlbumVideoEntity *item) {
                
                //缓存asset
                if (item.duration >= duration && item.title && item.assetKey)
                {
                    [weakSelf.assetDic setObject:obj forKey:item.assetKey];
                    
                    NSString *curDateStr = [obj.creationDate stringWithFormat:@"yyyy.MM"];
                    
                    //分组归类
                    if (![curDateStr isEqualToString:lastDateStr]) //换时间了
                    {
                        __block BOOL isExist = NO;
                        [groups enumerateObjectsUsingBlock:^(NTESAlbumGroupEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ([obj.dateStr isEqualToString:curDateStr]) {
                                isExist = YES;
                                [obj.items addObject:item];
                                *stop = YES;
                            }
                        }];
                        
                        if (isExist == NO) {
                            NTESAlbumGroupEntity *group = [NTESAlbumGroupEntity new];
                            group.dateStr = curDateStr;
                            [group.items addObject:item];
                            [groups addObject:group];
                        }
                    }
                    else
                    {
                        NTESAlbumGroupEntity *group = [groups lastObject];
                        [group.items addObject:item];
                    }
                    lastDateStr = curDateStr;
                }
                else
                {
                    NSLog(@"[NTESDemo] 相册 － asset - 视频没有名字，放弃添加");
                }
                
                dispatch_semaphore_signal(sem);
            }];
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(groups);
            }
        });
    });
}

//获取NTESAlbumVideoEntity
- (void)videoItemWithAsset:(PHAsset *)asset
                     index:(NSInteger)index
                  complete:(void (^)(NTESAlbumVideoEntity *item))complete
{
    dispatch_group_t group = dispatch_group_create();
    NTESAlbumVideoEntity *item = [NTESAlbumVideoEntity new];
    
    //获取微缩图
    dispatch_group_enter(group);
    [NTESAlbumHelper requestVideoThumbForAsset:asset complete:^(UIImage *thumb) {
        item.thumbImg = thumb;
        dispatch_group_leave(group);
    }];
    
    //获取视频信息
    dispatch_group_enter(group);
    [NTESAlbumHelper requestVideoInfoForAsset:asset complete:^(NSString *name, CGFloat size) {
        
        item.title = name;
        item.size = size;
        item.assetKey = name;
        dispatch_group_leave(group);
    }];

    //获取视频时长
    item.duration = round(asset.duration);
    
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        if (complete) {
            complete(item);
        }
    });
}

- (void)addPhotoWithComplete:(void (^)(NSError *))complete {
    //首先获取相册的集合
    PHFetchResult *collectonResuts = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:[PHFetchOptions new]] ;
    //对获取到集合进行遍历
    [collectonResuts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PHAssetCollection *assetCollection = obj;
        //Camera Roll是我们写入照片的相册
        if ([assetCollection.localizedTitle isEqualToString:@"Camera Roll"])  {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                //请求创建一个Asset
                PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:[UIImage imageNamed:@"pet"]];
                //请求编辑相册
                PHAssetCollectionChangeRequest *collectonRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                //为Asset创建一个占位符，放到相册编辑请求中
                PHObjectPlaceholder *placeHolder = [assetRequest placeholderForCreatedAsset ];
                //相册中添加照片
                [collectonRequest addAssets:@[placeHolder]];
            } completionHandler:^(BOOL success, NSError *error) {
                NSLog(@"Error:%@", error);
            }];
        }
    }];
}

#pragma mark - 删除assetKey对应的视频
- (void)deleLastVideoWithCompletion:(void(^)(BOOL success))completion
                            failure:(void(^)(NSError *error))failure {
    PHFetchResult *collectonResuts = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:[PHFetchOptions new]] ;
    [collectonResuts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PHAssetCollection *assetCollection = obj;
        if ([assetCollection.localizedTitle isEqualToString:@"Videos"] || [assetCollection.localizedTitle isEqualToString:@"视频"])  {
            PHFetchResult *assetResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:[PHFetchOptions new]];
            [assetResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    //获取相册的最后一张照片
                    if (idx == [assetResult count] - 1) {
                        [PHAssetChangeRequest deleteAssets:@[obj]];
                    }
                } completionHandler:^(BOOL success, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (completion) {
                            if (success) {
                                completion(YES);
                            }else {
                                completion(NO);
                            }
                        }
                        
                        if (error && failure) {
                            failure(error);
                        }
                    });
                }];
            }];
        }
    }];
}

#pragma mark - 添加视频模块缓存视频
- (void)cacheVideoWithAlbumVideoKey:(NSString *)assetKey
                           complete:(void (^)(NSError *error, NSString *filePath))complete
{
    
    PHAsset *asset = [_assetDic objectForKey:assetKey];
    
    if (!asset) {
        if (complete) {
            NSError *error = [NSError errorWithDomain:@"ntes.album.cache"
                                                 code:0x1001
                                             userInfo:@{NTES_ERROR_MSG_KEY : @"未找到Asset"}];
            complete(error, nil);
        }
        return;
    }

    NSString *title = [NTESAlbumHelper requestVideoNameForAsset:asset];
    if (!title) {//iOS9+ API防止错误
        title = @"selectReSource.MOV";
    }

    if (asset.mediaType == PHAssetResourceTypeVideo) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.networkAccessAllowed = NO;
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        
        //使用iOS 8 API 保证兼容性
        PHImageManager *manager = [PHImageManager defaultManager];
        
        [manager requestExportSessionForVideo:asset
                                      options:options
                                 exportPreset:AVAssetExportPresetMediumQuality
                                resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
                                    //获取文件路径
                                    NSString *dateStr = [[NSDate date] stringWithFormat:@"yyyyMMddHHmmss"];
                                    NSString *tempName = [NSString stringWithFormat:@"%@_%@", dateStr, title];
                                    NSString *dir = [[NTESSandboxHelper videoCachePath] stringByAppendingPathComponent:tempName];
                                    
                                    exportSession.outputURL = [NSURL fileURLWithPath:dir];
                                    exportSession.shouldOptimizeForNetworkUse = NO;
                                    exportSession.outputFileType = AVFileTypeMPEG4;
                                    
                                    [exportSession exportAsynchronouslyWithCompletionHandler:^{
                                        switch ([exportSession status]) {
                                            case AVAssetExportSessionStatusFailed:
                                            {
                                                if (complete) {
                                                    complete(exportSession.error, nil);
                                                }
                                            }
                                                break;
                                            case AVAssetExportSessionStatusCompleted:
                                            {
                                                if (complete) {
                                                    complete(nil, dir);
                                                }
                                            }
                                                break;
                                            default:
                                                break;
                                        }
                                    }];
                                }];
        
    }
    else {
        if (complete) {
            NSError *error = [NSError errorWithDomain:@"ntes.album.cache"
                                                 code:0x1002
                                             userInfo:@{NTES_ERROR_MSG_KEY : @"不是视频资源"}];
            complete(error, nil);
        }
    }
    
}

#pragma mark - 上传视频模块缓存视频
- (void)cacheVideoWithAlbumVideoKey:(NSString *)assetKey
                             cancel:(NTESAlbumCacheCancelBlock)cancel
                           complete:(NTESAlbumCacheCompleteBlock)complete
{
    pthread_mutex_lock(&_cache_lock);
    
    PHAsset *asset = [_assetDic objectForKey:assetKey];
    
    if (!asset)
    {
        if (complete) {
            NSError *error = [NSError errorWithDomain:@"ntes.album.cache"
                                                 code:0x1001
                                             userInfo:@{NTES_ERROR_MSG_KEY : @"未找到Asset"}];
            complete(error, nil);
        }
        
        pthread_mutex_unlock(&_cache_lock);
        return;
    }
    
    NSString *title = [NTESAlbumHelper requestVideoNameForAsset:asset];
    
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHImageRequestOptionsVersionCurrent;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    PHImageManager *manager = [PHImageManager defaultManager];
    WEAK_SELF(weakSelf);
    [manager requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable avasset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info){
        
        AVURLAsset *urlAsset = (AVURLAsset *)avasset;
        
        //获取文件路径
        NSString *dateStr = [[NSDate date] stringWithFormat:@"yyyyMMddHHmmss"];
        NSString *tempName = [NSString stringWithFormat:@"%@_%@", dateStr, title];
        NSString *dir = [[NTESSandboxHelper videoCachePath] stringByAppendingPathComponent:tempName];
        
        //获取文件路径
        [weakSelf cacheFile:urlAsset.URL dst:dir cancel:cancel complete:complete];
    }];
}

- (void)cacheFile:(NSURL *)url
              dst:(NSString *)dstPath
           cancel:(NTESAlbumCacheCancelBlock)cancel
         complete:(NTESAlbumCacheCompleteBlock)complete
{
    _cancelCache = cancel;
    _completeCache = complete;
    
    _dstFilePath = dstPath;
    
    [[NSFileManager defaultManager] createFileAtPath:dstPath contents:nil attributes:nil];
    _handle = [NSFileHandle fileHandleForWritingAtPath:dstPath];
    
    NSInputStream *readStream = [[NSInputStream alloc] initWithURL:url];
    [readStream setDelegate:self];
    [readStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [readStream open];
    [[NSRunLoop currentRunLoop] run];
}

#pragma mark - <NSStreamDelegate>
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    BOOL isError = NO;
    switch (eventCode)
    {
        case NSStreamEventHasBytesAvailable: // 读
        {
            int BufferSize=1024*512;
            uint8_t *buffer = calloc(BufferSize, sizeof(*buffer));
            NSInputStream *reads = (NSInputStream *)aStream;
            NSInteger blength = [reads read:buffer maxLength:BufferSize];
            if (blength != 0)
            {
                [_handle writeData:[NSData dataWithBytesNoCopy:buffer length:blength freeWhenDone:YES]];
            }
            else
            {
                [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
                [aStream close];
                [_handle closeFile];
                _handle = nil;
                free(buffer);
                NSLog(@"[NTESDemo] 相册服务 - 缓存 - 完成");
                
                NSString *relPath = _dstFilePath.lastPathComponent;
                if (_completeCache) {
                    _completeCache(nil, relPath);
                }
                pthread_mutex_unlock(&_cache_lock);
            }
            break;
        }
        case NSStreamEventErrorOccurred:
        case NSStreamEventEndEncountered: // 错误处理
        {
            NSLog(@"错误处理");
            isError = YES;
            break;
            
        }
        case NSStreamEventOpenCompleted: // 打开完成
        {
            NSLog(@"[NTESDemo] 相册服务 - 缓存 - 打开文件");
            break;
        }
        case NSStreamEventNone: // 无事件处理
        case NSStreamEventHasSpaceAvailable: // 写
        default:
            break;
    }
    
    //处理
    if (isError)
    {
        [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [aStream close];
        [_handle closeFile];
        _handle = nil;
        
        NSError * error = [NSError errorWithDomain:@"ntes.album.cache"
                                              code:0x1002
                                          userInfo:@{NTES_ERROR_MSG_KEY : @"缓存出错了"}];
        
        [[NSFileManager defaultManager] removeItemAtPath:_dstFilePath error:nil];
        
        if (_completeCache) {
            _completeCache(error, nil);
        }
        
        pthread_mutex_unlock(&_cache_lock);
        
    }
    else if (_cancelCache && _cancelCache() == YES) //取消了
    {
        [aStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [aStream close];
        [_handle closeFile];
        _handle = nil;
        
        [[NSFileManager defaultManager] removeItemAtPath:_dstFilePath error:nil];
        
        NSLog(@"[NTESDemo] 相册服务 - 缓存 - 取消");
        
        if (_completeCache) {
            _completeCache(nil, nil);
        }
        
        pthread_mutex_unlock(&_cache_lock);
    }
}

@end
