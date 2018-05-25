
//
//  NTESUpateVC.m
//  NTESUpadateUI
//
//  Created by Netease on 17/2/24.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESUpdateVC.h"
#import "NTESUpdateDetailVC.h"
#import "NTESUpdateCell.h"
#import "NTESVideoEntity.h"
#import "MJRefresh.h"
#import "NTESAlbumService.h"

@interface NTESUpdateVC ()<UITableViewDelegate, UITableViewDataSource, NTESUpdateCellProtocol>

@property (nonatomic, strong) UIAlertView *netTipAlert; // 网络提示
@property (nonatomic, strong) MJRefreshNormalHeader *refreshHeader; //刷新视图
@property (nonatomic, assign) BOOL netDatasIsLoaded;  //网络数据读取
@property (nonatomic, assign) BOOL isEnterBackground; //进入后台

@property (nonatomic, strong) NSError *loadLocDatasError;

@end

@implementation NTESUpdateVC

- (void)dealloc
{
    [self.locDatas addObjectsFromArray:self.waitDatas]; //同步等待数据
    [self.updateQueue clear];
    [self.updateDataCenter clear];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSubViews];
    
    [self initNotication];
    
    [self doLoadLocalDatas];
    
    if (self.locDatas == 0)
    {
        [self doLoadServerDatas:nil];
    }
    else
    {
        [self.refreshHeader beginRefreshing];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_loadLocDatasError)
    {
        NSString *msg = _loadLocDatasError.userInfo[NTES_ERROR_MSG_KEY];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        //监测网络
        [self doUpdateCheckNetState:NO];
        
        //刷新网络数据
        if (self.waitDatas.count != 0 && !self.refreshHeader.isRefreshing)
        {
            [self.refreshHeader beginRefreshing];
        }
    }
}

- (void)initSubViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    //子类初始化
    [self doInitSubViews];
}

- (void)initNotication
{
    //上传状态查询
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(updateQueryChanged:)
                                       name:NTES_UPDATEQUEUE_QUERY_NOTE
                                     object:nil];
    //进入后台通知
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(didEnterBackground:)
                                       name:UIApplicationDidEnterBackgroundNotification
                                     object:nil];
    //进入前台通知
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(didBecomeActive:)
                                       name:UIApplicationWillEnterForegroundNotification
                                     object:nil];
    //网络监听
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(onNetwokingChanged:)
                                       name:kRealReachabilityChangedNotification
                                     object:nil];
    
    //子类初始化
    [self doInitNotication];
}

#pragma mark - Fuction - 路由
- (void)goDetailVCWithEntity:(NTESVideoEntity *)entity
{
    if (entity && entity.vid)
    {
        NTESUpdateDetailVC *push = [[NTESUpdateDetailVC alloc] initWithEntity:entity];
        [self.navigationController pushViewController:push animated:YES];
    }
    else
    {
        [self.view makeToast:@"vid不合法" duration:2.0 position:CSToastPositionCenter];
    }
}

#pragma mark - Fuction - 数据
//读取本地数据
- (void)doLoadLocalDatas
{
    [self.updateDataCenter loadLocVideos];
    
    //执行子类其他任务
    __weak typeof(self) weakSelf = self;
    [self doInitBeforeUpdateDatasFromBreak:^(NSError *error) {
        
        if (error)
        {
            weakSelf.loadLocDatasError = error;
        }
        else
        {
            if (weakSelf.locDatas.count != 0)
            {
                [weakSelf doUpdateCheckNetState:NO];
                
                [weakSelf doUpdateFromDatas:weakSelf.locDatas];
            }
        }
    }];

    [self.videoList reloadData];
}

