//
//  NTESPlayStreamVC.m
//  NEUIDemo
//
//  Created by Netease on 17/1/3.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESPlayStreamVC.h"
#import "NTESTextMessage.h"
#import "NTESPresentMessage.h"

#import "NTESChatView.h"
#import "NTESLikeView.h"
#import "NTESAudienceBottomBar.h"
#import "NTESAudienceTopBar.h"
#import "NTESEndView.h"
#import "NTESTextInputView.h"

#import "NTESSessionMsgConverter.h"
#import "NTESPresentAttachment.h"
#import "NTESLikeAttachment.h"
#import "NTESChatroomDataCenter.h"
#import "NTESChatroomManger.h"
#import "NTESPresentManger.h"
#import "NTESLiveDataHelper.h"

@interface NTESPlayStreamVC ()< NTESAudienceBottomBarProtocol,
                                NTESAudienceTopBarProtocol,
                                NTESTextInputViewDelegate,
                                NTESEndViewProtocol,
                                NTESLikeViewProtocol,
                                NIMChatroomManagerDelegate,
                                NIMChatManagerDelegate >
{
    BOOL _needIM;
    BOOL _needPlay;
}
@property (nonatomic, strong) ALAssetsLibrary *assetLibrary; //图库
@property (nonatomic, strong) NTESChatView *chatView;   //聊天视图
@property (nonatomic, strong) NTESLikeView *likeView;   //爱心视图
@property (nonatomic, strong) NTESAudienceBottomBar *bottomBar; //底部工具栏
@property (nonatomic, strong) NTESAudienceTopBar *topBar;       //顶部工具栏
@property (nonatomic, strong) NTESEndView *endView;       //播放完成视图
@property (nonatomic, strong) YYAnimatedImageView *backImageView; //背景图片（音频时使用）
@property (nonatomic, strong) NTESTextInputView *textInputView; //输入框
@property (nonatomic, strong) UIView *containerView; //播放器包裹视图

@end

@implementation NTESPlayStreamVC

- (void)dealloc
{
    if (_needIM)
    {
        [[NIMSDK sharedSDK].chatroomManager removeDelegate:self];
        [[NIMSDK sharedSDK].chatManager removeDelegate:self];
    }
}

- (instancetype)initWithChatroomid:(NSString *)chatroomId pullUrl:(NSString *)pullUrl
{
    if (self = [super init]) {
        self.roomId = chatroomId;
        self.pullUrl = pullUrl;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self checkParam];
    
    [self setupSubviews:_needIM];
    
    [self constraintSubViews:_needIM];
    
    if (_needIM)
    {
        [self setupIM];
    }
    
    if (_needPlay)
    {
        [self setupPlay];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.bottomBar dismissPresentShop];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.endView.frame = self.view.bounds;
}

#pragma mark - 私有
- (void)checkParam
{
    //参数防范
    _needIM = (self.roomId != nil);
    _needPlay = (self.pullUrl != nil);
    if (!_needIM) {
        [self.view makeToast:@"房间号为空，进入点播模式" duration:2.0 position:CSToastPositionCenter];
    }
    if (!_needPlay) {
        [self.view makeToast:@"拉流地址为空，请退出" duration:2.0 position:CSToastPositionCenter];
    }
}

- (void)setupSubviews:(BOOL)needIM
{
    self.view.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.containerView];
    [self.view addSubview:self.backImageView];
    [self.view addSubview:self.topBar];
    
    if (needIM)
    {
        [self.view addSubview:self.bottomBar];
        [self.view addSubview:self.textInputView];
        [self.view addSubview:self.chatView];
        [self.view addSubview:self.likeView];
    }
}

