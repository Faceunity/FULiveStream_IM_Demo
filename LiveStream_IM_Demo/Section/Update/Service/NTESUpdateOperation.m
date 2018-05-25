//
//  NTESUpdateOperation.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/3/8.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESUpdateOperation.h"
#import "NTESDaoService+Update.h"
#import "NTESAlbumService.h"
#import "NTESVideoEntity.h"
#import "NTESUpdateDelegate.h"

typedef NS_ENUM(NSInteger, NTESOperationState) {
    NTESOperationReadyState       = 1,
    NTESOperationExecutingState   = 2,
    NTESOperationFinishedState    = 3,
};

static NSString * const kNTESUpdateLockName = @"ntes.update.operation.lock";

static inline NSString * NTESKeyPathFromOperationState(NTESOperationState state) {
    switch (state) {
        case NTESOperationReadyState:
            return @"isReady";
        case NTESOperationExecutingState:
            return @"isExecuting";
        case NTESOperationFinishedState:
            return @"isFinished";
        default: {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
            return @"state";
#pragma clang diagnostic pop
        }
    }
}

static inline BOOL NTESStateTransitionIsValid(NTESOperationState fromState, NTESOperationState toState, BOOL isCancelled) {
    switch (fromState) {
        case NTESOperationReadyState:
            switch (toState) {
                case NTESOperationExecutingState:
                    return YES;
                case NTESOperationFinishedState:
                    return isCancelled;
                default:
                    return NO;
            }
        case NTESOperationExecutingState:
            switch (toState) {
                case NTESOperationFinishedState:
                    return YES;
                default:
                    return NO;
            }
        case NTESOperationFinishedState:
            return NO;

        default: {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
            switch (toState) {
                case NTESOperationReadyState:
                case NTESOperationExecutingState:
                case NTESOperationFinishedState:
                    return YES;
                default:
                    return NO;
            }
        }
#pragma clang diagnostic pop
    }
}

@interface NTESUpdateOperation ()

@property (nonatomic, strong) NSSet *runLoopModes;
@property (readwrite, nonatomic, assign) NTESOperationState state;
@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;

@property (nonatomic, assign) NSInteger interTransjobstatus; //当前的转码状态
@property (nonatomic, assign) NSInteger interVideoCount; //当前已上传的视频数量

@property (nonatomic, assign) BOOL cancelCache;  //取消缓存
@property (nonatomic, assign) BOOL cancelUpdate; //取消上传
@property (nonatomic, strong) NOSUploadManager *upManager;

@end

@implementation NTESUpdateOperation

#pragma mark - Life
- (void)dealloc
{
    _delegate = nil;
    
    NSLog(@"[NTESUpdateTask] 释放");
}

- (instancetype)init NS_UNAVAILABLE
{
    return nil;
}

- (NSString *)description
{
    [self.lock lock];
    NSString *description = [NSString stringWithFormat:@"<%@: %p, state: %@, cancelled: %@>",
                             NSStringFromClass([self class]),
                             self,
                             NTESKeyPathFromOperationState(self.state),
                             ([self isCancelled] ? @"YES" : @"NO")];
    [self.lock unlock];
    return description;
}

#pragma mark - Public
- (instancetype)initWithItem:(NTESVideoEntity *)item type:(NTESUpdateType)type
{
    if (item == nil) {
        return nil;
    }
    
    if (self = [super init])
    {
        _item = item;
        _type = type;
        

        
        _state = NTESOperationReadyState;
        _cancelUpdate = NO;
        
        self.lock = [[NSRecursiveLock alloc] init];
        self.lock.name = kNTESUpdateLockName;
        
        self.runLoopModes = [NSSet setWithObject:NSRunLoopCommonModes];
        
        self.upManager = [self doInitUploader];
    }
    return self;
}

#pragma mark - Opertaion Handle (Main Thread)
- (void)startHandle
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(updateOperationDidStart:)]) {
            [_delegate updateOperationDidStart:self];
        }
    });
}