//读取服务器数据
- (void)doLoadServerDatas:(void(^)(NSError *error))complete
{
    __weak typeof(self) weakSelf = self;
    
    if (self.locDatas.count + self.netDatas.count == 0)
    {
        [self.emptyView show:YES style:NTESUpdateEmptyLoading];
    }
    
    _netDatasIsLoaded = NO;
    
    [self doLoadServerData:^(NSError *error, NSArray<NTESVideoEntity *> *infos) {
        if (!error)
        {
            weakSelf.netDatasIsLoaded = YES; //网络加载成功
            
            //添加缓存
            [weakSelf.netDatas removeAllObjects];
            [weakSelf.netDatas addObjectsFromArray:infos];
            
            //增加状态查询
            NSMutableDictionary *queryDic = [NSMutableDictionary dictionary];
            for (NTESVideoEntity *item in infos) {
                if (item.state == NTESVideoItemTransCoding) {
                    [queryDic setObject:@(item.state) forKey:item.vid];
                }
            }
            [weakSelf.updateQueue addQueryTaskWithDic:queryDic];
            
            //增加等待数据
            [weakSelf doAddWaitUpdates];
            
            //刷新UI
            [weakSelf.videoList reloadData];
        }
        else
        {
            if (weakSelf.locDatas.count + weakSelf.netDatas.count == 0)
            {
                [weakSelf.emptyView show:YES style:NTESUpdateEmptyTimeOut];
            }
            
            NSLog(@"读取数据出错 [%@]", error.userInfo[NTES_ERROR_MSG_KEY] ?: @"");
            NSString *toast = @"读取网络数据出错";
            if (weakSelf.waitDatas.count != 0) {
                [toast stringByAppendingString:@", 放弃上传"];
                [weakSelf.waitDatas removeAllObjects];
            }
            [weakSelf.view makeToast:toast duration:2 position:CSToastPositionCenter];
        }
        
        if (complete) {
            complete(error);
        }

    }];
}

//删除数据
- (void)doDeleteVideo:(NTESVideoEntity *)video
{
    [SVProgressHUD show];
    if (video.state == NTESVideoItemUnexist)
    {
        [self deleteRowWithItem:video]; //删除模型
    }
    else if (video.state == NTESVideoItemWaiting)
    {
        [self.updateQueue cancelUpdateTaskWithItem:video]; //取消任务
        [self deleteCacheFileWithRelPath:video.fileRelPath];
        [self deleteRowWithItem:video]; //删除模型
    }
    else if (video.state == NTESVideoItemCaching)
    {
        [self.updateQueue cancelUpdateTaskWithItem:video]; //取消任务
    }
    else if (video.state == NTESVideoItemUpdating)
    {
        [self.updateQueue cancelUpdateTaskWithItem:video]; //取消任务
        [self deleteCacheFileWithRelPath:video.fileRelPath];
    }
    else if (video.state == NTESVideoItemUpdateFail)
    {
        [self deleteRowWithItem:video]; //删除模型
        [self deleteCacheFileWithRelPath:video.fileRelPath];
    }
    else //传完了，需要删除NOS服务器上的视频
    {
        __weak typeof(self) weakSelf = self;
        [SVProgressHUD show];
        
        [self doDeleteServerDataWithVid:video.vid complete:^(NSError *error) {
            [SVProgressHUD dismiss];
            if (error && error.code != 1644)
            {
                NSLog(@"删除失败:[%@]", error);
                [weakSelf.view makeToast:@"删除失败" duration:2 position:CSToastPositionCenter];
            }
            else
            {
                [weakSelf deleteRowWithItem:video];
            }
        }];
    }
}

//删除缓存文件
- (void)deleteCacheFileWithRelPath:(NSString *)relPath
{
    if (relPath) {
        NSString *path = [[NTESSandboxHelper videoCachePath] stringByAppendingPathComponent:relPath];
        [NTESSandboxHelper deleteFiles:@[path]];
    }
}

