//
//  NTESUpdateDetailVC.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/3/10.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESUpdateDetailVC.h"
#import "NTESUpdateDetailHeader.h"
#import "NTESUpdateDetailThumbCell.h"
#import "NTESUpdateDetailTitleCell.h"
#import "NTESUpdateDetailOriCell.h"
#import "NTESUpdateDetailStateCell.h"

#import "NTESVideoEntity.h"
#import "NTESVideoFormatEntity.h"

#import "NTESDaoService+Update.h"
#import "NTESUpdateService.h"

#import "NTESDemandPlayVC.h"

@interface NTESUpdateDetailVC () <UITableViewDelegate, UITableViewDataSource, NTESUpdateDetailOriCellProtocol, NTESUpdateDetailStateCellProtocol>

@property (nonatomic, strong) UITableView *list;

@property (nonatomic, strong) NTESVideoEntity *entity;

@property (nonatomic, strong) NSMutableArray <NTESVideoFormatEntity *> *datas; //首项是源信息，其他是转码信息

@end

@implementation NTESUpdateDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initSubviews];
    
    [self loadVideoInfo];
    
    //上传队列查询转码状态通知
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(updateQueryChanged:)
                                       name:NTES_UPDATEQUEUE_QUERY_NOTE
                                     object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (instancetype)initWithEntity:(NTESVideoEntity *)entity
{
    if (self = [super init]) {
        _entity = entity;
        _datas = [self formatItemsWithVideoItem:entity];
    }
    return self;
}

- (void)initSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItems = nil;
    self.title = @"视频详情";
    [self.view addSubview:self.list];
    
    __weak typeof(self) weakSelf = self;
    [self.list mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
}

#pragma mark - 数据
- (void)loadVideoInfo
{
    //更新信息
    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    [[NTESDaoService sharedService] requestQueryVideoInfoWithVid:_entity.vid completion:^(NSError *error, NSArray<NTESVideoEntity *> *infos) {
        
        [SVProgressHUD dismiss];
        
        if (!error) {
            //更新缓存
            NTESVideoEntity *item = infos.lastObject;
            if (item)
            {
                weakSelf.entity = item;
                weakSelf.datas = [weakSelf formatItemsWithVideoItem:weakSelf.entity];
                [weakSelf.list reloadData];
            }
        }
        else
        {
            NSString *msg = @"视频信息查询失败";
            if (error.code == 1644) {
                msg = @"视频已被删除";
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:msg
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles: nil];
            [alert showAlertWithCompletionHandler:^(NSInteger index) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        }
    }];
}

- (NSMutableArray <NTESVideoFormatEntity *>*)formatItemsWithVideoItem:(NTESVideoEntity *)video
{
    NSMutableArray *array = [NSMutableArray array];
    
    if (video.state == NTESVideoItemTransCoding || video.state == NTESVideoItemTransCodeFail) //这两个阶段需要全部都显示出来
    {
        NTESVideoFormatEntity *format1 = [NTESVideoFormatEntity new];
        format1.format = NTESVideoFormatSHDMP4;
        format1.url = video.shdMp4Url;
        format1.size = video.shdMp4Size;
        [array addObject:format1];
        
        NTESVideoFormatEntity *format2 = [NTESVideoFormatEntity new];
        format2.format = NTESVideoFormatHDFLV;
        format2.url = video.hdFlvUrl;
        format2.size = video.hdFlvSize;
        [array addObject:format2];
        
        NTESVideoFormatEntity *format3 = [NTESVideoFormatEntity new];
        format3.format = NTESVideoFormatSDHLS;
        format3.url = video.sdHlsUrl;
        format3.size = video.sdHlsSize;
        [array addObject:format3];
    }
    else
    {
        if (video.shdMp4Url)
        {
            NTESVideoFormatEntity *format1 = [NTESVideoFormatEntity new];
            format1.format = NTESVideoFormatSHDMP4;
            format1.url = video.shdMp4Url;
            format1.size = video.shdMp4Size;
            [array addObject:format1];
        }
        
        if (video.hdFlvUrl)
        {
            NTESVideoFormatEntity *format2 = [NTESVideoFormatEntity new];
            format2.format = NTESVideoFormatHDFLV;
            format2.url = video.hdFlvUrl;
            format2.size = video.hdFlvSize;
            [array addObject:format2];
        }
        
        if (video.sdHlsUrl)
        {
            NTESVideoFormatEntity *format3 = [NTESVideoFormatEntity new];
            format3.format = NTESVideoFormatSDHLS;
            format3.url = video.sdHlsUrl;
            format3.size = video.sdHlsSize;
            [array addObject:format3];
        }
    }
    return array;
}

#pragma mark - Fuction
- (void)doStartPlayWithName:(NSString *)name url:(NSString *)url
{
    if (url == nil) {
        [self.view makeToast:@"播放地址为空" duration:2 position:CSToastPositionCenter];
        return;
    }
    if (name == nil) {
        name = [url.lastPathComponent stringByDeletingPathExtension];
    }
    
    NTESDemandPlayVC *push =  [[NTESDemandPlayVC alloc] initWithName:name url:url];
    [self.navigationController pushViewController:push animated:YES];
}

- (void)doShareUrl:(NSString *)url
{
//    [SVProgressHUD showSuccessWithStatus:@"点播地址已复制，请到第三方播放器中打开，或分享给好友"];
    [self.view makeToast:@"点播地址已复制，请到第三方播放器中打开，或分享给好友" duration:2 position:CSToastPositionCenter];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = url;
    
}

- (void)doDeleteVideo:(NTESVideoFormat)format complete:(void(^)())complete
{
    NSString *formatStr = [NSString stringWithFormat:@"%zi", format];
    
    [SVProgressHUD show];
    __weak typeof(self) weakSelf = self;
    [[NTESDaoService sharedService] requestDelVideoWithVid:_entity.vid format:formatStr completion:^(NSError *error) {
        
        [SVProgressHUD dismiss];
        
        if (error) {
            NSLog(@"删除失败, %@", error);
        }
        else
        {
            [weakSelf.datas enumerateObjectsUsingBlock:^(NTESVideoFormatEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.format == format) {
                    [weakSelf.datas removeObject:obj];
                    *stop = YES;
                }
            }];
            
            if (complete) {
                complete();
            }
        }
    }];
}