- (void)constraintSubViews:(BOOL)needIM
{
    __weak typeof(self) weakSelf = self;
    [self.backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf.view);
        make.width.height.mas_equalTo(130.0);
    }];
    
    [self.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view).with.offset(8.0);
        make.left.right.equalTo(weakSelf.view);
        make.height.mas_equalTo(72.0);
    }];
    
    if (needIM)
    {
        [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(weakSelf.view);
            make.height.mas_equalTo(55.0);
        }];
        
        [self.textInputView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(weakSelf.view);
            make.height.mas_equalTo(36.0);
        }];
        
        [self.chatView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.view);
            make.bottom.equalTo(weakSelf.bottomBar.mas_top);
            make.height.mas_equalTo(200.0);
            make.width.mas_equalTo(200.0 * UISreenWidthScale);
        }];
        
        [self.likeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(weakSelf.view);
            make.bottom.equalTo(weakSelf.chatView).with.offset(-8.0);
            make.height.mas_equalTo(300.0);
            make.width.mas_equalTo(50.0);
        }];
    }
}

- (void)setupIM
{
    [[NIMSDK sharedSDK].chatroomManager addDelegate:self];
    [[NIMSDK sharedSDK].chatManager addDelegate:self];
    
    //获取主播信息
    __weak typeof(self) weakSelf = self;
    [[NTESChatroomManger shareInstance] requestAnchorInfoWithRoomId:_roomId complete:^(NSError *error, NTESMember *member) {
        
        if (error)
        {
            NSString *toast = [NSString stringWithFormat:@"获取主播信息失败，code = %zi", error.code];
            [weakSelf.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
        }
        else
        {
            [weakSelf.topBar refreshBarWithCreator:member];
            
            [weakSelf.endView configEndView:member.avatarUrlString
                                       name:member.showName
                                    message:@"直播已结束"
                                 hiddenBack:NO];
        }
    }];
    
    //获取观众信息
    [[NTESChatroomManger shareInstance] requestRefreshMemberWithRoomId:_roomId complete:^(NSError *error) {
        
        if (error)
        {
            NSString *toast = [NSString stringWithFormat:@"获取观众信息失败，code = %zi", error.code];
            [weakSelf.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
        }
        else
        {
            NSArray *members = [[NTESChatroomDataCenter sharedInstance] membersWithRoomId:weakSelf.roomId];
            [weakSelf.topBar refreshBarWithAudiences:members];
        }
    }];
    
    //定时刷新通知
    
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(timerRefreshMember:)
                                       name:ChatMangerRefreshMemberNotiction
                                     object:nil];
    
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(timerRefreshRoomInfo:)
                                       name:ChatMangerRefreshRoomInfoNotiction
                                     object:nil];
}

- (void)setupPlay
{
    if ([RealReachability sharedInstance].currentReachabilityStatus == RealStatusViaWWAN)
    {
        //提示用户
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:@"正在使用手机流量，是否继续？"
                                                       delegate:nil
                                              cancelButtonTitle:@"是"
                                              otherButtonTitles:@"否", nil];
        __weak typeof(self) weakSelf = self;
        [alert showAlertWithCompletionHandler:^(NSInteger index) {
            if (index == 0)
            {
                [weakSelf startPlay:_pullUrl inView:self.containerView isFull:YES];
            }
        }];
    }
    else
    {
        [self startPlay:_pullUrl inView:self.containerView isFull:YES];
    }
}


//接收到文字信息
- (void)doReceiveTextMessage:(NIMMessage *)message
{
    __weak typeof(self) weakSelf = self;
    [[NTESChatroomManger shareInstance] requestMemberInfoWithRoomId:message.session.sessionId memberId:@
     [message.from] complete:^(NSError *error, NSArray<NTESMember *> *members) {
         NTESMember *member = members.firstObject;
         NTESTextMessage *msg = [NTESTextMessage textMessage:message.text sender:member];
         [weakSelf.chatView addNormalMessages:@[msg]];
     }];
}

//接收到礼物信息
- (void)doReceivePresentMessage:(NIMMessage *)message
{
    NIMCustomObject *object = message.messageObject;
    id<NIMCustomAttachment> attachment = object.attachment;
    if ([attachment isKindOfClass:[NTESPresentAttachment class]]) //礼物消息
    {
        //显示礼物信息
        NTESPresentMessage *presentMessage = [[NTESPresentMessage alloc] initWithNIMPresentMessage:message];
        [self.chatView addPresentMessage:presentMessage];
    }
    else if ([attachment isKindOfClass:[NTESLikeAttachment class]]) //点赞消息
    {
        [self.likeView fireLike];
    }
}