//删除行
- (void)deleteRowWithItem:(NTESVideoEntity *)item
{
    [SVProgressHUD dismiss];
    NSInteger index = -1;
    
    if ([self.netDatas containsObject:item])
    {
        index = [self.netDatas indexOfObject:item];
        [self.netDatas removeObjectAtIndex:index];
        item = nil;
    }
    else if ([self.locDatas containsObject:item])
    {
        index = [self.locDatas indexOfObject:item];
        [self.locDatas removeObjectAtIndex:index];
        [self.updateDataCenter saveUpdateRecordToDisk];
        index += self.netDatas.count;
        item = nil;
    }
    
    if (index != -1)
    {
        BOOL isBeyondMax = ((self.netDatas.count + self.locDatas.count) >= self.updateDataCenter.videoMaxCount);
        [self doBeyondMaxVideo:isBeyondMax];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [_videoList deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

#pragma mark - Function - 上传
//上传等待数据
- (void)doAddWaitUpdates
{
    //读取网络数据
    if (!_netDatasIsLoaded) //未加载过网络
    {
        [self doLoadServerDatas:nil];
    }
    else //加载过网络
    {
        //添加等待
        [self doAddWaitDatas];
    }
}

//添加上传等待数据
- (void)doAddWaitDatas
{
    if (self.waitDatas.count  == 0) {
        return;
    }
    
    if ((self.netDatas.count + self.locDatas.count) >= self.updateDataCenter.videoMaxCount)
    {
        NSMutableArray *waitCachePaths = [NSMutableArray array];
        
        //等待上传的缓存文件文件
        [self.waitDatas enumerateObjectsUsingBlock:^(NTESVideoEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *relPath = obj.fileRelPath;
            if (relPath) {
                NSString *path = [[NTESSandboxHelper videoCachePath] stringByAppendingPathComponent:relPath];
                [waitCachePaths addObject:path];
            }
        }];
        
        //删除缓存文件
        [NTESSandboxHelper deleteFiles:waitCachePaths];
        
        NSString *toast = [NSString stringWithFormat:@"上传数量超过%zi个，请在相册查询", self.updateDataCenter.videoMaxCount];
        [self.view makeToast:toast duration:2 position:CSToastPositionCenter];
        [self.waitDatas removeAllObjects];
    }
    else
    {
        //上传等待的队列
        [self doUpdateFromDatas:self.waitDatas];
        
        //添加到本地模型
        [self.locDatas addObjectsFromArray:self.waitDatas];
        [self.updateDataCenter saveUpdateRecordToDisk];
        
        //移除等待队列
        [self.waitDatas removeAllObjects];
    }
    
    [self.videoList reloadData];
}

//添加上传数据
- (void)doUpdateFromDatas:(NSArray *)datas
{
    NSMutableArray *taskModels = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    
    //上传模型
    [datas enumerateObjectsUsingBlock:^(NTESVideoEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NTESUpdateModel *model = [weakSelf updateModelWithItem:obj];
        [taskModels addObject:model];
    }];
    
    //上传任务
    [self.updateQueue addUpdateTaskWithModels:taskModels complete:nil];
    
}

//根据网络状态控制上传
- (void)doUpdateCheckNetState:(BOOL)isChanged
{
    if (GLobalRealReachability.currentReachabilityStatus == RealStatusViaWiFi)
    {
        [self showWWANTip:NO]; //消失弹框
        
        [self doShowNoneNetTip:NO]; //消失无网提示
        
        if (self.locDatas.count != 0 || self.waitDatas.count != 0)
        {
            if (isChanged)
            {
                UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
                NSString *toast = @"wifi网络, 开始上传";
                [rootView makeToast:toast duration:2 position:CSToastPositionCenter];
            }
            
            [self.updateQueue resume];
        }
    }
    else if (GLobalRealReachability.currentReachabilityStatus == RealStatusViaWWAN)
    {
        [self doShowNoneNetTip:NO]; //消失无网提示
        
        if (self.locDatas.count != 0 || self.waitDatas.count != 0)
        {
            [self showWWANTip:YES];
        }
    }
    else
    {
        [self doShowNoneNetTip:YES]; //显示无网提示
        
        [self showWWANTip:NO]; //消失弹框
        
        if (self.locDatas.count != 0 || self.waitDatas.count != 0)
        {
            [self.updateQueue pause];
            
            if (isChanged)
            {
                UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
                [rootView makeToast:@"网络异常, 恢复后将继续上传" duration:2 position:CSToastPositionCenter];
            }
        }
    }
}

//上传回调
- (NTESUpdateModel *)updateModelWithItem:(NTESVideoEntity *)item
{
    WEAK_SELF(weakSelf);
    NTESUpdateModel *model = [[NTESUpdateModel alloc] init];
    model.item = item;
    
    //开始回调
    model.startBlock = ^(NSError *error, NTESVideoEntity *item){
        //保存上传信息
        [weakSelf.updateDataCenter saveUpdateRecordToDisk];
    };
    
    //完成回调
    model.completeBlock = ^(NSError *error, NTESVideoEntity *item){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!error)
        {
            //删除缓存文件
            [strongSelf deleteCacheFileWithRelPath:item.fileRelPath];
            //将模型从本地模型缓存移至网络模型缓存
            [strongSelf.locDatas removeObject:item];
            [strongSelf.netDatas addObject:item];
        }
        //保存上传信息
        [strongSelf.updateDataCenter saveUpdateRecordToDisk];
        [strongSelf.videoList.mj_header beginRefreshing];
        [strongSelf.videoList reloadData];
    };
    
    //取消回调
    model.cancelBlock = ^(NSError *error, NTESVideoEntity *item){
        [weakSelf deleteRowWithItem:item];
    };
    
    model.phaseBlock = ^(NSError *error, NTESVideoEntity *item){
        //保存上传信息
        [weakSelf.updateDataCenter saveUpdateRecordToDisk];
    };
    return model;
}


#pragma mark - Helper - 视图控制 && 数据映射
- (void)showWWANTip:(BOOL)isShown
{
    if (isShown)
    {
        [self.updateQueue pause];
        
        if (!self.netTipAlert.isVisible)
        {
            __weak typeof(self) weakSelf = self;
            [self.netTipAlert showAlertWithCompletionHandler:^(NSInteger index) {
                
                if (index == 1)
                {
                    [weakSelf.updateQueue resume];
                }
            }];
        }
    }
    else
    {
        if (self.netTipAlert.isVisible)
        {
            [self.netTipAlert dismissWithClickedButtonIndex:0 animated:NO];
        }
    }
}

//index -> item
- (NTESVideoEntity *)itemWithIndexPath:(NSIndexPath *)indexPath
{
    NSArray *datas = ((indexPath.row < self.netDatas.count) ? self.netDatas : self.locDatas);
    NSInteger index = (indexPath.row < self.netDatas.count ? indexPath.row : indexPath.row - self.netDatas.count);
    NTESVideoEntity *item = datas[index];
    return item;
}

//视频按时间排序
- (void)sortData:(NSMutableArray<NTESVideoEntity *> *)array {
    NTESVideoEntity *temp = nil;
    if (array.count) {
        NSInteger first = 0;
        NSInteger last = array.count - 1;
        while (first < last) {
            temp = array[first];
            array[first] = array[last];
            array[last] = temp;
            first++;
            last--;
        }
    }
}

#pragma mark - Action && Notication
- (void)updateQueryChanged:(NSNotification *)note
{
    NSDictionary *dic = [note object];

    if (dic[@"error"]) {
        NSLog(@"查询任务失败: %@", dic[@"error"]);
    }
    else
    {
        if (dic[@"vid"] && dic[@"state"])
        {
            NSString *vid = dic[@"vid"];
            NTESVideoItemState state = [dic[@"state"] integerValue];
            NTESVideoEntity *item = [self.updateDataCenter videoInVideosWithVid:vid];
            item.state = state;
        }
    }
}

- (void)didEnterBackground:(NSNotification *)note
{
    _isEnterBackground = YES;
    
    [self showWWANTip:NO];
    
    [self.updateQueue performSelector:@selector(pause)
                                          withObject:nil
                                          afterDelay:1];
}

- (void)didBecomeActive:(NSNotification *)note
{
    _isEnterBackground = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self.updateQueue
                                             selector:@selector(pause)
                                               object:nil];
    
    [self doUpdateCheckNetState:YES];
}

- (void)onNetwokingChanged:(NSNotification *)note
{
    if (_isEnterBackground) //在后台，不监测网络
    {
        return;
    }
    [self doUpdateCheckNetState:YES];
}


#pragma mark - Delegate - <NTESUpdateCellProtocol>
- (void)updateCellRetryAction:(NTESUpdateCell *)cell
{
    NSIndexPath *indexPath = [_videoList indexPathForCell:cell];
    
    if (indexPath.row >= self.netDatas.count &&
        (indexPath.row - self.netDatas.count) < self.locDatas.count)
    {
        NTESVideoEntity *item = self.locDatas[indexPath.row - self.netDatas.count];
        [self.locDatas removeObject:item];
        [_videoList deleteRowsAtIndexPaths:@[indexPath]
                           withRowAnimation:UITableViewRowAnimationLeft];
        
        [self.locDatas addObject:item];
        [self.updateDataCenter saveUpdateRecordToDisk];
        [_videoList reloadData];
        
        [self doUpdateFromDatas:@[item]];
    }
}

#pragma mark - Delegate - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = self.netDatas.count + self.locDatas.count;

    [self.emptyView show:(count == 0) style:NTESUpdateEmptyNone];
    
    if (_netDatasIsLoaded)
    {
        BOOL isBeyondMax = (count >= self.updateDataCenter.videoMaxCount);
        [self doBeyondMaxVideo:isBeyondMax];
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NTESUpdateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NTESUpdateCell" forIndexPath:indexPath];
    NTESVideoEntity *item = [self itemWithIndexPath:indexPath];
    [cell configCellWithItem:item];
    cell.delegate = self;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NTESVideoEntity *item = [self itemWithIndexPath:indexPath];
    return (item.state != NTESVideoItemTransCoding); //转码中不允许删除
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NTESVideoEntity *item = [self itemWithIndexPath:indexPath];
        [self doDeleteVideo:item];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NTESVideoEntity *item = [self itemWithIndexPath:indexPath];

    if (item.state == NTESVideoItemTransCoding || item.state == NTESVideoItemComplete)
    {
        [self goDetailVCWithEntity:item];
    }
    else if (item.state == NTESVideoItemCaching || item.state == NTESVideoItemUpdating)
    {
        [self.view makeToast:@"视频正在上传中" duration:2.0 position:CSToastPositionCenter];
    }
    else
    {}
}

#pragma mark - Getter
- (UITableView *)videoList
{
    if (!_videoList) {
        _videoList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) style:UITableViewStylePlain];
        _videoList.showsVerticalScrollIndicator = NO;
        _videoList.showsHorizontalScrollIndicator = NO;
        _videoList.delegate = self;
        _videoList.dataSource = self;
        _videoList.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _videoList.rowHeight = 90.0;
        _videoList.separatorStyle = UITableViewCellSeparatorStyleNone;
        _videoList.mj_header = self.refreshHeader;
        [_videoList registerClass:[NTESUpdateCell class] forCellReuseIdentifier:@"NTESUpdateCell"];
    }
    return _videoList;
}

