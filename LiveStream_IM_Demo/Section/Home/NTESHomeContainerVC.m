//
//  NTESHomeContainerVC.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/2/28.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESHomeContainerVC.h"
#import "NTESLiveHomeVC.h"
#import "NTESDemandHomeVC.h"
#import "NTESShortVideoHomeVC.h"

@interface NTESHomeContainerVC ()

@property (nonatomic, strong) UISegmentedControl *segCtl;
@property (nonatomic, strong) NTESLiveHomeVC *liveHomeVC;
@property (nonatomic, strong) NTESDemandHomeVC *demandHomeVC;
@property (nonatomic, strong) NTESShortVideoHomeVC *shortHomeVC;
@end

@implementation NTESHomeContainerVC

- (void)dealloc
{
    self.liveHomeVC = nil;
    self.demandHomeVC = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.hiddenLeftBtn = YES;
    self.rightBtnTitle = @"退出";
    self.navigationItem.titleView = self.segCtl;
    
    [self addChildViewController:self.liveHomeVC];
    [self.view addSubview:self.liveHomeVC.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    if (self.navigationController.navigationBar.shadowImage == nil) {
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (BOOL)shouldAutorotate
{
    if (_segCtl.selectedSegmentIndex == 0) {
        return [self.liveHomeVC shouldAutorotate];
    }
    else if (_segCtl.selectedSegmentIndex == 1)
    {
        return [self.demandHomeVC shouldAutorotate];
    }
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (_segCtl.selectedSegmentIndex == 0) {
        return [self.liveHomeVC supportedInterfaceOrientations];
    }
    else if (_segCtl.selectedSegmentIndex == 1)
    {
        return [self.demandHomeVC supportedInterfaceOrientations];
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (void)segmentChangedAction:(UISegmentedControl *)seg
{
    switch (seg.selectedSegmentIndex)
    {
        case 0:
        {
            [self.shortHomeVC removeFromParentViewController];
            [self.shortHomeVC.view removeFromSuperview];
            
            [self.demandHomeVC removeFromParentViewController];
            [self.demandHomeVC.view removeFromSuperview];
            
            [self addChildViewController:self.liveHomeVC];
            [self.view addSubview:self.liveHomeVC.view];
            if (!CGRectEqualToRect(self.liveHomeVC.view.frame, self.view.bounds)) {
                self.liveHomeVC.view.frame = self.view.bounds;
            }
            break;
        }
        case 1:
        {
            [self.shortHomeVC removeFromParentViewController];
            [self.shortHomeVC.view removeFromSuperview];
            
            [self.liveHomeVC removeFromParentViewController];
            [self.liveHomeVC.view removeFromSuperview];
            
            [self addChildViewController:self.demandHomeVC];
            [self.view addSubview:self.demandHomeVC.view];
            if (!CGRectEqualToRect(self.demandHomeVC.view.frame, self.view.bounds)) {
                self.demandHomeVC.view.frame = self.view.bounds;
            }
            break;
        }
        case 2:
        {
            [self.demandHomeVC removeFromParentViewController];
            [self.demandHomeVC.view removeFromSuperview];
            
            [self.liveHomeVC removeFromParentViewController];
            [self.liveHomeVC.view removeFromSuperview];
            
            [self addChildViewController:self.shortHomeVC];
            [self.view addSubview:self.shortHomeVC.view];
            if (!CGRectEqualToRect(self.shortHomeVC.view.frame, self.view.bounds)) {
                self.shortHomeVC.view.frame = self.view.bounds;
            }
        }
        default:
            break;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (!CGRectEqualToRect(self.liveHomeVC.view.frame, self.view.bounds)) {
        self.liveHomeVC.view.frame = self.view.bounds;
    }
    
    if (!CGRectEqualToRect(self.demandHomeVC.view.frame, self.view.bounds)) {
        self.demandHomeVC.view.frame = self.view.bounds;
    }
}

- (void)doLogout
{
    [SVProgressHUD show];
    
    NTESAccount *account = [NTESLoginManager sharedManager].currentNTESLoginData;
    
    __weak typeof(self) weakSelf = self;
    [[NTESLoginManager sharedManager] logoutUser:account complete:^(NSError *error) {
        
        [SVProgressHUD dismiss];
        if (error)
        {
            NSString *cause = (error.userInfo[NTES_ERROR_MSG_KEY] ?: @"");
            NSString *toast = [NSString stringWithFormat:@"注销失败: %@", cause];
            [weakSelf.view makeToast:toast duration:2 position:CSToastPositionCenter];
        }
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark - Getter
- (UISegmentedControl *)segCtl
{
    if (!_segCtl) {
        _segCtl = [[UISegmentedControl alloc] initWithItems:@[@"直播", @"点播", @"短视频"]];
        _segCtl.selectedSegmentIndex = 0;
        _segCtl.frame = CGRectMake(0, 0, 182, 29);
        [_segCtl addTarget:self action:@selector(segmentChangedAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _segCtl;
}

- (NTESLiveHomeVC *)liveHomeVC
{
    if (!_liveHomeVC) {
        _liveHomeVC = [[NTESLiveHomeVC alloc] init];
    }
    return _liveHomeVC;
}

- (NTESDemandHomeVC *)demandHomeVC
{
    if (!_demandHomeVC) {
        _demandHomeVC = [[NTESDemandHomeVC alloc] init];
    }
    return _demandHomeVC;
}

- (UIViewController *)shortHomeVC
{
    if (!_shortHomeVC) {
        _shortHomeVC = [[NTESShortVideoHomeVC alloc] init];
    }
    return _shortHomeVC;
}

#pragma mark - 父类重载
- (void)doRightNavBarRightBtnAction
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确定退出该账号？" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    __weak typeof(self) weakSelf = self;
    [alertView showAlertWithCompletionHandler:^(NSInteger index) {
        if (index == 1) {
            [weakSelf doLogout];
        }
    }];
}

@end