- (void)doReceiveSystemMessage:(NIMMessage *)message
{
    NIMNotificationObject *object = (NIMNotificationObject *)message.messageObject;
    if (object.notificationType == NIMNotificationTypeChatroom)
    {
        NIMChatroomNotificationContent *content = (NIMChatroomNotificationContent *)object.content;
        switch (content.eventType)
        {
            case NIMChatroomEventTypeEnter:
            {
                NSLog(@"成员进入");
                NSArray *memberIds = @[content.source.userId];
                __weak typeof(self) weakSelf = self;
                [[NTESChatroomManger shareInstance] requestMemberInfoWithRoomId:_roomId memberId:memberIds complete:^(NSError *error, NSArray<NTESMember *> *members) {
                    
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    
                    //刷新聊天信息
                    NTESTextMessage *message = [NTESTextMessage systemMessage:@"进入直播室" from:content.source.nick];
                    [strongSelf.chatView addNormalMessages:@[message]];
                    
                    //刷新观众头像
                    [[NTESChatroomDataCenter sharedInstance] memberListAddMembers:members roomId:strongSelf.roomId];
                    NSArray *memberDatas = [[NTESChatroomDataCenter sharedInstance] membersWithRoomId:strongSelf.roomId];
                    [weakSelf.topBar refreshBarWithAudiences:memberDatas];
                }];
                break;
            }
            case NIMChatroomEventTypeExit:
            {
                NSLog(@"成员退出");
                NSArray *memberIds = @[content.source.userId];
                __weak typeof(self) weakSelf = self;
                [[NTESChatroomManger shareInstance] requestMemberInfoWithRoomId:_roomId memberId:memberIds complete:^(NSError *error, NSArray<NTESMember *> *members) {
                    
                    NIMChatroomMember *me = [[NTESChatroomDataCenter sharedInstance] myInfo:weakSelf.roomId];
                    if (![content.source.userId isEqualToString:me.userId])
                    {
                        //刷新聊天信息
                        NTESTextMessage *message = [NTESTextMessage systemMessage:@"退出直播室" from:content.source.nick];
                        [weakSelf.chatView addNormalMessages:@[message]];
                        
                        //刷新观众头像
                        [[NTESChatroomDataCenter sharedInstance] memberListDelMembers:members roomId:weakSelf.roomId];
                        NSArray *memberDatas = [[NTESChatroomDataCenter sharedInstance] membersWithRoomId:weakSelf.roomId];
                        [weakSelf.topBar refreshBarWithAudiences:memberDatas];
                    }
                }];
                break;
            }
            case NIMChatroomEventTypeAddMute:
            case NIMChatroomEventTypeAddMuteTemporarily:
            {
                NSLog(@"成员被设置禁言");
                
                //刷新观众头像
                NIMChatroomMember *me = [[NTESChatroomDataCenter sharedInstance] myInfo:_roomId];
                
                for (NIMChatroomNotificationMember *meber in content.targets)
                {
                    [[NTESChatroomDataCenter sharedInstance] setMemberMute:YES roomId:_roomId userId:meber.userId];
                    
                    if (meber.userId == me.userId) //自己被禁言了
                    {
                        me.isMuted = YES;
                        [[NTESChatroomDataCenter sharedInstance] cacheMyInfo:me roomId:_roomId];
                    }
                    
                    //系统消息
                    NTESTextMessage *message = [NTESTextMessage systemMessage:@"已被禁言" from:meber.nick];
                    [self.chatView addNormalMessages:@[message]];
                }
                
                NSArray *memberDatas = [[NTESChatroomDataCenter sharedInstance] membersWithRoomId:_roomId];
                [self.topBar refreshBarWithAudiences:memberDatas];
                
                break;
            }
            case NIMChatroomEventTypeRemoveMute:
            case NIMChatroomEventTypeRemoveMuteTemporarily:
            {
                NSLog(@"成员解除禁言");
                
                //刷新观众头像
                NIMChatroomMember *me = [[NTESChatroomDataCenter sharedInstance] myInfo:_roomId];
                for (NIMChatroomNotificationMember *meber in content.targets) {
                    [[NTESChatroomDataCenter sharedInstance] setMemberMute:NO roomId:_roomId userId:meber.userId];
                    
                    if (meber.userId == me.userId) //自己被解禁了
                    {
                        me.isMuted = NO;
                        [[NTESChatroomDataCenter sharedInstance] cacheMyInfo:me roomId:_roomId];
                    }
                    
                    //系统消息
                    NTESTextMessage *message = [NTESTextMessage systemMessage:@"解除禁言" from:meber.nick];
                    [self.chatView addNormalMessages:@[message]];
                }
                NSArray *memberDatas = [[NTESChatroomDataCenter sharedInstance] membersWithRoomId:_roomId];
                [self.topBar refreshBarWithAudiences:memberDatas];
                
                break;
            }
            case NIMChatroomEventTypeKicked:
            {
                NSLog(@"成员被踢");
                NSArray *memberIds = @[content.targets.firstObject.userId];
                
                //系统消息
                NTESTextMessage *message = [NTESTextMessage systemMessage:@"已被踢出" from:content.targets.firstObject.nick];
                [self.chatView addNormalMessages:@[message]];
                
                //刷新观众头像
                __weak typeof(self) weakSelf = self;
                [[NTESChatroomManger shareInstance] requestMemberInfoWithRoomId:_roomId memberId:memberIds complete:^(NSError *error, NSArray<NTESMember *> *members) {
                    [[NTESChatroomDataCenter sharedInstance] memberListDelMembers:members roomId:weakSelf.roomId];
                    NSArray *memberDatas = [[NTESChatroomDataCenter sharedInstance] membersWithRoomId:weakSelf.roomId];
                    [weakSelf.topBar refreshBarWithAudiences:memberDatas];
                }];
                
                break;
            }
            default:
                break;
        }
    }
}

