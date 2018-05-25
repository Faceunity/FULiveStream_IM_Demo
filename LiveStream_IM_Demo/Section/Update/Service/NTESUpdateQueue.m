//
//  NTESUpdateQueue.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/4/24.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESUpdateQueue.h"
#import "NTESUpdateOperation.h"
#import "NTESDaoService+Update.h"
#import <pthread.h>

@interface NTESUpdateQueue () <NTESUpdateOperationProtocol>
{
    pthread_mutex_t g_queryDataLock;
    pthread_mutex_t g_pauseTaskLock;
    pthread_mutex_t g_updateDataLock;
    dispatch_group_t g_controlPauseGroup;  //暂停同步group
    dispatch_queue_t g_controlThreadQueue; //控制线程
}

@property (nonatomic, assign) NTESUpdateType type;
@property (nonatomic, strong) NSOperationQueue *updateQueue; //上传queue
@property (nonatomic, strong) NSMutableArray <NTESUpdateModel *>*updateModels; //上传任务模型
@property (nonatomic, strong) NSMutableDictionary *queryStates; //待查询的vid {vid : state}
@property (nonatomic, assign) BOOL allIsPaused;
@property (nonatomic, strong) NTESUpdateModel *excutingModel;
@end

@implementation NTESUpdateQueue

- (instancetype)initWithType:(NTESUpdateType)type
{
    if (self = [super init])
    {
        _type = type;
        _updateModels = [NSMutableArray array];
        _queryStates = [NSMutableDictionary dictionary];
        g_controlPauseGroup = dispatch_group_create();
        g_controlThreadQueue = [self queueWithType:type];
        pthread_mutex_init(&g_queryDataLock, NULL);
        pthread_mutex_init(&g_updateDataLock, NULL);
        pthread_mutex_init(&g_pauseTaskLock, NULL);
    }
    return self;
}

- (void)clear
{
    [self cancel];
}

- (dispatch_queue_t)queueWithType:(NTESUpdateType)type
{
    dispatch_queue_t queue;
    
    switch (type)
    {
        case NTESUpdateTypeDemand:
            queue = dispatch_queue_create("update.demand.queue", DISPATCH_QUEUE_CONCURRENT);
            break;
        case NTESUpdateTypeShortVideo:
            queue = dispatch_queue_create("update.shortVideo.queue", DISPATCH_QUEUE_CONCURRENT);
            break;
            
        default:
            queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            break;
    }
    
    return queue;
}

#pragma mark - 公共API - 上传任务
//添加任务
- (void)addUpdateTaskWithModels:(NSArray <NTESUpdateModel *>*)models complete:(void(^)())complete
{
    //参数校验
    if (!models || models.count == 0)
    {
        if (complete) {
            complete();
        }
        return;
    }
    
    //添加任务
    dispatch_async(g_controlThreadQueue, ^{
        [models enumerateObjectsUsingBlock:^(NTESUpdateModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
            NTESUpdateOperation *operation = [[NTESUpdateOperation alloc] initWithItem:model.item type:_type];
            operation.delegate = self;
            if (!operation)
            {
                NSLog(@"[NTESDemo] 上传 － 添加任务 － 操作初始化失败");
                return;
            }
            
            //状态更新
            model.item.state = NTESVideoItemWaiting;
            
            //添加队列
            model.isPaused = _allIsPaused;
            
            pthread_mutex_lock(&g_updateDataLock);
            if (![_updateModels containsObject:model]) {
                [_updateModels addObject:model];
            }
            pthread_mutex_unlock(&g_updateDataLock);
            
            if (!model.isPaused) {
                //任务管理
                [self.updateQueue addOperation:operation];
            }
        }];
        
        if (complete) {
            complete();
        }
    });
}

