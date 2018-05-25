//
//  NTESRoomAddressVC.m
//  NEUIDemo
//
//  Created by Netease on 17/1/3.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESRoomAddressVC.h"
#import "NTESQRScanVC.h"
#import "NTESPlayStreamVC.h"
#import "NTESChatroomManger.h"
#import "NTESLiveDataCenter.h"

@interface NTESRoomAddressVC () <NTESQRScanVCDelegate>
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UITextField *textView;
@property (strong, nonatomic) UIButton *scanBtn;
@property (strong, nonatomic) UIButton *enterBtn;

@end

@implementation NTESRoomAddressVC

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
        
        CGFloat interval = 4.0;
        CGFloat scanHeight = _containerView.height - 2*interval;
        CGFloat scanWidth = scanHeight;
        _scanBtn.frame = CGRectMake(_containerView.width - scanWidth - interval,
                                    interval,
                                    scanWidth,
                                    scanHeight);
        _textView.frame = CGRectMake(interval,
                                     interval,
                                     _scanBtn.left - interval,
                                     _scanBtn.height);
        
        _enterBtn.frame = CGRectMake(16.0,
                                     _containerView.bottom + 20,
                                     self.view.width - 2*16.0,
                                     48.0);
    }
}

- (void)initSubviews
{
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:self.containerView];
    [_containerView addSubview:self.textView];
    [_containerView addSubview:self.scanBtn];
    [self.view addSubview:self.enterBtn];
}

#pragma mark - Action
- (void)textChangedAction:(UITextField *)sender
{
    _enterBtn.enabled = (_textView.text.length != 0);
}

- (void)QRAction:(id)sender
{
    NTESQRScanVC *scanVC = [[NTESQRScanVC alloc] init];
    scanVC.delegate = self;
    [self presentViewController:scanVC animated:YES completion:nil];
}

- (void)startPlayStreamAction:(UIButton *)sender
{
    NSLog(@"开始直播");
    
    [self.view endEditing:YES];
    
    NSString *inputPullUrl = [_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //简单校验
    if (![NSString checkPullUrl:inputPullUrl]) {
        [self.view makeToast:@"拉流地址错误" duration:2 position:CSToastPositionCenter];
        return;
    }
    
    //进入聊天室
    [SVProgressHUD showWithStatus:@"进入聊天室..."];
    __weak typeof(self) weakSelf = self;
    [[NTESChatroomManger shareInstance] audienceEnterChatroomWithPullUrl:_textView.text complete:^(NSError *error, NSString *roomId) {
        [SVProgressHUD dismiss];
        if (error)
        {
            NSString *errorMsg = error.userInfo[NTES_ERROR_MSG_KEY];
            [weakSelf.view makeToast:errorMsg duration:2 position:CSToastPositionCenter];
        }
        else
        {
            NSString *pullUrl = [NTESLiveDataCenter shareInstance].pullUrl;
            NTESPlayStreamVC *playerVC = [[NTESPlayStreamVC alloc] initWithChatroomid:roomId pullUrl:pullUrl];
            [weakSelf presentViewController:playerVC animated:YES completion:nil];
        }
    }];
}


#pragma mark - <NTESQRScanVCDelegate>
- (void)NELivePlayerQRScanDidFinishScanner:(NSString *)string
{
    if (string) {
        _textView.text = string;
        _enterBtn.enabled = (_textView.text.length != 0);
    }
}

#pragma mark - Getter
- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor whiteColor];
    }
    return _containerView;
}

- (UITextField *)textView
{
    if (!_textView) {
        _textView = [[UITextField alloc] init];
        _textView.font = [UIFont systemFontOfSize:14.0];
        _textView.clearButtonMode = UITextFieldViewModeWhileEditing;
        _textView.clipsToBounds = YES;
        _textView.autocorrectionType = UITextAutocorrectionTypeNo;
        [_textView addTarget:self action:@selector(textChangedAction:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textView;
}

- (UIButton *)scanBtn
{
    if (!_scanBtn) {
        _scanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_scanBtn setImage:[UIImage imageNamed:@"扫一扫 n"] forState:UIControlStateNormal];
        [_scanBtn setImage:[UIImage imageNamed:@"扫一扫 p"] forState:UIControlStateHighlighted];
        [_scanBtn addTarget:self action:@selector(QRAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _scanBtn;
}

- (UIButton *)enterBtn
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