- (void)doExitWithEndView:(NTESEndView *)endView isKicked:(BOOL)isKicked complete:(void(^)())complete
{
    
    [self.view endEditing:YES];
    
    //停止播放
    [self releasePlayer];
    
    __weak typeof(self) weakSelf = self;
    [[NTESChatroomManger shareInstance] audienceExitChatroom:_roomId isKicked:isKicked complete:^(NSError *error) {
        
        if (error) {
            NSLog(@"退出聊天室出错: [%zi]", error.code);
        }
        
        //回调
        if (complete) {
            complete();
        }
        
        //退出
        if (endView)
        {
            if (!weakSelf.view.presentedView) {
                [weakSelf.view presentView:weakSelf.endView animated:YES complete:nil];
            }
        }
        else
        {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

#pragma mark - IM协议
#pragma mark -- <NIMChatroomManagerDelegate>
//被踢回调
- (void)chatroom:(NSString *)roomId beKicked:(NIMChatroomKickReason)reason
{
    BOOL playComplete = NO;
    
    if ([roomId isEqualToString:_roomId])
    {
        NSLog(@"chatroom be kicked, roomId:%@  rease:%zd",roomId,reason);
        NSString *reasonStr = @"未知原因";
        switch (reason)
        {
            case NIMChatroomKickReasonInvalidRoom:
            {
                reasonStr = @"直播已结束";
                playComplete = YES;
                break;
            }
            case NIMChatroomKickReasonByManager:
            {
                reasonStr = @"您已被踢出房间";
                break;
            }
            case NIMChatroomKickReasonBlacklist:
            {
                reasonStr = @"您已被拉进黑名单";
                break;
            }
            case NIMChatroomKickReasonByConflictLogin:
            {
                reasonStr = @"您已在其他端登陆";
                break;
            }
            default:
                break;
        }

        //查找自己的id
        NSString *meId = [NTESLoginManager sharedManager].currentNTESLoginData.accid;
        NSString *roomId = _roomId;
        
        __weak typeof(self) weakSelf = self;
        [[NTESChatroomManger shareInstance] requestMemberInfoWithRoomId:roomId memberId:@[meId] complete:^(NSError *error, NSArray<NTESMember *> *members) {
            NTESMember *member = [members firstObject];
            [weakSelf.endView configEndView:member.avatarUrlString
                                       name:member.showName
                                    message:reasonStr
                                 hiddenBack:!playComplete];
            [weakSelf doExitWithEndView:weakSelf.endView isKicked:YES complete:nil];
        }];
    }
}

- (void)chatroom:(NSString *)roomId connectionStateChanged:(NIMChatroomConnectionState)state;
{
    NSLog(@"chatroom connection state changed roomId : %@  state : %zd",roomId,state);
}

#pragma mark -- <NIMChatManagerDelegate>
- (void)willSendMessage:(NIMMessage *)message
{
    switch (message.messageType)
    {
        case NIMMessageTypeText: //普通消息
        {
            __weak typeof(self) weakSelf = self;
            [[NTESChatroomManger shareInstance] requestMemberInfoWithRoomId:message.session.sessionId memberId:@
             [message.from] complete:^(NSError *error, NSArray<NTESMember *> *members) {
                 NTESMember *member = members.firstObject;
                 NTESTextMessage *msg = [NTESTextMessage textMessage:message.text sender:member];
                 [weakSelf.chatView addNormalMessages:@[msg]];
             }];
            break;
        }
        case NIMMessageTypeCustom: //礼物
        {
            NIMCustomObject *object = message.messageObject;
            id<NIMCustomAttachment> attachment = object.attachment;
            if ([attachment isKindOfClass:[NTESPresentAttachment class]]) {
            
                //显示礼物信息
                NTESPresentMessage *presentMessage = [[NTESPresentMessage alloc] initWithNIMPresentMessage:message];
                [self.chatView addPresentMessage:presentMessage];
            }
        }
            break;
        default:
            break;
    }
}

- (void)onRecvMessages:(NSArray *)messages
{
    for (NIMMessage *message in messages)
    {
        if (![message.session.sessionId isEqualToString:_roomId]
            && message.session.sessionType == NIMSessionTypeChatroom)
        {
            return; //不属于这个聊天室的消息
        }
        switch (message.messageType)
        {
            case NIMMessageTypeText: //普通消息
            {
                [self doReceiveTextMessage:message];
                break;
            }
            case NIMMessageTypeCustom: //礼物信息
            {
                [self doReceivePresentMessage:message];
                break;
            }
            case NIMMessageTypeNotification: //系统消息
            {
                [self doReceiveSystemMessage:message];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Action
- (void)timerRefreshMember:(NSNotification *)note
{
    //观众列表
    NSArray *memberDatas = [[NTESChatroomDataCenter sharedInstance] membersWithRoomId:self.roomId];
    [self.topBar refreshBarWithAudiences:memberDatas];
    NSLog(@"----- 定时刷新了人员列表，本次刷新人数 %zi", memberDatas.count);
}

//定时刷新房间信息
- (void)timerRefreshRoomInfo:(NSNotification *)note
{
    NIMChatroom *room = [[NTESChatroomDataCenter sharedInstance] roomInfo:self.roomId];
    NTESChatroom *ntesRoom = [[NTESChatroom alloc] initWithNITChatroom:room];
    [self.topBar refreshBarWithChatroom:ntesRoom];
    NSLog(@"----- 定时刷新了房间信息，房间人数 %zi", ntesRoom.onlineUserCount);
}

#pragma mark - 视图协议
#pragma mark -- <NTESTextInputViewDelegate>
//发送信息
- (void)inputView:(NTESTextInputView *)inputView didSendText:(NSString *)text
{
    NSLog(@"发送信息:[%@]", text);
    
    if (text.length == 0)
    {
        [self.view makeToast:@"不能发送空消息" duration:2.0 position:CSToastPositionCenter];
    }
    else
    {
        NIMChatroomMember *me = [[NTESChatroomDataCenter sharedInstance] myInfo:_roomId];
        
        if (me.isMuted)
        {
            [self.view makeToast:@"您已被禁言" duration:2.0 position:CSToastPositionCenter];
        }
        else
        {
            NIMMessage *message = [NTESSessionMsgConverter msgWithText:text];
            NIMSession *session = [NIMSession session:self.roomId type:NIMSessionTypeChatroom];
            [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:nil];
        }
    }
}

//文本框高度改变
- (void)inputView:(NTESTextInputView *)inputView didChangeHeight:(CGFloat)height
{
    NSLog(@"改变高度");
    
    if (height != self.textInputView.height)
    {
        [self.textInputView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(height);
        }];
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}
#pragma mark -- <NTESLikeViewProtocol>
//发送点赞
- (void)likeViewSendZan:(NTESLikeView *)likeView;
{
    NIMChatroomMember *me = [[NTESChatroomDataCenter sharedInstance] myInfo:_roomId];
    
    if (me.isMuted)
    {
        [self.view makeToast:@"您已被禁言" duration:2.0 position:CSToastPositionCenter];
    }
    else
    {
        NIMMessage *message = [NTESSessionMsgConverter msgWithLike];
        NIMSession *session = [NIMSession session:_roomId type:NIMSessionTypeChatroom];
        [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:nil];
    }
}

#pragma mark -- <NTESEndViewProtocol>
- (void)endViewCloseAction:(NTESEndView *)endView
{
    [self.view dismissPresentedView:NO complete:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- <NTESAudienceTopBarProtocol>
- (void)topBarClickClose:(NTESAudienceTopBar *)bar
{
    [self doExitWithEndView:nil isKicked:NO complete:nil];
}

#pragma mark -- <NTESAudienceBottomBarProtocol>
//点击截屏
- (void)bottomBarClickComment:(NTESAudienceBottomBar *)bar
{
     [self.textInputView myFirstResponder];
}

//发送礼物
- (void)bottomBar:(NTESAudienceBottomBar *)bar sendPresent:(NTESPresent *)present
{
    NSLog(@"发送礼物:[%@]", present);
    
    NIMChatroomMember *me = [[NTESChatroomDataCenter sharedInstance] myInfo:_roomId];
    
    if (me.isMuted)
    {
        [self.view makeToast:@"您已被禁言" duration:2.0 position:CSToastPositionCenter];
    }
    else
    {
        NIMMessage *message = [NTESSessionMsgConverter msgWithPresent:present];
        NIMSession *session = [NIMSession session:_roomId type:NIMSessionTypeChatroom];
        [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:nil];
    }
}

//点击截屏
- (void)bottomBarClickSnap:(NTESAudienceBottomBar *)bar
{
    NSLog(@"点击截屏");
    UIImage *image = nil;
    
    if (self.playType == NTESPlayTypeNone)
    {
        NSLog(@"类型不明，就不截图了");
        return;
    }
    else if (self.playType == NTESPlayTypeAudio) //纯音频就截屏背景图
    {
        image = [self.backImageView snapshot];
    }
    else //有视频的截取视频画面
    {
        image = [self.player getSnapshot];
    }
    
    //保存相册
    [self.assetLibrary saveImage:image toAlbum:@"视频直播" completion:^(NSURL *assetURL, NSError *error) {
        [SVProgressHUD showSuccessWithStatus:@"截图成功"];
    } failure:^(NSError *error) {
        [SVProgressHUD showSuccessWithStatus:@"截图保存失败"];
    }];
}

//点击分享
- (void)bottomBar:(NTESAudienceBottomBar *)bar selectShareUrl:(NSInteger)index
{
    NSLog(@"点击分享");
    NSString *shareUrl = [NTESLiveDataHelper pullUrlWithSelectIndex:index];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = shareUrl;
    [self.view makeToast:@"直播地址已复制，请到第三方播放器中打开，或分享给好友" duration:2 position:CSToastPositionCenter];
}

#pragma mark -- 重载父类
//播放完成
- (void)doPlayComplete:(NSError *)error
{
    [super doPlayComplete:error];
    
    NSLog(@"播放完成");
    
    dispatch_async(dispatch_get_main_queue(), ^{
                
        [SVProgressHUD dismiss];

        NSString *message = (error ? @"播放出错" : @"直播已完成");
        [self.endView configEndView:nil name:nil message:message hiddenBack:NO];
        [self doExitWithEndView:self.endView isKicked:NO complete:nil];
    });
}

//播放类型
- (void)doPlayUrlType: (NTESPlayType)playType
{
    NSLog(@"当前类型 %zi", playType);
    if (playType == NTESPlayTypeAudio) //音频类型，用音波图
    {
        self.backImageView.hidden = NO;
        self.bottomBar.hiddenSnap = YES; //纯音频就隐藏吧
    }
    else
    {
        self.backImageView.hidden = YES;
        self.bottomBar.hiddenSnap = NO;
    }
}

//键盘事件
- (void)doKeyboardChangedWithTransition:(YYKeyboardTransition)transition
{
    CGFloat textAdjustDistance = 0.0;
    CGFloat chatAdjustDistance = 0.0;
    
    //显示文本框
    _textInputView.hidden = !transition.toVisible;
    
    //调整位置
    if (transition.toVisible)
    {
        textAdjustDistance = transition.toFrame.size.height;
        chatAdjustDistance = transition.toFrame.size.height - (self.bottomBar.height - self.textInputView.height);
    }
    
    //根据键盘调整
    __weak typeof(self) weakSelf = self;
    [_textInputView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.view).with.offset(-textAdjustDistance);
    }];
    [_chatView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.bottomBar.mas_top).with.offset(-chatAdjustDistance);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - 属性
- (NTESChatView *)chatView
{
    if (!_chatView) {
        _chatView = [[NTESChatView alloc] init];
    }
    return _chatView;
}

- (NTESLikeView *)likeView
{
    if (!_likeView) {
        _likeView = [[NTESLikeView alloc] init];
        _likeView.delegate = self;
    }
    return _likeView;
}

- (NTESAudienceBottomBar *)bottomBar
{
    if (!_bottomBar) {
        _bottomBar = [[NTESAudienceBottomBar alloc] init];
        _bottomBar.delegate = self;
        
        _bottomBar.presents = [NTESPresentManger sharedInstance].myPresentShop;
    }
    return _bottomBar;
}

- (NTESAudienceTopBar *)topBar
{
    if (!_topBar) {
        _topBar = [NTESAudienceTopBar topBarInstance];
        _topBar.delegate = self;
        
        if (_roomId)
        {
            NIMChatroom *chatroom = [[NTESChatroomDataCenter sharedInstance] roomInfo:_roomId];
            NTESChatroom *ntesChatroom = [[NTESChatroom alloc] initWithNITChatroom:chatroom];
            [self.topBar refreshBarWithChatroom:ntesChatroom];
        }
    }
    return _topBar;
}

- (NTESEndView *)endView
{
    if (!_endView) {
        _endView = [[NTESEndView alloc] init];
        _endView.delegate = self;
    }
    return _endView;
}

- (UIImageView *)backImageView
{
    if (!_backImageView) {
        _backImageView = [[YYAnimatedImageView alloc] initWithImage:[YYImage imageNamed:@"auidoGif.gif"]];
        _backImageView.contentMode = UIViewContentModeScaleAspectFit;
        _backImageView.hidden = YES;
    }
    return _backImageView;
}

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _containerView.backgroundColor = [UIColor blackColor];
    }
    return _containerView;
}

- (NTESTextInputView *)textInputView
{
    if (!_textInputView)
    {
        _textInputView = [[NTESTextInputView alloc] init];
        _textInputView.hidden = YES;
        _textInputView.delegate = self;
    }
    return _textInputView;
}

- (ALAssetsLibrary *)assetLibrary
{
    if (!_assetLibrary) {
        _assetLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetLibrary;
}

@end
