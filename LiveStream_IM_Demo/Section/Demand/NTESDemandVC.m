//
//  NTESDemandVC.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/3/6.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESDemandVC.h"
#import "NTESQRScanVC.h"
#import "NTESDemandPlayVC.h"

@interface NTESDemandVC () <NTESQRScanVCDelegate>
@property (assign, nonatomic) BOOL isForceLandscape; //强制横屏
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UITextField *textView;
@property (strong, nonatomic) UIButton *scanBtn;
@property (strong, nonatomic) UIButton *enterBtn;
@end

@implementation NTESDemandVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initSubviews];
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
    NSLog(@"开始播放");
    
    NSString *url = [_textView.text removeSpace];
    
    if (![NSString checkDemandUrl:url])
    {
        [self.view endEditing:YES];
        NSString *msg = (url.length == 0 ? @"点播地址不可为空" : @"点播地址错误");
        [self.view makeToast:msg duration:2 position:CSToastPositionCenter];
    }
    else if (![url hasSuffix:@"mp4"] && ![url hasSuffix:@"flv"] && ![url hasSuffix:@"m3u8"])
    {
        [self.view endEditing:YES];
        [self.view makeToast:@"不支持该格式视频" duration:2 position:CSToastPositionCenter];
    }
    else
    {
        __weak typeof(self) weakSelf = self;
        [[RealReachability sharedInstance] reachabilityWithBlock:^(ReachabilityStatus status) {
            if (status == RealStatusNotReachable) {
                [self.view makeToast:@"无网络，请检查网络设置" duration:2 position:CSToastPositionCenter];
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
                        [weakSelf goPlayerVC:url];
                    }
                }];
            }
            else
            {
                [self goPlayerVC:url];
            }
        }];
    }
}

- (void)goPlayerVC:(NSString *)url
{
    //url = @"http://10.240.76.173:8080/bbc_meta.flv";
    
    if (url == nil)
    {
        [self.view makeToast:@"播放地址为空" duration:2 position:CSToastPositionCenter];
        return;
    }
    
    if ([self.textView isFirstResponder])
    {
        [self.textView resignFirstResponder];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NTESDemandPlayVC *push =  [[NTESDemandPlayVC alloc] initWithName:[url.lastPathComponent stringByDeletingPathExtension] url:url];
            [self.navigationController pushViewController:push animated:YES];
        });
    }
    else
    {
        NTESDemandPlayVC *push =  [[NTESDemandPlayVC alloc] initWithName:[url.lastPathComponent stringByDeletingPathExtension] url:url];
        [self.navigationController pushViewController:push animated:YES];
    }
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
        [_enterBtn setTitle:@"播放视频" forState:UIControlStateNormal];
        _enterBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
        [_enterBtn addTarget:self
                      action:@selector(startPlayStreamAction:)
            forControlEvents:UIControlEventTouchUpInside];
//        _enterBtn.enabled = NO;
    }
    return _enterBtn;
}

@end
