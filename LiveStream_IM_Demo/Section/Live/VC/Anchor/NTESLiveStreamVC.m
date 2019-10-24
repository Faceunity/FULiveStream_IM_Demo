//
//  NTESLiveStreamVC.m
//  NEUIDemo
//
//  Created by Netease on 17/1/5.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESLiveStreamVC.h"
#import "NTESAnchorTopBar.h"
#import "NTESAnchorBottomBar.h"
#import "NTESChatView.h"
#import "NTESPresentBoxView.h"
#import "NTESMuteView.h"
#import "NTESLikeView.h"
#import "NTESEndView.h"
#import "NTESTextInputView.h"

#import "NTESTextMessage.h"
#import "NTESPresentMessage.h"
#import "NTESPresentAttachment.h"
#import "NTESLikeAttachment.h"

#import "NTESSessionMsgConverter.h"
#import "NTESChatroomDataCenter.h"
#import "NTESChatroomManger.h"
#import "NTESPresentManger.h"
#import "NTESDaoService.h"

#import "NTESLiveDataHelper.h"

@interface NTESLiveStreamVC ()<NTESAnchorBottomBarProtocol, NTESAnchorTopBarProtocol, NTESTextInputViewDelegate, NTESMuteViewProtocol, NTESEndViewProtocol, NTESChatViewProtocol, NIMChatManagerDelegate, NIMChatroomManagerDelegate>

@property (nonatomic, strong) NSArray *members;
@property (nonatomic, copy) NSString *roomId;    //聊天室id
@property (nonatomic, strong) ALAssetsLibrary *assetLibrary; //图库

@property (nonatomic, strong) NTESChatView *chatView;   //聊天视图
@property (nonatomic, strong) NTESAnchorTopBar *topBar;       //顶部工具栏
@property (nonatomic, strong) NTESAnchorBottomBar *bottomBar; //底部工具栏
@property (nonatomic, strong) UIButton *presentBtn;   //礼物盒按钮
@property (nonatomic, strong) UIButton *startLiveBtn; //开始直播按钮
@property (nonatomic, strong) UIView *containerView;  //视频包裹视图
@property (nonatomic, strong) YYAnimatedImageView *backImageView; //背景图片（音频时使用）
@property (nonatomic, strong) NTESEndView *endView;       //完成视图
@property (nonatomic, strong) NTESLikeView *likeView;   //爱心视图
@property (nonatomic, strong) NTESTextInputView *textInputView; //输入框
@property (nonatomic, strong) NTESPresentBoxView *presentBox; //礼物盒子
@property (nonatomic, strong) NTESMuteView *muteView; //踢人视图

@end

@implementation NTESLiveStreamVC

- (instancetype)initWithChatroomId:(NSString *)roomId;
{
    if (self = [super init]) {
        _roomId = roomId;
    }
    return self;
}

- (void)dealloc
{
    [[NIMSDK sharedSDK].chatroomManager removeDelegate:self];
    [[NIMSDK sharedSDK].chatManager removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //子视图
    [self setupSubviews];
    
    //约束
    [self constraintSubViews];
    
    //默认UI
    [self switchToPreviewUI];
    
    //IM模块
    [self setupIM];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //开始预览
    if (self.pParaCtx.eOutStreamType != LS_HAVE_AUDIO) {
        [self startVideoPreview:self.pushUrl container:self.containerView];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.muteView dismiss];
    [self.bottomBar dismissChooseMenu];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.endView.frame = self.view.bounds;
}

#pragma mark - Private
- (void)setupSubviews
{
    [self.view addSubview:self.containerView];
    [self.view addSubview:self.backImageView];
    [self.view addSubview:self.startLiveBtn];
    [self.view addSubview:self.topBar];
    [self.view addSubview:self.bottomBar];
    [self.view addSubview:self.textInputView];
    [self.view addSubview:self.chatView];
    [self.view addSubview:self.likeView];
    [self.view addSubview:self.presentBtn];
}

- (void)constraintSubViews
{
    __weak typeof(self) weakSelf = self;
    [self.startLiveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).offset(32.0);
        make.right.equalTo(weakSelf.view).offset(-32.0);
        make.height.mas_equalTo(48.0);
        make.bottom.equalTo(weakSelf.view).offset(-80.0);
    }];
    
    [self.backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf.view);
        make.width.height.mas_equalTo(130.0);
    }];
    
    [self.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.view).with.offset(20.0);
        make.height.mas_equalTo(87.0);
    }];
    
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
    
    [self.presentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(weakSelf.view).with.offset(-10.0);
        make.bottom.equalTo(weakSelf.chatView).with.offset(-10.0);
        make.width.height.mas_equalTo(35.0);
    }];
    
    [self.likeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.presentBtn.mas_top);
        make.right.equalTo(weakSelf.view).with.offset(-10.0);
        make.width.equalTo(weakSelf.presentBtn);
        make.height.equalTo(weakSelf.chatView);
    }];
}