- (void)cancelHandle
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(updateOperationDidCancel:)]) {
            [_delegate updateOperationDidCancel:self];
        }
        [self finish];
    });
}

- (void)completeHandle:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(updateOperationDidComplete:error:vid:)]) {
            [_delegate updateOperationDidComplete:self error:error vid:_item.vid];
        }
        [self finish];
    });
}

- (void)phaseChangeHandle
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(updateOperationStateDidChanged:toPhase:)]) {
            [_delegate updateOperationStateDidChanged:self toPhase:_item.updatePhase];
        }
    });
};

- (void)processHandle:(CGFloat)process
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_delegate && [_delegate respondsToSelector:@selector(updateOperationProcess:process:)]) {
            [_delegate updateOperationProcess:self process:process];
        }
    });
}

#pragma mark - Operation Work (Update Thread)
//初始化上传管理类
- (NOSUploadManager *)doInitUploader
{
    NOSUploadManager *upManger = nil;
    NSError *error = nil;
    NSString *dir = [NSTemporaryDirectory() stringByAppendingString:@"nos-ios-sdk-test"];
    
    //创建断点续传目录并记录
    NOSFileRecorder *file = [NOSFileRecorder fileRecorderWithFolder:dir error:&error];
    if (error) {
        NSLog(@"[NTESDemo] 上传 - 初始化上传类 - 失败。[%@]", error);
    }
    
    //配置块大小
    UInt32 chunkSize = 32 * 1024;
    if ([RealReachability sharedInstance].currentReachabilityStatus == RealStatusViaWWAN)
    {
        chunkSize = 8 * 1024;
    }
    
    //配置基于位置服务的参数
    NOSConfig *conf = [[NOSConfig alloc] initWithLbsHost: @"http://wanproxy.127.net"
                                           withSoTimeout: 30
                                     withRefreshInterval: 2 * 60 * 60
                                           withChunkSize: chunkSize
                                     withMoniterInterval: 120
                                          withRetryCount: 2];
    //将其设置为全局变量
    [NOSUploadManager setGlobalConf:conf];
    
    //实例化上传管理类
    upManger = [NOSUploadManager sharedInstanceWithRecorder: (id<NOSRecorderDelegate>)file
                                       recorderKeyGenerator: nil];
    //设置上传管理类的delegate
    upManger.delegate = [NTESUpdateDelegate shareInstance];
    
    return upManger;
}

//缓存视频文件
- (void)doCacheVideoWithRelPath:(NSString *)relPath
{
    _item.updatePhase = NTESOperationCachingProcess;
    NSString *path = nil;

    //阶段切换回调
    [self phaseChangeHandle];
    
    //已经取消了，直接结束
    if ([self isCancelled])
    {
        [self cancelHandle];
        return;
    }
    
    //已经缓存了，进行下一步
    if (relPath)
    {
        path = [[NTESSandboxHelper videoCachePath] stringByAppendingPathComponent:relPath];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            [self doInitFileWithRelPath:relPath];
            return;
        }
    }
    
    //取消回调
    __weak typeof(self) weakSelf = self;
    NTESAlbumCacheCancelBlock cancel = ^(){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        return strongSelf.cancelCache;
    };
    
    //成功回调
    NTESAlbumCacheCompleteBlock complete = ^(NSError *error, NSString *relPath){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if ([strongSelf isCancelled]) //主动取消
        {
            NSLog(@"[NTESDemo] 上传 - 缓存 - 取消.");
            
            [strongSelf cancelHandle];
        }
        else
        {
            if (!relPath)
            {
                NSLog(@"[NTESDemo] 上传 - 缓存 - 失败.[%@]", error);
                NSError *error = [NSError errorWithDomain:@"ntes.demo.update.cache"
                                                     code:1001
                                                 userInfo:@{NTES_ERROR_MSG_KEY : @"缓存失败"}];
                [strongSelf completeHandle:error];
            }
            else
            {
                NSLog(@"[NTESDemo] 上传 - 缓存 - 成功.");
                
                //保存数据
                strongSelf.item.fileRelPath = relPath;
                
                [strongSelf performSelector:@selector(doInitFileWithRelPath:)
                                   onThread:[[strongSelf class] updateRequestThread]
                                 withObject:relPath
                              waitUntilDone:NO
                                      modes:[strongSelf.runLoopModes allObjects]];
                
            }
        }
    };
    
    //开始缓存
    [[NTESAlbumService shareInstance] cacheVideoWithAlbumVideoKey:_item.assetKey
                                                           cancel:cancel
                                                         complete:complete];
}