//取消某个
- (void)cancelUpdateTaskWithItem:(NTESVideoEntity *)item
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(g_controlThreadQueue, ^{
        
        [weakSelf updateModelWithItem:item complete:^(NTESUpdateModel *model) {
            
            __strong typeof(weakSelf) strongSelf = self;
            
            if (!model)
            {
                NSLog(@"[NTESDemo] 上传 － 取消单个任务 － 未找到该任务");
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (model.cancelBlock) {
                        model.cancelBlock(nil, item);
                    }
                });
            }
            else
            {
                if (model.isPaused)
                {
                    pthread_mutex_lock(&(strongSelf->g_updateDataLock));
                    [weakSelf.updateModels removeObject:model];
                    pthread_mutex_unlock(&(strongSelf->g_updateDataLock));
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (model.cancelBlock) {
                            model.cancelBlock(nil, item);
                        }
                    });
                }
                else
                {
                    [strongSelf.updateQueue.operations enumerateObjectsUsingBlock:^(__kindof NTESUpdateOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        if (obj.item == item)
                        {
                            [obj cancel];
                            *stop = YES;
                        }
                    }];
                }
            }
        }];
    });
}

//暂停全部
- (void)pause
{
    if (_allIsPaused == YES) {
        return;
    }
    
    _allIsPaused = YES;
    
    dispatch_async(g_controlThreadQueue, ^{
        
        pthread_mutex_lock(&g_pauseTaskLock);
    
        __weak typeof(self) weakSelf = self;
        
        [weakSelf.updateModels enumerateObjectsUsingBlock:^(NTESUpdateModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.isPaused = YES;
        }];
        
        [weakSelf.updateQueue.operations enumerateObjectsUsingBlock:^(__kindof NSOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            dispatch_group_enter(strongSelf->g_controlPauseGroup);
            [obj cancel];
        }];
        
        pthread_mutex_unlock(&g_pauseTaskLock);
    });
}

//恢复全部
- (void)resume
{
    if (_allIsPaused == NO) {
        return;
    }
    
    _allIsPaused = NO;
    
    dispatch_async(g_controlThreadQueue, ^{
        pthread_mutex_lock(&g_pauseTaskLock);
        dispatch_group_wait(g_controlPauseGroup, DISPATCH_TIME_FOREVER);
        
        __weak typeof(self) weakSelf = self;
        [self addUpdateTaskWithModels:_updateModels complete:^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            pthread_mutex_unlock(&(strongSelf->g_pauseTaskLock));
        }];
    });
}

//取消全部
- (void)cancel
{
    dispatch_async(g_controlThreadQueue, ^{
        if (_allIsPaused) //已经暂停了
        {
            [_updateModels enumerateObjectsUsingBlock:^(NTESUpdateModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (obj.cancelBlock) {
                        obj.cancelBlock(nil, obj.item);
                    }
                });
            }];
            
            pthread_mutex_lock(&g_updateDataLock);
            [_updateModels removeAllObjects];
            pthread_mutex_unlock(&g_updateDataLock);
        }
        else
        {
            [self.updateQueue cancelAllOperations];
        }
        _allIsPaused = NO;
    });
    
    [self stopQueryTask];
}


#pragma mark - 公共API - 查询转码
- (void)addQueryTaskWithDic:(NSDictionary *)dic
{
    BOOL needStartQueryTask = NO;
    
    if (!dic) {
        return;
    }
    
    if (_queryStates.count == 0) {
        needStartQueryTask = YES;
    }
    
    pthread_mutex_lock(&g_queryDataLock);
    __weak typeof(self) weakSelf = self;
    [dic enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull vid, NSNumber  *_Nonnull state, BOOL * _Nonnull stop) {
        if ([state integerValue] == NTESVideoItemTransCoding)
        {
            [weakSelf.queryStates setObject:state forKey:vid];
        }
    }];
    pthread_mutex_unlock(&g_queryDataLock);
    
    if (needStartQueryTask && _queryStates.count != 0) {
        [self startQueryTask];
    }
}

