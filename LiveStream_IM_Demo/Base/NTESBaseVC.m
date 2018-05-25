//
//  NTESBaseVC.m
//  NEUIDemo
//
//  Created by Netease on 16/12/30.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NTESBaseVC.h"

@interface NTESBaseVC ()<YYKeyboardObserver, UITextFieldDelegate>
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@end

@implementation NTESBaseVC

- (void)dealloc
{
    NSLog(@"[%@] 释放了", NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [NTESAutoRemoveNotification addObserver:self
                                   selector:@selector(accountBeKickedAction:)
                                       name:kNTESAccountBeKicedNotication
                                     object:nil];
    
    
    [self setupDefaultNavBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.view endEditing:YES];
    
    [[YYKeyboardManager defaultManager] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[YYKeyboardManager defaultManager] addObserver:self];
    [[UIApplication sharedApplication] setStatusBarHidden:![self isStatusBarVisible]];

}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:![self isNaviBarVisible] animated:YES];
    UIStatusBarStyle style = [self preferredStatusBarStyle];
    [[UIApplication sharedApplication] setStatusBarStyle:style animated:NO];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)isNaviBarVisible {
    return YES;
}

- (BOOL)isStatusBarVisible {
    return YES;
}

- (void)setupDefaultNavBar
{
    [self configNavigationBar];
    
    UIBarButtonItem *leftBtnItem = [[UIBarButtonItem alloc] initWithCustomView:self.leftButton];
    UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -16;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, leftBtnItem, nil];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, rightBtnItem, nil];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:nil];
    self.leftBtnImage = @"";
    self.rightBtnImage = @"";
    self.rightBtnTitle = @"";
    self.leftBtnTitle = @"";
    self.hiddenRightBtn = NO;
    self.hiddenLeftBtn = NO;
}

- (void)configNavigationBar {
    UIImage *backImg = [UIImage imageWithColor:UIColorFromRGB(0xf7f7f9) size:CGSizeMake(100, 100)];
    [[UINavigationBar appearance] setBackgroundImage:backImg forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage:backImg forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
}

#pragma mark -- 事件
- (void)tapAction:(UITapGestureRecognizer *)tap
{
    [self.view endEditing:YES];
}

- (void)leftButtonAction:(UIButton *)sender
{
//    [self.navigationController popViewControllerAnimated:YES];
    //FIX ME:这里需要根据前置页面是present或者push进来做一个判断
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1) {
        if (viewControllers[viewControllers.count - 1] == self) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)rightButtonAction:(UIButton *)sender
{
    NSLog(@"右键事件");
    [self doRightNavBarRightBtnAction];
}

- (void)accountBeKickedAction:(NSNotification *)note
{
    [self doAccountBeKicked];
}

#pragma mark -- 属性
- (UITapGestureRecognizer *)tap
{
    if (!_tap) {
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        _tap.cancelsTouchesInView = YES;
    }
    return _tap;
}

- (UIButton *)leftButton
{
    if (!_leftButton)
    {
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (self.leftBtnTitleColor) {
            [_leftButton setTitleColor:self.leftBtnTitleColor forState:UIControlStateNormal];
        }else {
            [_leftButton setTitleColor:UIColorFromRGB(0X238EFA) forState:UIControlStateNormal];
        }
        _leftButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        _leftButton.frame = CGRectMake(0, 0, 60, 40.0);
        [_leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

- (UIButton *)rightButton
{
    if (!_rightButton)
    {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightButton setTitleColor:UIColorFromRGB(0X238EFA) forState:UIControlStateNormal];
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        _rightButton.frame = CGRectMake(0, 0, 60, 40.0);
        [_rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}

- (void)setLeftBtnTitle:(NSString *)leftBtnTitle
{
    _leftBtnTitle = leftBtnTitle;
    
    [_leftButton setTitle:leftBtnTitle forState:UIControlStateNormal];
}

- (void)setLeftBtnImage:(NSString *)leftBtnImage
{
    _leftBtnImage = leftBtnImage;
    
    [_leftButton setBackgroundImage:[UIImage imageNamed:leftBtnImage] forState:UIControlStateNormal];;
}

- (void)setRightBtnTitle:(NSString *)rightBtnTitle
{
    _rightBtnTitle = rightBtnTitle;
    
    [_rightButton setTitle:rightBtnTitle forState:UIControlStateNormal];
}

- (void)setRightBtnImage:(NSString *)rightBtnImage
{
    _rightBtnImage = rightBtnImage;
    
    [_rightButton setImage:[UIImage imageNamed:rightBtnImage] forState:UIControlStateNormal];
}

- (void)setHiddenLeftBtn:(BOOL)hiddenLeftBtn
{
    _hiddenLeftBtn = hiddenLeftBtn;
    
    _leftButton.hidden = hiddenLeftBtn;
    
    _leftButton.userInteractionEnabled = !hiddenLeftBtn;
}

- (void)setHiddenRightBtn:(BOOL)hiddenRightBtn
{
    _hiddenRightBtn = hiddenRightBtn;
    
    _rightButton.hidden = hiddenRightBtn;
}


#pragma mark - 代理
#pragma mark - <UITextFieldDelegate>
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -- <YYKeyboardObserver>
- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition
{
    if (transition.toVisible)
    {
        [self.view removeGestureRecognizer:self.tap];
        [self.view addGestureRecognizer:self.tap];
    }
    else
    {
        [self.view removeGestureRecognizer:self.tap];
    }
    
    [self doKeyboardChangedWithTransition:transition];
}

#pragma mark -- 子类重载
- (void)doKeyboardChangedWithTransition:(YYKeyboardTransition)transition {}
- (void)doRightNavBarRightBtnAction {};
- (void)doAccountBeKicked
{
    UINavigationController *rootVC = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootVC.presentedViewController) {
        [rootVC.presentedViewController dismissViewControllerAnimated:YES completion:^{
            [rootVC popToRootViewControllerAnimated:YES];
        }];
    }
    else
    {
        [rootVC popToRootViewControllerAnimated:YES];
    }
};

@end