#pragma mark - Action
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
            if ([vid isEqualToString:_entity.vid])
            {
                NSLog(@"当前状态：%zi", dic[@"state"]);
                [self loadVideoInfo];
            }
        }
    }
}

#pragma mark - <NTESUpdateDetailOriCellProtocol>
- (void)oriCell:(NTESUpdateDetailOriCell *)cell playName:(NSString *)name url:(NSString *)playUrl
{
    NSLog(@"播放 url = [%@]", playUrl);
    
    __weak typeof(self) weakSelf = self;
    [[RealReachability sharedInstance] reachabilityWithBlock:^(ReachabilityStatus status) {
        if (status == RealStatusNotReachable) {
            [weakSelf.view makeToast:@"无网络，请检查网络设置" duration:2 position:CSToastPositionCenter];
        }
        else if (status == RealStatusViaWWAN)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"正在使用手机流量，是否继续？"
                                                               delegate:nil
                                                      cancelButtonTitle:@"否"
                                                      otherButtonTitles:@"是", nil];
        
            [alertView showAlertWithCompletionHandler:^(NSInteger index) {
                if (index == 1) {
                    [weakSelf doStartPlayWithName:name url:playUrl];
                }
            }];
        }
        else
        {
            [weakSelf doStartPlayWithName:name url:playUrl];
        }
    }];
}

- (void)oriCell:(NTESUpdateDetailOriCell *)cell share:(NSString *)shareUrl
{
    NSLog(@"分享 url = [%@]", shareUrl);

    [self doShareUrl:shareUrl];
}

#pragma mark - <NTESUpdateDetailStateCellProtocol>
- (void)stateCell:(NTESUpdateDetailStateCell *)cell playName:(NSString *)name url:(NSString *)playUrl
{
    NSLog(@"播放 url = [%@]", playUrl);
    
    __weak typeof(self) weakSelf = self;
    [[RealReachability sharedInstance] reachabilityWithBlock:^(ReachabilityStatus status) {
        if (status == RealStatusNotReachable) {
            [weakSelf.view makeToast:@"无网络，请检查网络设置" duration:2 position:CSToastPositionCenter];
        }
        else if (status == RealStatusViaWWAN)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:@"正在使用手机流量，是否继续？"
                                                               delegate:nil
                                                      cancelButtonTitle:@"否"
                                                      otherButtonTitles:@"是", nil];
            
            [alertView showAlertWithCompletionHandler:^(NSInteger index) {
                if (index == 1) {
                    [weakSelf doStartPlayWithName:name url:playUrl];
                }
            }];
        }
        else
        {
            [weakSelf doStartPlayWithName:name url:playUrl];
        }
    }];
}