- (void)startQueryTask
{
    //服务端查询
    NSMutableArray *vids = [NSMutableArray arrayWithArray:[_queryStates allKeys]];
    __weak typeof(self) weakSelf = self;
    [[NTESDaoService sharedService] requestVideoStateWithVids:vids completion:^(NSError *error, NSDictionary *states) {
        
        if (!error)
        {
            [weakSelf.queryStates enumerateKeysAndObjectsUsingBlock:^(NSString *vid, NSNumber *obj, BOOL * _Nonnull stop) {
                
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
                NSNumber *transcodeState = [states objectForKey:vid];
                NTESVideoItemState oriState = [obj integerValue];
                NTESVideoItemState state = oriState;
                if (transcodeState) {
                    switch ([transcodeState integerValue]) {
                        case 10:
                        case 30:
                            state = NTESVideoItemTransCoding;
                            break;
                        case 20:
                            state = NTESVideoItemTransCodeFail;
                            break;
                        case 40:
                            state = NTESVideoItemComplete;
                            break;
                        case -1:
                            state = NTESVideoItemUnexist;
                        default:
                            break;
                    }
                }
                
                if (oriState != state) //有结果了
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NTES_UPDATEQUEUE_QUERY_NOTE object:@{@"vid":vid, @"state":@(state)}];
                    pthread_mutex_lock(&(strongSelf->g_queryDataLock));
                    [weakSelf.queryStates removeObjectForKey:vid];
                    pthread_mutex_unlock(&(strongSelf->g_queryDataLock));
                }
            }];
        }
        else //查询失败了
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NTES_UPDATEQUEUE_QUERY_NOTE object:@{@"error":error}];
        }
        
        //轮巡
        if (weakSelf.queryStates.count > 0)
        {
            [weakSelf performSelector:@selector(startQueryTask) withObject:nil afterDelay:10];
        }
    }];
}

- (void)stopQueryTask
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma mark - 私有API
- (void)updateModelWithItem:(NTESVideoEntity *)item complete:(void(^)(NTESUpdateModel *model))complete
{
    dispatch_async(g_controlThreadQueue, ^{
        NTESUpdateModel *dstModel = nil;
        pthread_mutex_lock(&g_updateDataLock);
        for (NTESUpdateModel *model in _updateModels) {
            if (model.item == item) {
                dstModel = model;
                break;
            }
        }
        pthread_mutex_unlock(&g_updateDataLock);
        
        if (complete) {
            complete(dstModel);
        }
    });
}

#pragma mark - 上传任务 - <NTESUpdateOperationProtocol>
//任务开启
- (void)updateOperationDidStart:(NTESUpdateOperation *)operation
{
    __weak typeof(self) weakSelf = self;
    [self updateModelWithItem:operation.item complete:^(NTESUpdateModel *model) {
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf.excutingModel = model;
        
        //离开恢复暂停队列
        if (strongSelf.excutingModel.isPaused) {
            strongSelf.excutingModel.isPaused = NO;
        }
        
        //回调
        dispatch_async(dispatch_get_main_queue(), ^{
            if (strongSelf.excutingModel.startBlock) {
                strongSelf.excutingModel.startBlock(nil, strongSelf.excutingModel.item);
            }
        });
    }];
}

//任务取消
- (void)updateOperationDidCancel:(NTESUpdateOperation *)operation
{
    __weak typeof(self) weakSelf = self;
    [self updateModelWithItem:operation.item complete:^(NTESUpdateModel *model) {
        
        __strong typeof(self) strongSelf = weakSelf;
        
        strongSelf.excutingModel = model;
        
        if (strongSelf.excutingModel.isPaused) //暂停
        {
            //等待状态
            strongSelf.excutingModel.item.state = NTESVideoItemWaiting;
            
            //移除管理
            dispatch_group_leave(strongSelf->g_controlPauseGroup);
            
            //回调
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf.excutingModel.pauseBlock) {
                    strongSelf.excutingModel.pauseBlock(nil, strongSelf.excutingModel.item);
                }
            });
        }
        else //停止
        {
            //移除管理
            pthread_mutex_lock(&g_updateDataLock);
            [strongSelf.updateModels removeObject:strongSelf.excutingModel];
            pthread_mutex_unlock(&g_updateDataLock);
            
            strongSelf.excutingModel.item.state = NTESVideoItemNormal;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf.excutingModel.cancelBlock) {
                    strongSelf.excutingModel.cancelBlock(nil, strongSelf.excutingModel.item);
                }
            });
        }

    }];
}