//上传文件初始化
- (void)doInitFileWithRelPath:(NSString *)relPath
{
    _item.updatePhase = NTESOperationFileInitingProcess;

    //阶段切换回调
    [self phaseChangeHandle];
    
    //已经取消了，直接结束
    if ([self isCancelled])
    {
        [self cancelHandle];
        return;
    }
    
    //参数检查
    if (!relPath)
    {
        NSLog(@"[NTESDemo] 上传 - 初始化文件 - 参数不合法");
        NSError *error = [NSError errorWithDomain:@"ntes.demo.update.fileinit"
                                             code:1000
                                         userInfo:@{NTES_ERROR_MSG_KEY : @"初始化文件参数不合法"}];
        [self completeHandle:error];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    //文件初始化成功回调
    NOSUploadRequestSuccess success = ^(id responseObject) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSInteger code = [[responseObject objectForKey:@"code"] integerValue];
        NSString *msg = responseObject[@"msg"];
        if (code == 200)
        {
            NSLog(@"[NTESDemo] 上传 - 初始化文件 - 成功");
            strongSelf.item.nosObject = strongSelf.upManager.objectName;
            strongSelf.item.nosBucket = strongSelf.upManager.bucketName;
            strongSelf.item.nosToken = strongSelf.upManager.xNosToken;
            
            [strongSelf performSelector:@selector(doUpdateFileWithRelPath:)
                               onThread:[[strongSelf class] updateRequestThread]
                             withObject:relPath
                          waitUntilDone:NO
                                  modes:[strongSelf.runLoopModes allObjects]];
        }
        else
        {
            NSLog(@"[NTESDemo] 上传 - 初始化文件 - 失败");
            msg = (msg ?: @"上传初始化失败");
            if ([strongSelf isCancelled])
            {
                [weakSelf cancelHandle];
            }
            else
            {
                NSError *error = [NSError errorWithDomain:@"ntes.demo.update.fileinit"
                                                     code:code
                                                 userInfo:@{NTES_ERROR_MSG_KEY : msg}];
                
                [weakSelf completeHandle:error];
            }
        }
    };
    
    //文件初始化失败回调
    NOSUploadRequestFail fail = ^(NSError *error) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        NSLog(@"[NTESDemo] 上传 - 初始化文件 - 失败");
        
        if ([strongSelf isCancelled])
        {
            [strongSelf cancelHandle];
        }
        else
        {
            [strongSelf completeHandle:error];
        }
    };
    
    //文件初始化
    NSString *uploadCallbackUrl = [NSString stringWithFormat:@"%@/vod/uploadcallback", [NTESDemoConfig sharedConfig].apiURL];
    NSString *transcodeCallbackUrl = [NSString stringWithFormat:@"%@/vod/transcodecallback", [NTESDemoConfig sharedConfig].apiURL];
    
    //文件名称
    NSString *initName = relPath.lastPathComponent;
    if (_item.title && _item.extension) {
        initName = [_item.title stringByAppendingPathExtension:_item.extension];
    }
    
    [_upManager fileUploadInit:initName
                  userFileName:nil
                        typeId:nil
                      presetId:nil
             uploadCallbackUrl:uploadCallbackUrl
                   callbackUrl:transcodeCallbackUrl
                   description:nil
                   watermarkId:nil
                   userDefInfo:nil
                       success:success
                          fail:fail];
}