- (void)switchToPreviewUI
{
    self.startLiveBtn.hidden = NO;
    self.bottomBar.hidden = YES;
    self.presentBtn.hidden = YES;
    self.chatView.hidden = YES;
    [self.topBar hiddenChatroomView:YES];
}

- (void)switchToLiveStreamUI
{
    self.startLiveBtn.hidden = YES;
    self.bottomBar.hidden = NO;
    self.presentBtn.hidden = NO;
    self.chatView.hidden = NO;
    [self.topBar hiddenChatroomView:NO];
}

//监听IM事件
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

//常规退出
//destory: 是否销毁聊天室
- (void)doExitWithEndView:(NTESEndView *)endView
{
    [self.view endEditing:YES];
    
    [SVProgressHUD show];
    
    //停止伴音
    [self setAudioType:0];

    //停止推流
    __weak typeof(self) weakSelf = self;
    [self stopLiveStream:^(NSError *error) {
        
        [SVProgressHUD dismiss];
        
        if (error)
        {
            NSString *toast = [NSString stringWithFormat:@"停止推流失败：%zi", error.code];
            [weakSelf.view makeToast:toast duration:2 position:CSToastPositionCenter];
        }
        else
        {
            [weakSelf stopVideoPreview]; //停止预览
        }
        
        //退出聊天室
        [[NTESChatroomManger shareInstance] anchorExitChatroom:weakSelf.roomId destory:YES complete:^(NSError *error) {
            
            if (error)
            {
                NSString *toast = [NSString stringWithFormat:@"退出聊天室失败：%zi", error.code];
                [weakSelf.view makeToast:toast duration:2 position:CSToastPositionCenter];
            }
            
            //退出
            if (endView)
            {
                [weakSelf.view presentView:endView animated:YES complete:^{
                    weakSelf.startLiveBtn.hidden = YES;
                }];
            }
            else
            {
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }
        }];
    }];
}

//踢人
- (void)doKiceMember:(NSString *)userId roomId:(NSString *)roomId
{
    NIMChatroomMemberKickRequest *request = [[NIMChatroomMemberKickRequest alloc] init];
    request.roomId = roomId;
    request.userId = userId;
    
    __weak typeof(self) weakSelf = self;
    [[NIMSDK sharedSDK].chatroomManager kickMember:request completion:^(NSError * _Nullable error) {
        if (error) {
            NSString *toast = [NSString stringWithFormat:@"踢人失败,code = %zi", error.code];
            [weakSelf.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
        }
    }];
}

//禁言
- (void)doMuteMember:(NSString *)userId roomId:(NSString *)roomId mute:(BOOL)isMute
{
    NIMChatroomMemberUpdateRequest *request = [[NIMChatroomMemberUpdateRequest alloc] init];
    request.roomId = roomId;
    request.userId = userId;
    request.enable = !isMute;
    
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD show];
    [[NIMSDK sharedSDK].chatroomManager updateMemberMute:request completion:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        if (error) {
            NSString *toast = [NSString stringWithFormat:@"禁言失败,code = %zi", error.code];
            [weakSelf.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
        }
    }];
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
        
        //保存礼物
        [[NTESPresentManger sharedInstance] cachePresentToBox:presentMessage.present];
        
        //刷新礼物盒子
        self.presentBox.presents = [NTESPresentManger sharedInstance].myPresentBox;
    }
    else if ([attachment isKindOfClass:[NTESLikeAttachment class]]) //点赞消息
    {
        [self.likeView fireLike];
    }
}