- (UIAlertView *)netTipAlert
{
    if (!_netTipAlert) {
        _netTipAlert = [[UIAlertView alloc] initWithTitle:nil
                                                  message:@"正在使用手机流量，是否继续上传？"
                                                 delegate:nil
                                        cancelButtonTitle:@"否"
                                        otherButtonTitles:@"是", nil];
    }
    return _netTipAlert;
}

- (MJRefreshNormalHeader *)refreshHeader
{
    if (!_refreshHeader)
    {
        __weak typeof(self) weakSelf = self;
        _refreshHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{ //下拉刷新事件
            
            [weakSelf doShowNoneNetTip:NO];
            
            [weakSelf doLoadServerDatas:^(NSError *error) {
                
                [weakSelf.videoList.mj_header endRefreshing];
                
                [self sortData:self.locDatas];
                [self sortData:self.netDatas];
                
            }];
        }];
        
        _refreshHeader.endRefreshingCompletionBlock = ^(){
        
            BOOL noneNetIsShown = (GLobalRealReachability.currentReachabilityStatus == RealStatusNotReachable);
            [weakSelf doShowNoneNetTip:noneNetIsShown];
        };
        
        _refreshHeader.lastUpdatedTimeLabel.hidden = YES;
        _refreshHeader.backgroundColor = [UIColor whiteColor];
    }
    return _refreshHeader;
}