//任务完成
- (void)updateOperationDidComplete:(NTESUpdateOperation *)operation
                             error:(NSError *)error
                               vid:(NSString *)vid
{
    if (error)
    {
        //需求要求没有网络断掉时，设置为等待中...
        if ([RealReachability sharedInstance].currentReachabilityStatus == RealStatusNotReachable)
        {
            operation.item.state = NTESVideoItemWaiting;
        }
        else
        {
            operation.item.state = NTESVideoItemUpdateFail;
            operation.item.updateProcess = 0.0;
        }
    }
    else
    {
        //点播才发起转码请求，短视频不用
        if (_type == NTESUpdateTypeDemand)
        {
            if (operation.transjobstatus == 0)
            {
                operation.item.state = NTESVideoItemTransCoding;
                operation.item.updateProcess = 1.0;
                
                [self addQueryTaskWithDic:@{vid: @(operation.item.state)}];
            }
            else
            {
                operation.item.state = NTESVideoItemTransCodeFail;
                operation.item.updateProcess = 0.0;
            }
        }
        else
        {
            operation.item.state = NTESVideoItemComplete;
            operation.item.updateProcess = 1.0;
        }
    }
    operation.item.vid = vid;
    
    //查找模型
    __weak typeof(self) weakSelf = self;
    [self updateModelWithItem:operation.item complete:^(NTESUpdateModel *model) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        strongSelf.excutingModel = model;
        
        //移除管理
        if (strongSelf.excutingModel.isPaused == YES)
        {
            dispatch_group_leave(strongSelf->g_controlPauseGroup);
        }
        
        pthread_mutex_lock(&(strongSelf->g_updateDataLock));
        [strongSelf.updateModels removeObject:strongSelf.excutingModel];
        pthread_mutex_unlock(&(strongSelf->g_updateDataLock));
        
        //回调
        dispatch_async(dispatch_get_main_queue(), ^{
            if (strongSelf.excutingModel.completeBlock) {
                strongSelf.excutingModel.completeBlock(error, strongSelf.excutingModel.item);
            }
        });
    }];
}

//任务阶段
- (void)updateOperationStateDidChanged:(NTESUpdateOperation *)operation
                               toPhase:(NTESOperationProcess)phase
{
    //更新数据
    if (phase == NTESOperationCachingProcess)
    {
        operation.item.state = NTESVideoItemCaching;
    }
    else if (phase == NTESOperationFileInitingProcess)
    {
        operation.item.state = NTESVideoItemUpdating;
    }
    
    //回调
    if (phase == NTESOperationCachingProcess || phase == NTESOperationFileInitingProcess)
    {
        if (self.excutingModel.phaseBlock) {
            self.excutingModel.phaseBlock(nil, self.excutingModel.item);
        }
    }
}

//上传进度
- (void)updateOperationProcess:(NTESUpdateOperation *)operation process:(CGFloat)process
{
    //更新数据
    operation.item.state = NTESVideoItemUpdating; //上传中
    operation.item.updateProcess = process;
    
    //回调
    if (self.excutingModel.processBlock) {
        self.excutingModel.processBlock(nil, self.excutingModel.item);
    };
}


#pragma mark - Getter
- (NSOperationQueue *)updateQueue
{
    if (!_updateQueue) {
        _updateQueue = [[NSOperationQueue alloc] init];
        _updateQueue.maxConcurrentOperationCount = 1;
    }
    return _updateQueue;
}



@end
