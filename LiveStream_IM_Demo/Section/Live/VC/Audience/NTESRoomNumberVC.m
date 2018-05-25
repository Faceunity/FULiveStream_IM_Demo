//
//  NTESRoomNumberVC.m
//  NEUIDemo
//
//  Created by Netease on 17/1/3.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESRoomNumberVC.h"
#import "NTESPlayStreamVC.h"

#import "NTESChatroomDataCenter.h"
#import "NTESDaoService.h"
#import "NTESLiveDataCenter.h"
#import "NTESChatroomManger.h"

typedef void(^EnterChatRoomComplete)(NTESChatroom *chatroom);

@interface NTESRoomNumberVC ()

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UITextField *textView;
@property (strong, nonatomic) UIButton *enterBtn;

@end

@implementation NTESRoomNumberVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (_containerView.width != self.view.width)
    {
        _containerView.frame = CGRectMake(0, 20.0, self.view.width, 48.0);
    
        _textView.frame = CGRectMake(15.0,
                                     0,
                                     _containerView.width - 15.0*2,
                                     _containerView.height);
        _enterBtn.frame = CGRectMake(16.0,
                                     _containerView.bottom + 20.0,
                                     self.view.width - 2*16.0,
                                     48.0);
    }
}

- (void)initSubviews
{
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:self.containerView];
    [_containerView addSubview:self.textView];
    [self.view addSubview:self.enterBtn];
}

#pragma mark - Action
- (void)textChangedAction:(UITextField *)sender
{
    _enterBtn.enabled = (sender.text.length != 0);
}

- (void)startPlayStreamAction:(UIButton *)sender
{
    NSLog(@"开始直播");
    
    [self.view endEditing:YES];
    
    //简单校验
    if (![NSString checkRoomNumber:_textView.text]) {
        [self.view makeToast:@"房间号错误" duration:2 position:CSToastPositionCenter];
        return;
    }
    
    //进入聊天室
    [SVProgressHUD showWithStatus:@"进入聊天室..."];
    NSString *chatroomId = _textView.text;
    __weak typeof(self) weakSelf = self;
    [[NTESChatroomManger shareInstance] audienceEnterChatroomWithRoomid:chatroomId complete:^(NSError *error, NSString *roomId) {
        [SVProgressHUD dismiss];
        if (error)
        {
            NSString *errorMsg = error.userInfo[NTES_ERROR_MSG_KEY];
            NSString *errorToast = [NSString stringWithFormat:@"进入聊天室失败:%@", errorMsg];
            [weakSelf.view makeToast:errorToast duration:2 position:CSToastPositionCenter];
        }
        else
        {
            [NTESLiveDataCenter shareInstance].pullUrl = [NTESLiveDataCenter shareInstance].rtmpPullUrl;
            NSString *pullUrl = [NTESLiveDataCenter shareInstance].pullUrl;
            NTESPlayStreamVC *vc = [[NTESPlayStreamVC alloc] initWithChatroomid:roomId pullUrl:pullUrl];
            [weakSelf presentViewController:vc animated:YES completion:nil];
        }
    }];
}

#pragma mark - Getter
- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.backgroundColor = [UIColor whiteColor];
    }
    return _containerView;
}

- (UITextField *)textView
{
    if (!_textView) {
        _textView = [[UITextField alloc] init];
        _textView.font = [UIFont systemFontOfSize:17.0];
        _textView.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textView.keyboardType = UIKeyboardTypeNumberPad;
        _textView.clipsToBounds = YES;
        [_textView addTarget:self
                      action:@selector(textChangedAction:)
            forControlEvents:UIControlEventEditingChanged];
    }
    return _textView;
}

-(UIButton *)enterBtn
{
    if (!_enterBtn) {
        _enterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_enterBtn setBackgroundImage:[UIImage imageNamed:@"按钮 正常"] forState:UIControlStateNormal];
        [_enterBtn setBackgroundImage:[UIImage imageNamed:@"按钮 按下"] forState:UIControlStateHighlighted];
        [_enterBtn setBackgroundImage:[UIImage imageNamed:@"按钮 不可点击"] forState:UIControlStateDisabled];
        [_enterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_enterBtn setTitle:@"进入直播" forState:UIControlStateNormal];
        _enterBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
        [_enterBtn addTarget:self
                      action:@selector(startPlayStreamAction:)
            forControlEvents:UIControlEventTouchUpInside];
        _enterBtn.enabled = NO;
    }
    return _enterBtn;
}

@end