- (NTESUpdateEmptyView *)emptyView
{
    if (!_emptyView) {
        _emptyView = [[NTESUpdateEmptyView alloc] init];
        _emptyView.style = NTESUpdateEmptyLoading;
        __weak typeof(self) weakSelf = self;
        _emptyView.retry = ^(){
            [weakSelf doLoadServerDatas:nil];
        };
    }
    return _emptyView;
}

- (NSMutableArray<NTESVideoEntity *> *)netDatas
{
    return self.updateDataCenter.netVideos;
}

- (NSMutableArray<NTESVideoEntity *> *)locDatas
{
    return self.updateDataCenter.locVideos;
}

#pragma mark - 子类重载
- (NTESUpdateData *)updateDataCenter
{
    NSAssert(NO, @"不应该运行到这里，子类一定要重载这个方法");
    return nil;
}

- (NTESUpdateQueue *)updateQueue
{
    NSAssert(NO, @"不应该运行到这里，子类一定要重载这个方法");
    return nil;
}

- (void)doInitSubViews {};

- (void)doInitNotication {};

- (void)doInitBeforeUpdateDatasFromBreak:(void (^)(NSError *error))complete
{
    if (complete) {
        complete(nil);
    }
};

- (void)doLoadServerData:(NTESUpdateLoadServerDataBlock)complete {}; //加载网络数据

- (void)doDeleteServerDataWithVid:(NSString *)vid
                         complete:(NTESUpdateDeleteServerDataBlock)complete {}; //删除网络数据

- (void)doBeyondMaxVideo:(BOOL)isBeyond {};

- (void)doShowNoneNetTip:(BOOL)isShow {};

@end