//上传文件到nos服务器
- (void)doUpdateFileWithRelPath:(NSString *)relPath
{
    NSString *bucket = _item.nosBucket;
    NSString *object = _item.nosObject;
    NSString *token = _item.nosToken;
    NSString *type =  @"application/octet-stream";
    
    _item.updatePhase = NTESOperationFileUpdatingProcess;
    
    //阶段切换回调
    [self phaseChangeHandle];
    
    //取消
    if ([self isCancelled])
    {
        [self cancelHandle];
        return;
    }
    
    //参数检查
    if (!relPath)
    {
        NSLog(@"[NTESDemo] 上传 - 上传 - 参数不合法");
        NSError *error = [NSError errorWithDomain:@"ntes.demo.update.query"
                                             code:1003
                                         userInfo:@{NTES_ERROR_MSG_KEY : @"上传参数不合法"}];
        [self completeHandle:error];
        return;
    }
    

    __weak typeof(self) weakSelf = self;
    //进度
    NOSUpProgressHandler process = ^(NSString *key, float percent){
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf processHandle:percent];
    };
    
    //取消
    NOSUpCancellationSignal cancel = ^BOOL(){
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        return strongSelf.cancelUpdate;
    };
    
    //上传完成
    NOSUpCompletionHandler complete = ^(NOSResponseInfo *info, NSString *key, NSDictionary *resp) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if ([strongSelf isCancelled]) //主动取消
        {
            NSLog(@"[NTESDemo] 上传 - 上传 - 取消.");
            [strongSelf cancelHandle];
        }
        else
        {
            if (resp == nil) //上传失败
            {
                NSLog(@"[NTESDemo] 上传 - 上传 - 失败.[%@]", info);
                NSError *error = [NSError errorWithDomain:@"ntes.demo.update"
                                                     code:1003
                                                 userInfo:@{NTES_ERROR_MSG_KEY : @"上传失败"}];
                [strongSelf completeHandle:error];
            }
            else //上传成功
            {
                NSLog(@"[NTESDemo] 上传 - 上传 - 成功.");
                
                //查询
                [strongSelf performSelector:@selector(doQueryVideoInfo:)
                                   onThread:[[strongSelf class] updateRequestThread]
                                 withObject:object
                              waitUntilDone:NO
                                      modes:[strongSelf.runLoopModes allObjects]];
                
            }
        }
    };
    
    //设置回调
    NOSUploadOption *option = [[NOSUploadOption alloc] initWithMime:type
                                                    progressHandler:process
                                                              metas:nil
                                                 cancellationSignal:cancel];
    
    NSString *filePath = [[NTESSandboxHelper videoCachePath] stringByAppendingPathComponent:relPath];
    
    //上传
    [_upManager putFileByHttps:filePath
                        bucket:bucket
                           key:object
                         token:token
                      complete:complete
                        option:option];
}

