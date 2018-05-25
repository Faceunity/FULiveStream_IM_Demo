//
//  NTESShortVideoHomeVC.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/5/3.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESShortVideoHomeVC.h"
#import "NTESNoneNetTip.h"
#import "NTESRecordVC.h"
#import "NTESDaoService+Update.h"

NSString *const kNtesAddShortVideoEntity = @"kNtesAddShortVideoEntity";

@interface NTESShortVideoHomeVC ()

@property (nonatomic, strong) UIButton *recordBtn;

@property (nonatomic, strong) NTESNoneNetTip *noneNetView;

@end

@implementation NTESShortVideoHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNtesAddShortVideoEntity object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self configNavigationBar];
}

- (void)configNavigationBar {
    UIImage *backImg = [UIImage imageWithColor:UIColorFromRGB(0xf7f7f9) size:CGSizeMake(100, 100)];
    [self.navigationController.navigationBar setBackgroundImage:backImg forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
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

#pragma mark - Action && Notication
- (void)goRecordVC
{
    //权限申请
    __weak typeof(self) weakSelf = self;
    [NTESAuthorizationHelper requestMediaCapturerAccessWithHandler:^(NSError *error) {
        if (error)
        {
            [UIAlertView showMessage:@"请开启照相机/麦克风权限"];
        }
        else
        {
            [NTESAuthorizationHelper requestAblumAuthorityWithCompletionHandler:^(NSError *error) {
                if (error)
                {
                    [UIAlertView showMessage:@"请开启照片权限"];
                }
                else
                {
                    NTESRecordVC *push = [[NTESRecordVC alloc] init];
                    [weakSelf.navigationController pushViewController:push animated:YES];
                }
            }];
        }
    }];
}

- (void)onAddUpdateEntity:(NSNotification *)note
{
    NSLog(@"current thread = %@", [NSThread currentThread]);

    NTESVideoEntity *item = [note object];
    if (!self.waitDatas) {
        self.waitDatas = [NSMutableArray array];
    }
    [self.waitDatas addObject:item];
}

#pragma mark - Getter
- (UIButton *)recordBtn
{
    if (!_recordBtn) {
        _recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordBtn setBackgroundImage:[UIImage imageNamed:@"start_record"] forState:UIControlStateNormal];
        [_recordBtn setBackgroundImage:[UIImage imageNamed:@"start_record_high"] forState:UIControlStateHighlighted];
        [_recordBtn addTarget:self
                       action:@selector(goRecordVC)
             forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordBtn;
}

- (NTESNoneNetTip *)noneNetView
{
    if (!_noneNetView) {
        _noneNetView = [[NTESNoneNetTip alloc] init];
    }
    return _noneNetView;
}

#pragma mark - Reload Function
//指定数据中心
- (NTESUpdateData *)updateDataCenter
{
    return GLobalUpdateShortVideoData;
}

//指定上传队列
- (NTESUpdateQueue *)updateQueue
{
    return GLobalUpdateShortVideoQueue;
}

//初始化子视图
- (void)doInitSubViews
{
    __weak typeof(self) weakSelf = self;
    
    [self.view addSubview:self.recordBtn];
    [self.recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(70.0);
        make.centerX.equalTo(weakSelf.view);
        make.bottom.equalTo(weakSelf.view).mas_offset(-20.0);
    }];
    
    [self.view addSubview:self.noneNetView];
    [self.noneNetView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.width.equalTo(weakSelf.view);
        make.height.mas_equalTo(0);
    }];
    
    [self.view addSubview:self.videoList];
    [self.videoList mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.noneNetView);
        make.top.equalTo(weakSelf.noneNetView.mas_bottom);
        make.bottom.equalTo(weakSelf.recordBtn.mas_top).mas_offset(-20.0);
    }];
    
    [self.view addSubview:self.emptyView];
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.noneNetView.mas_bottom);
        make.bottom.equalTo(weakSelf.videoList.mas_bottom);
    }];
}

- (void)doInitNotication
{
    //通知
    NSLog(@"NTESShortVideoHomeVC self%@", self);
    
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(onAddUpdateEntity:)
                                       name:kNtesAddShortVideoEntity
                                     object:nil];
}

- (void)doShowNoneNetTip:(BOOL)isShow
{
    CGFloat height = (isShow ? 40 : 0);
    
    if (_noneNetView.height == height) {
        return;
    }
    
    [_noneNetView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

//加载网络数据
- (void)doLoadServerData:(NTESUpdateLoadServerDataBlock)complete
{
    [[NTESDaoService sharedService] requestQueryVideoInfoWithType:1
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

@end