//接收到系统通知
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
                    //刷新聊天信息
                    NTESTextMessage *message = [NTESTextMessage systemMessage:@"进入直播室" from:content.source.nick];
                    [weakSelf.chatView addNormalMessages:@[message]];
                    
                    //刷新观众头像
                    [[NTESChatroomDataCenter sharedInstance] memberListAddMembers:members roomId:weakSelf.roomId];
                    NSArray *memberDatas = [[NTESChatroomDataCenter sharedInstance] membersWithRoomId:weakSelf.roomId];
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
                    //刷新聊天信息
                    NTESTextMessage *message = [NTESTextMessage systemMessage:@"退出直播室" from:content.source.nick];
                    [weakSelf.chatView addNormalMessages:@[message]];
                    
                    //刷新观众头像
                    [[NTESChatroomDataCenter sharedInstance] memberListDelMembers:members roomId:weakSelf.roomId];
                    NSArray *memberDatas = [[NTESChatroomDataCenter sharedInstance] membersWithRoomId:weakSelf.roomId];
                    [weakSelf.topBar refreshBarWithAudiences:memberDatas];
                }];
                break;
            }
            case NIMChatroomEventTypeAddMute:
            case NIMChatroomEventTypeAddMuteTemporarily:
            {
                NSLog(@"成员被设置禁言");
                
                //刷新观众头像
                for (NIMChatroomNotificationMember *meber in content.targets) {
                    [[NTESChatroomDataCenter sharedInstance] setMemberMute:YES roomId:_roomId userId:meber.userId];
                    
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
                for (NIMChatroomNotificationMember *meber in content.targets) {
                    [[NTESChatroomDataCenter sharedInstance] setMemberMute:NO roomId:_roomId userId:meber.userId];
                    
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

#pragma mark - Action
//定时刷新人数
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

//开始直播
- (void)startLiveAction:(UIButton *)btn
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
                [SVProgressHUD showWithStatus:@"开始推流..."];
                [weakSelf startLiveStream:^(NSError *error) {
                    [SVProgressHUD dismiss];
                    if (error) {
                        NSString *cause = (error.userInfo[NTES_ERROR_MSG_KEY] ?: @"");
                        NSString *toast = [NSString stringWithFormat:@"推流失败: %@", cause];
                        [weakSelf.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
                    }
                }];
            }
        }];
    }
    else
    {
        [SVProgressHUD showWithStatus:@"开始推流..."];
        __weak typeof(self) weakSelf = self;
        [self startLiveStream:^(NSError *error) {
            [SVProgressHUD dismiss];
            
            if (error) {
                NSString *cause = (error.userInfo[NTES_ERROR_MSG_KEY] ?: @"");
                NSString *toast = [NSString stringWithFormat:@"推流失败: %@", cause];
                [weakSelf.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
            }
        }];
    }
}

//礼物盒子
- (void)presentBtnAction:(UIButton *)btn
{
    NSLog(@"礼物盒子");
    
    [self.presentBox show];
}

#pragma mark - IM相关代理
#pragma mark -- <NIMChatroomManagerDelegate>
//被踢回调
- (void)chatroom:(NSString *)roomId beKicked:(NIMChatroomKickReason)reason
{
    if ([roomId isEqualToString:self.roomId])
    {
        NSLog(@"chatroom be kicked, roomId:%@  rease:%zd",roomId,reason);
        
        [self doExitWithEndView:self.endView];
    }
}

- (void)chatroom:(NSString *)roomId connectionStateChanged:(NIMChatroomConnectionState)state;
{
    NSLog(@"chatroom connection state changed roomId : %@  state : %zd",roomId,state);
}