//从nos服务器查询视频信息
- (void)doQueryVideoInfo:(NSString *)nosObject
{
    _item.updatePhase = NTESOperationFileQueryingProcess;
    
    //阶段切换回调
    [self phaseChangeHandle];
    
    //取消
    if ([self isCancelled])
    {
        [self cancelHandle];
        return;
    }
    
    //参数检查
    if (!nosObject)
    {
        NSLog(@"[NTESDemo] 上传 - 查询vid - 参数不合法.");
        NSError *error = [NSError errorWithDomain:@"ntes.demo.update.query"
                                             code:1004
                                         userInfo:@{NTES_ERROR_MSG_KEY : @"查询vid参数不合法"}];
        [self completeHandle:error];
        return;
    }
    
    //查询成功
    __weak typeof(self) weakSelf = self;
    NOSUploadRequestSuccess success = ^(id responseObject) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        //NSLog(@"%@", responseObject);
        NSInteger code = [responseObject[@"code"] integerValue];
        if (code == 200) //查询成功
        {
            NSLog(@"[NTESDemo] 上传 - 查询vid - 成功.");
            NSDictionary *dic = responseObject[@"ret"];
            NSArray *list = dic[@"list"];
            for (NSDictionary *item in list) {
                if ([item[@"objectName"] isEqualToString:weakSelf.item.nosObject])
                {
                    strongSelf.item.vid = [NSString stringWithFormat:@"%@", item[@"vid"]];
                    break;
                }
            }
            
            if (strongSelf.item.vid) //开始上报服务
            {
                [strongSelf performSelector:@selector(doReportAddVideoToServer)
                                   onThread:[[strongSelf class] updateRequestThread]
                                 withObject:nil
                              waitUntilDone:NO
                                      modes:[strongSelf.runLoopModes allObjects]];
            }
            else
            {
                NSLog(@"[NTESDemo] 上传 - 查询vid - 未查询到vid.");
                if ([strongSelf isCancelled])
                {
                    [strongSelf cancelHandle];
                }
                else
                {
                    NSError *error = [NSError errorWithDomain:@"ntes.demo.update.query"
                                                         code:code
                                                     userInfo:@{NTES_ERROR_MSG_KEY : @"未查到vid"}];
                    [strongSelf completeHandle:error];
                }
            }
        }
        else //查询失败
        {
            NSLog(@"[NTESDemo] 上传 - 查询vid - 失败[%zi].", code);
            if ([strongSelf isCancelled])
            {
                [strongSelf cancelHandle];
            }
            else
            {
                NSError *error = [NSError errorWithDomain:@"ntes.demo.update.query"
                                                     code:code
                                                 userInfo:@{NTES_ERROR_MSG_KEY : @"查询vid失败"}];
                [strongSelf completeHandle:error];
            }
        }
    };
    
    //查询失败
    NOSUploadRequestFail fail = ^(NSError *error){
    
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSLog(@"[NTESDemo] 上传 - 查询vid - 失败[%@].", error);
        if ([strongSelf isCancelled])
        {
            [strongSelf cancelHandle];
        }
        else
        {
            [strongSelf completeHandle:error];
        }
    };
    
    //查询
    [self.upManager videoQuery:[NSArray arrayWithObjects:nosObject, nil] success:success fail:fail];
}

//上报应用服务器添加视频信息
- (void)doReportAddVideoToServer
{
    _item.updatePhase = NTESOperationFileReporingProcess;
    
    //阶段切换回调
    [self phaseChangeHandle];
    
    //取消
    if ([self isCancelled])
    {
        [self cancelHandle];
        return;
    }
    
    //参数检查
    NSString *path = _item.nosBucket;
    NSString *vid = _item.vid;
    if (!path || !vid) {
        NSLog(@"[NTESDemo] 上传 - 上报服务器 - 参数不合法.");
        NSError *error = [NSError errorWithDomain:@"ntes.demo.update.report"
                                             code:1000
                                         userInfo:@{NTES_ERROR_MSG_KEY : @"上报服务器参数不合法"}];
        [self completeHandle:error];
        return;
    }
    
    //上报
    __weak typeof(self) weakSelf = self;
    NSString *name = [path lastPathComponent];
    [[NTESDaoService sharedService] requestAddVideoWithName:name
                                                        vid:vid
                                                       type:_type
                                                 completion:^(NSError *error, NSInteger transjobstatus, NSInteger videoCount, NTESVideoEntity *info) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        //error.code = 1643 表示服务器已经存在该vid了，这里算上传成功
        
        if (error && error.code != 1643) //失败了
        {
            if ([strongSelf isCancelled]) //取消了
            {
                NSLog(@"[NTESDemo] 上传 - 上报服务器 - 取消.");
                [strongSelf cancelHandle];
            }
            else
            {
                NSLog(@"[NTESDemo] 上传 - 上报服务器 - 失败[%@].", error);
                
                [strongSelf completeHandle:error];
            }
        }
        else
        {
            NSLog(@"[NTESDemo] 上传 - 上报服务器 - 成功.");
            [strongSelf.item copyFromItem:info];
            strongSelf.interTransjobstatus = transjobstatus;
            strongSelf.interVideoCount = videoCount;
            strongSelf.item.updatePhase = NTESOperationFileCompleteProcess;
            
            //阶段切换回调
            [self phaseChangeHandle];
            
            if ([strongSelf isCancelled])
            {
                [strongSelf cancelHandle];
            }
            else
            {
                [strongSelf completeHandle:nil];
            }
        }
    }];
}

