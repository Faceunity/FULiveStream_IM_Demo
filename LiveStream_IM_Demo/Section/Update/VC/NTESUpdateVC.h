//
//  NTESUpdateVC.h
//  NTESUpadateUI
//
//  Created by Netease on 17/2/24.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESBaseVC.h"
#import "NTESUpdateDataCenter.h"
#import "NTESUpdateService.h"
#import "NTESUpdateEmptyView.h"

typedef void(^NTESUpdateLoadServerDataBlock)(NSError *error, NSArray<NTESVideoEntity *> *infos);
typedef void(^NTESUpdateDeleteServerDataBlock)(NSError *error);

@interface NTESUpdateVC : NTESBaseVC

@property (nonatomic, strong) NSMutableArray<NTESVideoEntity *> *netDatas;  //网络数据

@property (nonatomic, strong) NSMutableArray<NTESVideoEntity *> *locDatas;  //本地数据

@property (nonatomic, strong) NSMutableArray<NTESVideoEntity *> *waitDatas; //等待数据

@property (nonatomic, strong) UITableView *videoList;         //上传列表视图

@property (nonatomic, strong) NTESUpdateEmptyView *emptyView; //空视图

#pragma mark - 子类重载

@property (nonatomic, strong) NTESUpdateData *updateDataCenter; //数据中心，必须重载

@property (nonatomic, strong) NTESUpdateQueue *updateQueue;     //上传队列，必须重载

- (void)doInitSubViews;   //初始化子视图，可选重载

- (void)doInitNotication; //初始化通知，可选重载

- (void)doInitBeforeUpdateDatasFromBreak:(void (^)(NSError *error))complete; //断点续传之前的其他任务，可选重载

- (void)doLoadServerData:(NTESUpdateLoadServerDataBlock)complete; //加载网络数据

- (void)doDeleteServerDataWithVid:(NSString *)vid
                         complete:(NTESUpdateDeleteServerDataBlock)complete; //删除网络数据

- (void)doBeyondMaxVideo:(BOOL)isBeyond; //是否超过最大上传视频数，可选重载

- (void)doShowNoneNetTip:(BOOL)isShow; //是否显示无网络提示，可选重载

@end