#pragma mark -- NIMChatManagerDelegate
//即将发送消息
- (void)willSendMessage:(NIMMessage *)message
{
    switch (message.messageType) {
        case NIMMessageTypeText:
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
        default:
            break;
    }
}

//接收消息
- (void)onRecvMessages:(NSArray *)messages
{
    for (NIMMessage *message in messages) {
        if (![message.session.sessionId isEqualToString:self.roomId]
            && message.session.sessionType == NIMSessionTypeChatroom) {
            //不属于这个聊天室的消息
            return;
        }
        switch (message.messageType)
        {
            case NIMMessageTypeText: //文字信息
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

#pragma mark - 视图相关代理
#pragma mark -- <NTESNormalMessageViewProtocol>
//评论组件点击名字
- (void)chatView:(NTESNormalMessageView *)chatView clickUserId:(NSString *)userId
{
    NIMChatroomMember *member = [[NTESChatroomDataCenter sharedInstance] myInfo:_roomId];
    if (![member.userId isEqualToString:userId])
    {
        __weak typeof(self) weakSelf = self;
        [[NTESChatroomManger shareInstance] requestMemberInfoWithRoomId:_roomId memberId:@[userId] complete:^(NSError *error, NSArray<NTESMember *> *members) {
            
            NTESMember *member = members.firstObject;
            member.isKicked = [[NTESChatroomDataCenter sharedInstance] memberIsKicked:userId roomId:weakSelf.roomId];
            [weakSelf.muteView showWithUserInfo:member];
        }];
    }
}

#pragma mark -- <NTESMuteViewProtocol>
//踢人
- (void)muteView:(NTESMuteView *)muteView kick:(NTESMember *) userInfo
{
    [self doKiceMember:userInfo.userId roomId:_roomId];
}

//禁言
- (void)muteView:(NTESMuteView *)muteView mute:(NTESMember *)userInfo
{
    [self doMuteMember:userInfo.userId roomId:_roomId mute:userInfo.isMuted];
}

#pragma mark -- <NTESEndViewProtocol>
- (void)endViewCloseAction:(NTESEndView *)endView
{
    [self.view dismissPresentedView:NO complete:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

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
        NIMMessage *message = [NTESSessionMsgConverter msgWithText:text];
        NIMSession *session = [NIMSession session:self.roomId type:NIMSessionTypeChatroom];
        [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:nil];
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

#pragma mark -- <NTESAnchorTopBarProtocol>
//关闭
- (void)topBarClose:(NTESAnchorTopBar *)bar
{
    if (self.bottomBar.isHidden) //直接退出
    {
        [self doExitWithEndView:nil];
    }
    else //弹框
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"确定结束直播？"
                                                           delegate:nil
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles: @"确定", nil];
        [alertView showAlertWithCompletionHandler:^(NSInteger index)
        {
            if (index == 1) {
                [self doExitWithEndView:self.endView];
            }
        }];
    }
}

//视频开启
- (void)topBar:(NTESAnchorTopBar *)bar videoOpen:(BOOL)isOpen
{
    NSLog(@"视频开启:%@",(isOpen ? @"开启" : @"关闭"));
    
    [self pauseVideo:!isOpen];
}

//音频开启
- (void)topBar:(NTESAnchorTopBar *)bar audioOpen:(BOOL)isOpen
{
    NSLog(@"音频开启:%@",(isOpen ? @"开启" : @"关闭"));

    [self pauseAudio:!isOpen];
}

//镜头方向
- (void)topBar:(NTESAnchorTopBar *)bar cameraIsFront:(BOOL)isFront
{
    NSLog(@"镜头方向:%@",(isFront ? @"前向" : @"后向"));
    
    [self switchCamera];
}

//点击用户头像
- (void)topBar:(NTESAnchorTopBar *)bar didSelectMember:(NTESMember *)member
{
    [self.muteView showWithUserInfo:member];
}

#pragma mark -- <NTESAnchorBottomBarProtocol>
- (void)bottomBarClickComment:(NTESAnchorBottomBar *)bar
{
    [self.textInputView myFirstResponder];
}

//点击截屏
- (void)bottomBarClickSnap:(NTESAnchorBottomBar *)bar
{
    NSLog(@"点击截屏");

    if (self.pParaCtx.eOutStreamType == LS_HAVE_AUDIO)
    {
        UIImage *image = self.backImageView.image;
        if (image)
        {
            [self.assetLibrary saveImage:image toAlbum:@"视频直播" completion:^(NSURL *assetURL, NSError *error) {
                [SVProgressHUD showSuccessWithStatus:@"截图成功"];
            } failure:^(NSError *error) {
                [SVProgressHUD showSuccessWithStatus:@"截图保存失败"];
            }];
        }
        else
        {
            [SVProgressHUD showSuccessWithStatus:@"截图失败"];
        }
    }
    else
    {
        [self snapImage:^(UIImage *image) {
            
            if (image)
            {
                [self.assetLibrary saveImage:image toAlbum:@"视频直播" completion:^(NSURL *assetURL, NSError *error) {
                    [SVProgressHUD showSuccessWithStatus:@"截图成功"];
                } failure:^(NSError *error) {
                    [SVProgressHUD showSuccessWithStatus:@"截图保存失败"];
                }];
            }
            else
            {
                [SVProgressHUD showSuccessWithStatus:@"截图失败"];
            }
        }];
    }
}

//点击分享
- (void)bottomBar:(NTESAnchorBottomBar *)bar selectShareUrl:(NSInteger)index
{
    NSString *shareUrl = [NTESLiveDataHelper pullUrlWithSelectIndex:index];
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = shareUrl;
//    [SVProgressHUD showSuccessWithStatus:@"直播地址已复制，请到第三方播放器中打开，或分享给好友"];
    [self.view makeToast:@"直播地址已复制，请到第三方播放器中打开，或分享给好友" duration:2 position:CSToastPositionCenter];
    
}

//选择伴音
- (void)bottomBar:(NTESAnchorBottomBar *)bar selectAudio:(NSInteger)index
{
    NSLog(@"伴音：选择了第%zi项", index);
    [self setAudioType:index];
}

//选择滤镜
- (void)bottomBar:(NTESAnchorBottomBar *)bar selectFilter:(NSInteger)index
{
    NSLog(@"滤镜：选择了第%zi项", index);
    NSInteger type = [NTESLiveDataHelper filterTypeWithSelectedIndex:index];
    [self setFilterType:type];
}

#pragma mark -- 重载父类
//已经开始直播
- (void)doDidStartLiveStream
{
    //前一页选择的是纯视频
    if (self.isOnlyPushVideo) {
        [_topBar performSelector:@selector(sendTouchupInsideToAudio) withObject:nil afterDelay:0.2];
    }
    
    [self switchToLiveStreamUI]; //更换UI
}

//已经停止直播
- (void)doDidStopLiveStream
{
    [self switchToPreviewUI]; //更换UI
}

//直播中出错
- (void)doLiveStreamError:(NSError *)error
{
    [self.view makeToast:@"直播出错" duration:2.0 position:CSToastPositionCenter];
    
    [self switchToPreviewUI]; //更换UI
    
    [self doExitWithEndView:self.endView];
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

//账号被踢
- (void)doAccountBeKicked
{
    __weak typeof(self) weakSelf = self;
    [self stopLiveStream:^(NSError *error) {
        
        [weakSelf stopVideoPreview];
        
        [[NTESChatroomManger shareInstance] anchorExitChatroom:weakSelf.roomId destory:YES complete:nil];
        
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            
            UINavigationController *nav = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            [nav popToRootViewControllerAnimated:YES];
        }];
    }];
}

#pragma mark - Getter/Setter
- (UIView *)containerView
{
    if (!_containerView)
    {
        _containerView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _containerView.backgroundColor = [UIColor blackColor];
    }
    return _containerView;
}

- (YYAnimatedImageView *)backImageView
{
    if (!_backImageView)
    {
        _backImageView = [[YYAnimatedImageView alloc] initWithImage:[YYImage imageNamed:@"audioGif.gif"]];
        _backImageView.hidden = (self.pParaCtx.eOutStreamType != LS_HAVE_AUDIO);
    }
    return _backImageView;
}

- (UIButton *)startLiveBtn
{
    if (!_startLiveBtn) {
        _startLiveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startLiveBtn setBackgroundImage:[UIImage imageNamed:@"按钮 正常"] forState:UIControlStateNormal];
        [_startLiveBtn setBackgroundImage:[UIImage imageNamed:@"按钮 按下"] forState:UIControlStateHighlighted];
        [_startLiveBtn setTitle:@"开始直播" forState:UIControlStateNormal];
        [_startLiveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_startLiveBtn addTarget:self action:@selector(startLiveAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _startLiveBtn;
}

- (NTESAnchorTopBar *)topBar
{
    if (!_topBar) {
        _topBar = [NTESAnchorTopBar topBarInstance];
        _topBar.delegate = self;
        
        [_topBar hiddenVideo:YES]; //去掉暂停视频推流功能。
        [_topBar hiddenCamera:(self.pParaCtx.eOutStreamType == LS_HAVE_AUDIO)];
 
        NIMChatroom *chatroom = [[NTESChatroomDataCenter sharedInstance] roomInfo:_roomId];
        NTESChatroom *room = [[NTESChatroom alloc] initWithNITChatroom:chatroom];
        [_topBar refreshBarWithChatroom:room];
    }
    return _topBar;
}

- (NTESAnchorBottomBar *)bottomBar
{
    if (!_bottomBar)
    {
        _bottomBar = [[NTESAnchorBottomBar alloc] init];
        _bottomBar.delegate = self;
        
        if (self.pParaCtx.eOutStreamType == LS_HAVE_AUDIO)
        {
            _bottomBar.hiddenFilter = YES;
            _bottomBar.hiddenSnap = YES;
        }
        else
        {
            _bottomBar.hiddenSnap = NO;
            if (self.pParaCtx.sLSVideoParaCtx.isVideoFilterOn)
            {
                _bottomBar.hiddenFilter = NO;
                NSInteger selectIndex = [NTESLiveDataHelper selectIndexWithfilterType:self.pParaCtx.sLSVideoParaCtx.filterType];
                _bottomBar.selectedFilter = selectIndex;
            }
            else
            {
                _bottomBar.hiddenFilter = YES;
            }
        }
    }
    return _bottomBar;
}

- (NTESChatView *)chatView
{
    if (!_chatView)
    {
        _chatView = [[NTESChatView alloc] init];
        _chatView.backgroundColor = [UIColor clearColor];
        _chatView.delegate = self;
    }
    return _chatView;
}

- (NTESLikeView *)likeView
{
    if (!_likeView)
    {
        _likeView = [[NTESLikeView alloc] init];
        [_likeView hiddenButton:YES];
    }
    return _likeView;
}

- (UIButton *)presentBtn
{
    if (!_presentBtn) {
        _presentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_presentBtn addTarget:self action:@selector(presentBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_presentBtn setBackgroundImage:[UIImage imageNamed:@"gift_btn_n"] forState:UIControlStateNormal];
        [_presentBtn setBackgroundImage:[UIImage imageNamed:@"gift_btn_p"] forState:UIControlStateHighlighted];
    }
    return _presentBtn;
}

- (NTESEndView *)endView
{
    if (!_endView) {
        _endView = [[NTESEndView alloc] init];
        _endView.delegate = self;
    }
    return _endView;
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

- (NTESPresentBoxView *)presentBox
{
    if (!_presentBox) {
        _presentBox = [[NTESPresentBoxView alloc] init];
        _presentBox.presents = [NTESPresentManger sharedInstance].myPresentBox;
    }
    return _presentBox;
}

- (NTESMuteView *)muteView
{
    if (!_muteView) {
        _muteView = [[NTESMuteView alloc] init];
        _muteView.delegate = self;
    }
    return _muteView;
}

- (ALAssetsLibrary *)assetLibrary
{
    if (!_assetLibrary) {
        _assetLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetLibrary;
}

@end