#pragma mark - NSOperation_Real Operation
//结束任务
- (void)operationDidFinish
{
    [self.lock lock];
    self.state = NTESOperationFinishedState;
    [self.lock unlock];
}

//取消任务
- (void)operationDidCancel
{
    _cancelCache = YES;
    _cancelUpdate = YES;
}

//开始任务
- (void)operationDidStart
{
    [self.lock lock];
    
    if (![self isCancelled])
    {
        self.state = NTESOperationExecutingState;
        
        //开始回调
        [self startHandle];
        
        //开始
        switch (_item.updatePhase)
        {
            case NTESOperationReadyProcess:
            case NTESOperationCachingProcess:
            {
                [self doCacheVideoWithRelPath:_item.fileRelPath];
                break;
            }
            case NTESOperationFileInitingProcess:
            {
                if (!_item.fileRelPath) //不存在文件路径
                {
                    [self doCacheVideoWithRelPath:_item.fileRelPath];
                }
                else
                {
                    NSString *path = [[NTESSandboxHelper videoCachePath] stringByAppendingPathComponent:_item.fileRelPath];
                    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) //不存在文件
                    {
                        [self doCacheVideoWithRelPath:_item.fileRelPath];
                    }
                    else //一切正常
                    {
                        [self doInitFileWithRelPath:_item.fileRelPath];
                    }
                }
                break;
            }
            case NTESOperationFileUpdatingProcess:
            {
                if (!_item.fileRelPath) //不存在文件路径
                {
                    [self doCacheVideoWithRelPath:_item.fileRelPath];
                }
                else
                {
                    NSString *path = [[NTESSandboxHelper videoCachePath] stringByAppendingPathComponent:_item.fileRelPath];
                    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) //不存在文件
                    {
                        [self doCacheVideoWithRelPath:_item.fileRelPath];
                    }
                    else
                    {
                        if (_item.nosBucket && _item.nosObject && _item.nosToken) //一切正常
                        {
                            [self doUpdateFileWithRelPath:_item.fileRelPath];
                        }
                        else //桶名、对象、token不全
                        {
                            [self doInitFileWithRelPath:_item.fileRelPath];
                        }
                    }
                }
                break;
            }
            case NTESOperationFileQueryingProcess:
            {
                if (!_item.nosBucket) //没有bucket
                {
                    if (!_item.fileRelPath) //不存在文件路径
                    {
                        [self doCacheVideoWithRelPath:_item.fileRelPath];
                    }
                    else
                    {
                        NSString *path = [[NTESSandboxHelper videoCachePath] stringByAppendingPathComponent:_item.fileRelPath];
                        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) //不存在文件
                        {
                            [self doCacheVideoWithRelPath:_item.fileRelPath];
                        }
                        else
                        {
                            if (_item.nosBucket && _item.nosObject && _item.nosToken) //一切正常
                            {
                                [self doUpdateFileWithRelPath:_item.fileRelPath];
                            }
                            else //桶名、对象、token不全
                            {
                                [self doInitFileWithRelPath:_item.fileRelPath];
                            }
                        }
                    }
                }
                else //有bucket
                {
                    [self doQueryVideoInfo:_item.nosObject];
                }
                break;
            }
            case NTESOperationFileReporingProcess:
            {
                if (!_item.vid) //没有vids
                {
                    if (!_item.nosBucket) //没有bucket
                    {
                        if (!_item.fileRelPath) //没有文件路径
                        {
                            [self doCacheVideoWithRelPath:_item.fileRelPath];
                        }
                        else
                        {
                            NSString *path = [[NTESSandboxHelper videoCachePath] stringByAppendingPathComponent:_item.fileRelPath];
                            if (![[NSFileManager defaultManager] fileExistsAtPath:path]) //文件不存在
                            {
                                [self doCacheVideoWithRelPath:_item.fileRelPath];
                            }
                            else
                            {
                                if (_item.nosBucket && _item.nosObject && _item.nosToken) //一切正常
                                {
                                    [self doUpdateFileWithRelPath:_item.fileRelPath];
                                }
                                else //桶名、对象、token不全
                                {
                                    [self doInitFileWithRelPath:_item.fileRelPath];
                                }
                            }
                        }
                    }
                    else //有bucket
                    {
                        [self doQueryVideoInfo:_item.nosObject];
                    }
                }
                else //一切正常
                {
                    [self doReportAddVideoToServer];
                }
                break;
            }
            case NTESOperationFileCompleteProcess:
            default:
            {
                [self completeHandle:nil];
                break;
            }
        }
    }
    else
    {
        [self cancelHandle];
    }
    [self.lock unlock];
}


