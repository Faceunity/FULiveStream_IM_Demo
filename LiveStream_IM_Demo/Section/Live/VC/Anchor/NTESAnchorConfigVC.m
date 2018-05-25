//
//  NTESAnchorConfigVC.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/1/10.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESAnchorConfigVC.h"
#import "NTESAnchorConfigCell.h"
#import "NTESLiveStreamVC.h"
#import "NTESLiveDataCenter.h"
#import "NTESDaoService.h"
#import "NTESChatroomManger.h"
#import "NTESChatroomDataCenter.h"

@interface NTESAnchorConfigVC () <UITableViewDelegate, UITableViewDataSource, NTESAnchorConfigCellProtocol, NTESActionSheetDelegate>

//页面控件
@property (nonatomic, strong) UITableView *listView;
@property (nonatomic, strong) UIButton *enterBtn;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress; //长按手势，用于查询配置信息

//页面数据
@property (nonatomic, assign) BOOL openVideo;
@property (nonatomic, assign) BOOL openAudio;
@property (nonatomic, strong) NSArray *sharpnessTitles;
@property (nonatomic, assign) NSInteger sharpnessIndex;

@end

@implementation NTESAnchorConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"推流配置";
    self.navigationItem.leftBarButtonItems = nil;
    
    [self initConfigData];
    
    [self initSubViews];
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

#pragma mark - Private
- (void)initConfigData
{
    //推流类型
    _openVideo = YES;
    _openAudio = YES;
    _openAudio = (([NTESLiveDataCenter shareInstance].pParaCtx.eOutStreamType != LS_HAVE_VIDEO) && ![NTESLiveDataCenter shareInstance].isPushOnlyVideo);
    _openVideo = ([NTESLiveDataCenter shareInstance].pParaCtx.eOutStreamType != LS_HAVE_AUDIO);

    //清晰度
    _sharpnessTitles = @[@"流畅", @"标清", @"高清"];
    LSVideoStreamingQuality quality = [NTESLiveDataCenter shareInstance].pParaCtx.sLSVideoParaCtx.videoStreamingQuality;
    _sharpnessIndex = [self sharpnessIndexWithParaCtx:quality];
}

- (void)initSubViews
{
    [self.view addSubview:self.listView];
    __weak typeof(self) weakSelf = self;
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
}

//sdk视频流参数和选项映射
- (NSInteger)sharpnessIndexWithParaCtx:(LSVideoStreamingQuality)quality
{
    NSInteger index = 0;
    
    switch (quality) {
        case LS_VIDEO_QUALITY_LOW:
        {
            index = 0;
            break;
        }
        case LS_VIDEO_QUALITY_HIGH:
        {
            index = 1;
            break;
        }
        case LS_VIDEO_QUALITY_SUPER:
        {
            index = 2;
            break;
        }
        default:
        {
            index = 0;
            break;
        }
    }
    return index;
}

- (LSVideoStreamingQuality)paraCtxWithSharpnessIndex:(NSInteger)index
{
    LSVideoStreamingQuality quality = LS_VIDEO_QUALITY_LOW;
    switch (index) {
        case 0:
        {
            quality = LS_VIDEO_QUALITY_LOW;
            break;
        }
        case 1:
        {
            quality = LS_VIDEO_QUALITY_HIGH;
            break;
        }
        case 2:
        {
            quality = LS_VIDEO_QUALITY_SUPER;
            break;
        }
        default:
            break;
    }
    return quality;
}


#pragma mark - Getter/Setter
- (UITableView *)listView
{
    if (!_listView) {
        _listView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _listView.delegate = self;
        _listView.dataSource = self;
        _listView.alwaysBounceVertical = NO;
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_listView setSeparatorInset:UIEdgeInsetsZero];
        [_listView setLayoutMargins:UIEdgeInsetsZero];
        [_listView registerClass:[NTESAnchorConfigCell class] forCellReuseIdentifier:@"cell"];
    }
    return _listView;
}

