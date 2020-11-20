//
//  NERootViewController.m
//  LSMediaCaptureDemo
//
//  Created by emily on 16/10/20.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "NERootViewController.h"
#import "NEInternalMacro.h"

@interface NERootViewController () <UIGestureRecognizerDelegate>

@end

@implementation NERootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self configNavigationBarWithLeftButtonTitle:self.naviBarLeftTitle rightTitle:self.naviBarRightTitle];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configNavigationBarWithLeftButtonTitle:(NSString *)leftTitle rightTitle:(NSString *)rightTitle {
    self.navigationItem.title = self.title;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont systemFontOfSize:17.f], NSFontAttributeName, nil]];
    self.navigationController.navigationBar.barTintColor = NAVI_COLOR;
    
    if (leftTitle) {
        UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
        [leftBtn setTitle:leftTitle forState:UIControlStateNormal];
        [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        leftBtn.titleLabel.font = FONT(14.f);
        [leftBtn addTarget:self action:@selector(navigationBarLeftButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    }
    
    if (rightTitle) {
        UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
        [rightBtn setTitle:rightTitle forState:UIControlStateNormal];
        rightBtn.titleLabel.font = FONT(14.f);
        [rightBtn addTarget:self action:@selector(navigationBarRightButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    }
}

- (void)navigationBarLeftButtonTapped:(UIButton *)sender {
    [self popViewController];
}

- (void)navigationBarRightButtonTapped:(UIButton *)sender {
    //FIX ME: customize
}

- (void)popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (BOOL)shouldAutorotate {
    return NO;
}


@end