#pragma mark - NSOperation
- (BOOL)isReady
{
    return self.state == NTESOperationReadyState && [super isReady];
}

- (BOOL)isExecuting
{
    return self.state == NTESOperationExecutingState;
}

- (BOOL)isFinished
{
    return self.state == NTESOperationFinishedState;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (void)start
{
    [self.lock lock];
    if ([self isCancelled])
    {
        [self performSelector:@selector(cancelHandle)
                     onThread:[[self class] updateRequestThread]
                   withObject:nil
                waitUntilDone:NO
                        modes:[self.runLoopModes allObjects]];
    }
    else if ([self isReady])
    {
        [self performSelector:@selector(operationDidStart)
                     onThread:[[self class] updateRequestThread]
                   withObject:nil
                waitUntilDone:NO
                        modes:[self.runLoopModes allObjects]];
    }
    else
    {}
    [self.lock unlock];
}

- (void)finish
{
    [self.lock lock];
    [self performSelector:@selector(operationDidFinish)
                 onThread:[[self class] updateRequestThread]
               withObject:nil
            waitUntilDone:NO
                    modes:[self.runLoopModes allObjects]];
    [self.lock unlock];
}

- (void)cancel
{
    [self.lock lock];
    if (![self isFinished] && ![self isCancelled]) {
        [super cancel];
        
        if ([self isExecuting]) {
            
            [self performSelector:@selector(operationDidCancel)
                         onThread:[[self class] updateRequestThread]
                       withObject:nil
                    waitUntilDone:NO
                            modes:[self.runLoopModes allObjects]];
        }
    }
    [self.lock unlock];
}



#pragma mark - Setter
- (void)setState:(NTESOperationState)state
{
    if (!NTESStateTransitionIsValid(self.state, state, [self isCancelled])) {
        return;
    }
    
    [self.lock lock];
    NSString *oldStateKey = NTESKeyPathFromOperationState(self.state);
    NSString *newStateKey = NTESKeyPathFromOperationState(state);
    
    [self willChangeValueForKey:newStateKey];
    [self willChangeValueForKey:oldStateKey];
    _state = state;
    [self didChangeValueForKey:oldStateKey];
    [self didChangeValueForKey:newStateKey];
    [self.lock unlock];
}

#pragma mark - Getter
- (NSInteger)transjobstatus
{
    return _interTransjobstatus;
}

- (NSInteger)videoCount
{
    return _interVideoCount;
}

#pragma mark - Class
+ (void)updateRequestThreadEntryPoint:(id)__unused object {
    @autoreleasepool {
        [[NSThread currentThread] setName:@"NTESUpdateThread"];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

+ (NSThread *)updateRequestThread {
    static NSThread *_updateRequestThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _updateRequestThread = [[NSThread alloc] initWithTarget:self
                                                       selector:@selector(updateRequestThreadEntryPoint:)
                                                         object:nil];
        [_updateRequestThread start];
    });
    
    return _updateRequestThread;
}

@end