- (void)stateCell:(NTESUpdateDetailStateCell *)cell share:(NSString *)shareUrl
{
    NSLog(@"分享 url = [%@]", shareUrl);
    
    [self doShareUrl:shareUrl];
}

- (void)stateCell:(NTESUpdateDetailStateCell *)cell delFormat:(NTESVideoFormat)format
{
    NSLog(@"删除类型 : %zi", format);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"确定删除该视频，删除后不可恢复"
                                                       delegate:nil
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    
    __weak typeof(self) weakSelf = self;
    [alertView showAlertWithCompletionHandler:^(NSInteger index) {
        if (index == 1)
        {
            [weakSelf doDeleteVideo:format complete:^{
                NSIndexPath *indexPath = [weakSelf.list indexPathForCell:cell];
                if (weakSelf.datas.count == 0) {
                    
                    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndex:indexPath.section];
                    [weakSelf.list deleteSections:indexSet withRowAnimation:UITableViewRowAnimationLeft];
                }
                else
                {
                    NSIndexPath *indexPath = [weakSelf.list indexPathForCell:cell];
                    [weakSelf.list deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                }
            }];
        }
    }];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (_datas.count == 0 ? 3 : 4);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == 3 ? _datas.count : 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) //微缩图
    {
        NTESUpdateDetailThumbCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NTESUpdateDetailThumbCell"
                                                                          forIndexPath:indexPath];
        [cell configCellWithImage:_entity.thumbImg imgUrl:_entity.thumbImgUrl];
        return cell;
    }
    else if (indexPath.section == 1 && indexPath.row == 0) //标题
    {
        NTESUpdateDetailTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NTESUpdateDetailTitleCell"];
        cell.textLabel.text = _entity.title;
        return cell;
    }
    else if (indexPath.section == 2 && indexPath.row == 0) //源格式
    {
        NTESUpdateDetailOriCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NTESUpdateDetailOriCell"
                                                                        forIndexPath:indexPath];
        [cell configCellWithItem:_entity delegate:self];
        return cell;
    }
    else if (indexPath.section == 3) //转码格式
    {
        NTESUpdateDetailStateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NTESUpdateDetailStateCell"
                                                                          forIndexPath:indexPath];
        NTESVideoFormatEntity *format = _datas[indexPath.row];
        [cell configCellWithFormatItem:format state:_entity.state delegate:self];
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell"
                                                                forIndexPath:indexPath];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        return 212;
    }
    else if (indexPath.section == 1 && indexPath.row == 0)
    {
        return 50.0;
    }
    else if (indexPath.section == 2 && indexPath.row == 0)
    {
        return 175.0;
    }
    else  if (indexPath.section == 3)
    {
        return 175.0;
    }
    else
    {
        return CGFLOAT_MIN;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == 0 ? CGFLOAT_MIN : 44.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *titles = @[@"标题", @"源格式", @"转码格式"];
    NSString *title = @"";
    if (section - 1 >= 0 && section - 1 < titles.count) {
        title = titles[section - 1];
    }
    NTESUpdateDetailHeader *header = [[NTESUpdateDetailHeader alloc] initWithTitle:title];
    return header;
}

#pragma mark - Getter
- (UITableView *)list
{
    if (!_list) {
        _list = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) style:UITableViewStyleGrouped];
        _list.delegate = self;
        _list.dataSource = self;
        _list.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_list registerClass:[NTESUpdateDetailThumbCell class] forCellReuseIdentifier:@"NTESUpdateDetailThumbCell"];
        [_list registerClass:[NTESUpdateDetailTitleCell class] forCellReuseIdentifier:@"NTESUpdateDetailTitleCell"];
        [_list registerClass:[NTESUpdateDetailOriCell class] forCellReuseIdentifier:@"NTESUpdateDetailOriCell"];
        [_list registerClass:[NTESUpdateDetailStateCell class] forCellReuseIdentifier:@"NTESUpdateDetailStateCell"];
        [_list registerClass:[UITableViewCell class] forCellReuseIdentifier:@"defaultCell"];
    }
    return _list;
}

@end
