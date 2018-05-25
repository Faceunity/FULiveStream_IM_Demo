//
//  NTESDemandUpdateVC.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/5/3.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESDemandUpdateVC.h"
#import "NTESAlubmVC.h"
#import "NTESAlbumService.h"
#import "NTESDaoService+Update.h"

@interface NTESDemandUpdateVC ()

@property (nonatomic, strong) UIButton *updateBtn;

@end

@implementation NTESDemandUpdateVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addUpdateEntity:(NSArray <NTESAlbumVideoEntity *> *)items
{
    if (!self.waitDatas) {
        self.waitDatas = [NSMutableArray array];
    }
    
    __weak typeof(self) weakSelf = self;
    [items enumerateObjectsUsingBlock:^(NTESAlbumVideoEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NTESVideoEntity *video = [[NTESVideoEntity alloc] initWithAlbumVideo:obj];
        if (video) {
            [weakSelf.waitDatas addObject:video];
        }
    }];
}

#pragma mark - Fuction - 路由
- (void)goAlbumVCWithNumber:(NSInteger)number
{
    if (number > 0)
    {
        __weak typeof(self) weakSelf = self;
        NTESAlubmVC *album = [NTESAlubmVC albumWithMaxNumber:number withMinDuration:0.f selected:^(NSArray<NTESAlbumVideoEntity *> *selectVideos) {
            [weakSelf addUpdateEntity:selectVideos];
        }];
        [self.navigationController pushViewController:album animated:YES];
    }
    else
    {
        [self.view makeToast:@"number不合法" duration:2.0 position:CSToastPositionCenter];
    }
}

#pragma mark - Action
- (void)updateStartAction:(UIButton *)btn
{
    NSInteger number = self.updateDataCenter.videoMaxCount - self.netDatas.count - self.locDatas.count;
    [self goAlbumVCWithNumber:number];
}

#pragma mark - Getter
- (UIButton *)updateBtn
{
    if (!_updateBtn) {
        _updateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_updateBtn setBackgroundImage:[UIImage imageNamed:@"按钮 正常"] forState:UIControlStateNormal];
        [_updateBtn setBackgroundImage:[UIImage imageNamed:@"按钮 按下"] forState:UIControlStateHighlighted];
        [_updateBtn setBackgroundImage:[UIImage imageNamed:@"按钮 不可点击"] forState:UIControlStateDisabled];
        [_updateBtn setTitle:@"上传视频" forState:UIControlStateNormal];
        [_updateBtn setImage:[UIImage imageNamed:@"album_video_add"] forState:UIControlStateNormal];
        [_updateBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 0)];
        [_updateBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 0)];
        [_updateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_updateBtn addTarget:self action:@selector(updateStartAction:) forControlEvents:UIControlEventTouchUpInside];
        _updateBtn.enabled = NO;
    }
    return _updateBtn;
}

#pragma mark - Reload Function
//指定数据中心
- (NTESUpdateData *)updateDataCenter
{
    return GLobalUpdateDemandData;
}

//指定上传队列
- (NTESUpdateQueue *)updateQueue
{
    return GLobalUpdateDemandQueue;
}

//布局视图
- (void)doInitSubViews
{
    [self.view addSubview:self.updateBtn];
    __weak typeof(self) weakSelf = self;
    [_updateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(20.0);
        make.right.equalTo(weakSelf.view.mas_right).mas_offset(-20);
        make.height.mas_equalTo(46.0);
    }];
    
    [self.view addSubview:self.videoList];
    [self.videoList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.updateBtn.mas_bottom).mas_offset(20.0);
        make.left.right.bottom.equalTo(weakSelf.view);
    }];
    
    [self.view addSubview:self.emptyView];
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.videoList);
    }];
}

//断点续传之前需要执行的任务
- (void)doInitBeforeUpdateDatasFromBreak:(void (^)(NSError *error))complete
{
    [NTESAuthorizationHelper requestAblumAuthorityWithCompletionHandler:^(NSError *error) {
        
        if (error)
        {
            NSError *error = [NSError errorWithDomain:@"ntes.update.album.authorization"
                                                 code:0x1000
                                             userInfo:@{NTES_ERROR_MSG_KEY:@"请开启相册访问权限"}];
            
            if (complete) {
                complete(error);
            }
        }
        else
        {
            //断点续传之前，一定要先遍历一下相册，否则等待任务会找不到待缓存的asset
            [[NTESAlbumService shareInstance] videoGroupsWithAscending:NO
                                                       withMinDuration:0.f
                                                              complete:^(NSArray<NTESAlbumGroupEntity *> *groups)
             {
                 if (complete) {
                     complete(nil);
                 }
             }];
        }
    }];
}

//获取网络数据
- (void)doLoadServerData:(NTESUpdateLoadServerDataBlock)complete
{
    [[NTESDaoService sharedService] requestQueryVideoInfoWithType:0
                                                       completion:^(NSError *error, NSArray<NTESVideoEntity *> *infos) {
        if (complete) {
            complete(error, infos);
        }
    }];
}

//删除网络数据
- (void)doDeleteServerDataWithVid:(NSString *)vid
                         complete:(NTESUpdateDeleteServerDataBlock)complete
{
    [[NTESDaoService sharedService] requestDelVideoWithVid:vid
                                                    format:nil
                                                completion:^(NSError *error) {
                                                    
        if (complete)
        {
            complete(error);
        }
    }];
}

//是否超过了最大上传数
- (void)doBeyondMaxVideo:(BOOL)isBeyond
{
    self.updateBtn.enabled = !isBeyond;
}

@end