- (UIButton *)enterBtn
{
    if (!_enterBtn) {
        _enterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_enterBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_enterBtn setBackgroundImage:[UIImage imageNamed:@"按钮 正常"] forState:UIControlStateNormal];
        [_enterBtn setBackgroundImage:[UIImage imageNamed:@"按钮 按下"] forState:UIControlStateHighlighted];
        [_enterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_enterBtn addTarget:self action:@selector(enterBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _enterBtn.enabled = (_openAudio || _openVideo);;
    }
    return _enterBtn;
}

- (UILongPressGestureRecognizer *)longPress
{
    if (!_longPress) {
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
        _longPress.minimumPressDuration = 2.0;
        _longPress.numberOfTouchesRequired = 1;
    }
    return _longPress;
}

- (void)setSharpnessIndex:(NSInteger)sharpnessIndex
{
    if (sharpnessIndex >= 0 && sharpnessIndex < _sharpnessTitles.count)
    {
        LSVideoStreamingQuality quality = [self paraCtxWithSharpnessIndex:sharpnessIndex];
        
        [NTESLiveDataCenter shareInstance].pParaCtx.sLSVideoParaCtx.videoStreamingQuality = quality;
        
        _sharpnessIndex = sharpnessIndex;
    }
}

- (void)setOpenAudio:(BOOL)openAudio
{
    _openAudio = openAudio;
    
    if (_openAudio && _openVideo)
    {
        [NTESLiveDataCenter shareInstance].pParaCtx.eOutStreamType = LS_HAVE_AV;
        [NTESLiveDataCenter shareInstance].isPushOnlyVideo = NO;
    }
    else if (_openAudio && !_openVideo)
    {
        [NTESLiveDataCenter shareInstance].pParaCtx.eOutStreamType = LS_HAVE_AUDIO;
        [NTESLiveDataCenter shareInstance].isPushOnlyVideo = NO;
    }
    else if (!_openAudio && _openVideo)
    {
        [NTESLiveDataCenter shareInstance].pParaCtx.eOutStreamType = LS_HAVE_AV;
        [NTESLiveDataCenter shareInstance].isPushOnlyVideo = YES;
    }
    else
    {}
}

- (void)setOpenVideo:(BOOL)openVideo
{
    _openVideo = openVideo;
    
    if (_openAudio && _openVideo)
    {
        [NTESLiveDataCenter shareInstance].pParaCtx.eOutStreamType = LS_HAVE_AV;
        [NTESLiveDataCenter shareInstance].isPushOnlyVideo = NO;
    }
    else if (_openAudio && !_openVideo)
    {
        [NTESLiveDataCenter shareInstance].pParaCtx.eOutStreamType = LS_HAVE_AUDIO;
        [NTESLiveDataCenter shareInstance].isPushOnlyVideo = NO;
    }
    else if (!_openAudio && _openVideo)
    {
        [NTESLiveDataCenter shareInstance].pParaCtx.eOutStreamType = LS_HAVE_AV;
        [NTESLiveDataCenter shareInstance].isPushOnlyVideo = YES;
    }
    else
    {}
}

#pragma mark - Action
- (void)enterBtnAction:(UIButton *)btn
{
    NSLog(@"进入直播");
    
    //进入聊天室
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD show];
    [[NTESChatroomManger shareInstance] anchorEnterChatroom:^(NSError *error, NSString *roomId) {
        [SVProgressHUD dismiss];
        if (error)
        {
            NSString *cause = (error.userInfo[NTES_ERROR_MSG_KEY] ?: @"");
            NSString *toast = [NSString stringWithFormat:@"进入聊天室失败: %@", cause];
            [weakSelf.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
        }
        else
        {
            NTESLiveStreamVC *push = [[NTESLiveStreamVC alloc] initWithChatroomId:roomId];
            push.pushUrl = [NTESLiveDataCenter shareInstance].pushUrl;
            [weakSelf presentViewController:push animated:YES completion:nil];
        }
    }];
}

- (void)longPressAction:(UILongPressGestureRecognizer *)longPress
{
    if(longPress.state == UIGestureRecognizerStateBegan)
    {
        NSString *msg = [[NTESLiveDataCenter shareInstance] liveStreamConfigInfo];
        [UIAlertView showMessage:msg];
    }
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else if (section == 1)
    {
        return 2;
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NTESAnchorConfigCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.delegate = self;

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [cell config:@"音频" switchIsOn:_openAudio];
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0) {
            [cell config:@"视频" switchIsOn:_openVideo];
        }
        else if (indexPath.row == 1) {
            [cell config:@"清晰度" accessory:_sharpnessTitles[_sharpnessIndex]];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 10.0;
    }
    else
    {
        return CGFLOAT_MIN;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 10;
    }
    else if (section == 1)
    {
        return 80.0;
    }
    else
    {
        return CGFLOAT_MIN;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 80.0)];
    [view addSubview:self.enterBtn];
    [self.enterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view).insets(UIEdgeInsetsMake(16.0, 32.0, 16.0, 32.0));
    }];
    
    [view addGestureRecognizer:self.longPress];
    
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 1) //清晰度
    {
        NTESAnchorConfigCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        NTESActionSheet *actionSheet = [[NTESActionSheet alloc] initWithTitle:nil
                                                                 delegate:nil
                                                        cancelButtonTitle:@"取消"
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:_sharpnessTitles];
        
        __weak typeof(self) weakSelf = self;
        [actionSheet showInView:self.view completionHandler:^(NSInteger index) {
            if (index != weakSelf.sharpnessTitles.count)
            {
                //更新UI
                [cell config:@"清晰度" accessory:_sharpnessTitles[index]];
                
                //更新数据
                weakSelf.sharpnessIndex = index;
            }
        }];
    }
}

#pragma mark - <NTESAnchorConfigCellProtocol>
//开关事件
- (void)configCell:(NTESAnchorConfigCell *)cell switchIsOn:(BOOL)isOn
{
    NSIndexPath *indexPath = [_listView indexPathForCell:cell];
    
    if (indexPath.section == 0)
    {
        self.openAudio = isOn;
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            self.openVideo = isOn;
        }
    }
    
    _enterBtn.enabled = (_openAudio || _openVideo);
    
}

@end
