//
//  NTESLoginVC.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 16/12/27.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NTESLoginVC.h"

#import "NTESHomeContainerVC.h"
#import "UIButton+Captcha.h"
#import "NTESRegisterVCViewController.h"
#import "NTESEncryption.h"

#define kUserName @"userName"
#define kUserPassword @"userPassward"
#define KisRememberPwd @"isRememberPwd"


@interface NTESLoginVC ()

@property (weak, nonatomic) IBOutlet UIView *inputContainerView;

@property (weak, nonatomic) IBOutlet UIImageView *logoImg;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *enterBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_imgTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_inputTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint_loginTop;

@property (weak, nonatomic) IBOutlet UIImageView *iconImg;
@property(nonatomic, strong) UITextField *mobileTextField;
@property(nonatomic, strong) UITextField *veirifyTextField;

//切换账号视图，手机验证码登录方式
@property(nonatomic, strong) UIButton *mobileBtn;

@property(nonatomic, strong) UIButton *userBtn;

@property(nonatomic, strong) UILabel *loginLabel;

@property(nonatomic, strong) UIButton *checklistBtn;

@property(nonatomic, strong) UIButton *captchaButton;

@end

@implementation NTESLoginVC

- (BOOL)isNaviBarVisible {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _loginLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.text = @"- - - - -手机验证码登录- - - - -";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:13];
        label.centerX = self.view.centerX;
        label;
    });
    
    _mobileBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"mobileLog_highlighted"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"mobileLog"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(goMobileLoginAction:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    _userBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"userLog_high"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"userLog"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(goUserLoginAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.hidden = YES;
        btn;
    });
    
    _checklistBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor clearColor];
        [btn setImage:[UIImage imageNamed:@"选框"] forState:UIControlStateNormal];
        [btn setTitle:@"记住账号和密码" forState:UIControlStateNormal];
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 75 );
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
        btn.titleLabel.font = [UIFont systemFontOfSize:10];
        btn.enabled = NO;
        [btn addTarget:self action:@selector(checklistBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    _captchaButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor whiteColor];
        btn.layer.cornerRadius = 8;
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn setTitleColor:UIColorFromRGB(0x2084ff) forState:UIControlStateNormal];
        [btn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(captchaButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.hidden = YES;
        btn;
    });
    
    _mobileTextField = ({
        UITextField *tf = [UITextField new];
        tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入手机号"
                                                                   attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13.f]}];
        tf.textColor = [UIColor whiteColor];
        tf.hidden = YES;
        tf.keyboardType = UIKeyboardTypeNumberPad;
        [tf addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
        tf;
    });
    
    _veirifyTextField = ({
        UITextField *tf = [UITextField new];
        tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入短信验证码"
                                                                   attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13.f]}];
        tf.textColor = [UIColor whiteColor];

        tf.hidden = YES;
        tf.keyboardType = UIKeyboardTypeNumberPad;
        [tf addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
        tf;
    });
    
    [@[_loginLabel,
       _mobileBtn,
       _checklistBtn,
       _captchaButton,
       _userBtn,
       _mobileTextField,
       _veirifyTextField]enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
           [self.view addSubview:view];
       }];
    
    [self.view bringSubviewToFront:self.captchaButton];
    
    [self setupConstraints];
    
    //登录按钮
    [_enterBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:1.f alpha:1.f] size:_enterBtn.size] forState:UIControlStateNormal];
    [_enterBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:1.f alpha:.5f] size:_enterBtn.size] forState:UIControlStateDisabled];
    [_enterBtn setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:1.f alpha:.5f] size:_enterBtn.size] forState:UIControlStateHighlighted];
    
    _constraint_inputTop.constant *= UISreenHeightScale;
    _constraint_imgTop.constant *= UISreenHeightScale;
    _constraint_loginTop.constant *= UISreenHeightScale;
    
    _usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:KisRememberPwd]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KisRememberPwd];
        [self.checklistBtn setImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
        
        self.usernameTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kUserName];
        self.passwordTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kUserPassword];
        [self changeUItoUserLoginwithUserName:self.usernameTextField.text andPassword:self.passwordTextField.text];
        self.enterBtn.enabled = YES;
    }
    else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KisRememberPwd];
        [self.checklistBtn setImage:[UIImage imageNamed:@"选框"] forState:UIControlStateNormal];
        [self changeUItoUserLoginwithUserName:nil andPassword:nil];
    }

    
}

- (void)viewWillDisappear:(BOOL)animated {
    if (![[NSUserDefaults standardUserDefaults] boolForKey:KisRememberPwd]) {
        self.usernameTextField.text = nil;
        self.passwordTextField.text = nil;
    }
    self.veirifyTextField.text = nil;
    [self.captchaButton releaseTimeAtCaptchaButton];
    
    [@[self.passwordTextField,
       self.usernameTextField,
       self.mobileTextField,
       self.veirifyTextField] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
           [view resignFirstResponder];
       }];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:![self isNaviBarVisible] animated:YES];
    BOOL enable = (_usernameTextField.text.length != 0 && _passwordTextField.text.length != 0);
    self.enterBtn.enabled = enable;
    self.checklistBtn.enabled = enable;
}

- (void)setupConstraints {
    [self.checklistBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordTextField.mas_bottom).offset(25);
        make.left.equalTo(self.view.mas_left).offset(27);
        make.width.equalTo(@88);
        make.height.equalTo(@13);
    }];
    
    [self.loginLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-70);
        make.width.equalTo(@200);
        make.height.equalTo(@13);
    }];
    
    [self.mobileBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.height.equalTo(@30);
        make.bottom.equalTo(self.view.mas_bottom).offset(-20);
    }];
    
    [self.userBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.mobileBtn);
    }];
    
    [self.captchaButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.usernameTextField.mas_right).offset(-5);
        make.centerY.equalTo(self.usernameTextField.mas_centerY);
        make.width.equalTo(@75);
    }];
    
    [self.mobileTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.usernameTextField);
    }];
    
    [self.veirifyTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.passwordTextField);
    }];
}


#pragma mark - 账号或手机登录
- (void)doLogin {
    NTESAccount *account = [NTESAccount new];
    if (!self.captchaButton.hidden) {
        account.phone = [_mobileTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        account.verifyCode = _veirifyTextField.text;
        [SVProgressHUD showWithStatus:@"登录中..."];
        WEAK_SELF(weakSelf);
        [[NTESLoginManager sharedManager] loginUserWithPhone:account complete:^(NSError *error) {
            [SVProgressHUD dismiss];
            if (error)
            {
                NSString *cause = (error.userInfo[NTES_ERROR_MSG_KEY] ?: @"");
                NSString *toast = [NSString stringWithFormat:@"登录失败  %@", cause];
                [weakSelf.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
            }
            else //登陆成功
            {
                if (![[NSUserDefaults standardUserDefaults] boolForKey:KisRememberPwd]) {
                    self.usernameTextField.text = @"";
                    self.passwordTextField.text = @"";
                }
                NTESHomeContainerVC *homeVC = [NTESHomeContainerVC new];
                [weakSelf.navigationController pushViewController:homeVC animated:YES];
            }
        }];
    }
    else {
        account.accid = [_usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        account.password = [NTESEncryption md5EncryptWithString:_passwordTextField.text];
        
        [SVProgressHUD showWithStatus:@"登录中..."];
        WEAK_SELF(weakSelf);
        [[NTESLoginManager sharedManager] loginUser:account complete:^(NSError *error) {
            [SVProgressHUD dismiss];
            if (error)
            {
                NSString *cause = (error.userInfo[NTES_ERROR_MSG_KEY] ?: @"");
                NSString *toast = [NSString stringWithFormat:@"登录失败: %@", cause];
                [weakSelf.view makeToast:toast duration:2.0 position:CSToastPositionCenter];
                if (error.code == 910 || error.code == 904) {
                    self.usernameTextField.text = @"";
                    self.passwordTextField.text = @"";
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:KisRememberPwd]) {
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KisRememberPwd];
                        [self.checklistBtn setImage:[UIImage imageNamed:@"选框"] forState:UIControlStateNormal];
                    }
                }
            }
            else //登陆成功
            {
                NTESHomeContainerVC *homeVC = [NTESHomeContainerVC new];
                [weakSelf.navigationController pushViewController:homeVC animated:YES];
            }
        }];
    }

}

#pragma mark -- 事件
- (IBAction)textChanged:(UITextField *)sender {
    if (self.captchaButton.hidden) {
        BOOL enable = (_usernameTextField.text.length != 0 && _passwordTextField.text.length != 0);
        self.enterBtn.enabled = enable;
        self.checklistBtn.enabled = enable;
    }else {
        BOOL enable = ( _mobileTextField.text.length != 0 && _veirifyTextField.text.length > 3);
        self.enterBtn.enabled = enable;
    }
    
    if (sender == self.veirifyTextField) {
        if (sender.text.length > 6){
            sender.text = [sender.text substringToIndex:6];
        }
    }
}

- (IBAction)loginAction:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:@"登录"]) {
        NSString *accid = [self.usernameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *pwd = self.passwordTextField.text;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:KisRememberPwd]) {
            [[NSUserDefaults standardUserDefaults] setValue:accid forKey:kUserName];
            [[NSUserDefaults standardUserDefaults] setValue:pwd forKey:kUserPassword];
        }
    }
    //检测网络
    WEAK_SELF(weakSelf);
    [[RealReachability sharedInstance] reachabilityWithBlock:^(ReachabilityStatus status) {
        if (status == RealStatusNotReachable) {
            [weakSelf.view makeToast:@"无网络，请检查网络设置" duration:2 position:CSToastPositionCenter];
        }
        else
        {
            [weakSelf doLogin];
        }
    }];
}

- (IBAction)goRegistAction:(id)sender
{
    NTESRegisterVCViewController *registerVC = [NTESRegisterVCViewController new];
    __weak typeof(self) weakSelf = self;
    registerVC.completeBlock = ^(NSString *username, NSString *password){
        
        if (username && password) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:KisRememberPwd]) {
                weakSelf.usernameTextField.text = username;
                weakSelf.passwordTextField.text = password;
                [[NSUserDefaults standardUserDefaults] setObject:username forKey:kUserName];
                [[NSUserDefaults standardUserDefaults] setObject:password forKey:kUserPassword];
            }
            else {
                weakSelf.usernameTextField.text = username;
                weakSelf.passwordTextField.text = password;
            }
            //FIX ME:
            [self changeUItoUserLoginwithUserName:username andPassword:password];
        }
        
        weakSelf.enterBtn.enabled = ([weakSelf.usernameTextField.text length] && [weakSelf.passwordTextField.text length]);
    };
    
    [self.navigationController pushViewController:registerVC animated:YES];
}

- (void)checklistBtnAction:(UIButton *)sender {
    self.checklistBtn.selected = !self.checklistBtn.selected;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:KisRememberPwd]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:KisRememberPwd];
        [self.checklistBtn setImage:[UIImage imageNamed:@"选框"] forState:UIControlStateNormal];
    }else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KisRememberPwd];
        [self.checklistBtn setImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
    }
}

- (void)goMobileLoginAction:(UIButton *)sender {
    //修改UI到手机登录
    [self changeUItoMobileLogin];
}

- (void)goUserLoginAction:(UIButton *)sender {
    //修改UI到用户登录
    [self changeUItoUserLoginwithUserName:self.usernameTextField.text andPassword:self.passwordTextField.text];
}

- (void)captchaButtonAction:(UIButton *)sender {
    NSString *phone = [self.mobileTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if (phone.length == 0) {
        NSString *toast = [NSString stringWithFormat:@"手机号为空"];
        [self.view makeToast:toast duration:2 position:CSToastPositionCenter];
    }
    else if (![self isValidMobile:phone]) {
        NSString *toast = [NSString stringWithFormat:@"手机号格式有误，请重新输入"];
        [self.view makeToast:toast duration:2 position:CSToastPositionCenter];
    }
    else {
    [sender startTimeAtCaptchaButton];
    [SVProgressHUD showWithStatus:@"获取验证码..."];

    WEAK_SELF(weakSelf);
    [[NTESLoginManager sharedManager] getLoginVerifyCode:phone complete:^(NSError *error) {
        [SVProgressHUD dismiss];
        if (error)
        {
            NSString *cause = (error.userInfo[NTES_ERROR_MSG_KEY] ?: @"");
            NSString *toast = [NSString stringWithFormat:@"获取验证码失败: %@", cause];
            [weakSelf.view makeToast:toast duration:2 position:CSToastPositionCenter];
            [self.captchaButton releaseTimeAtCaptchaButton];
        }
        else
        {
            [weakSelf.view makeToast:@"获取验证码成功" duration:2 position:CSToastPositionCenter];
        }
    }];
    }
}

#pragma mark -- 重载父类
- (void)doKeyboardChangedWithTransition:(YYKeyboardTransition)transition
{
    CGFloat adjustDistance = 0.0;
    
    if (transition.toVisible)
    {
        adjustDistance = 64.0 + 102.0 * UISreenHeightScale;
        _logoImg.hidden = YES;
    }
    else
    {
        adjustDistance = 257.0 * UISreenHeightScale;
        _logoImg.hidden = NO;
        
    }
    [UIView animateWithDuration:transition.animationDuration animations:^{
        _constraint_inputTop.constant = adjustDistance;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Private

- (void)changeUItoMobileLogin {
    self.usernameTextField.hidden = YES;
    self.passwordTextField.hidden = YES;
    self.iconImg.image = [UIImage imageNamed:@"verify"];
    self.mobileTextField.hidden = NO;
    self.veirifyTextField.hidden = NO;
    self.enterBtn.enabled = NO;
    [self.enterBtn setTitle:@"验证并登录" forState:UIControlStateNormal];
    self.captchaButton.hidden = NO;
    self.checklistBtn.hidden = YES;
    self.mobileBtn.hidden = YES;
    self.userBtn.hidden = NO;
    self.loginLabel.text = @"- - - - -账号登录- - - - -";

}

- (void)changeUItoUserLoginwithUserName:(NSString *)userName andPassword:(NSString *)pwd {
    
    self.usernameTextField.hidden = NO;
    self.passwordTextField.hidden = NO;
    self.iconImg.image = [UIImage imageNamed:@"icon_mima_"];
    self.mobileTextField.hidden = YES;
    self.veirifyTextField.hidden = YES;
    
    if (userName && pwd) {
        self.usernameTextField.text = userName;
        self.passwordTextField.text = pwd;
    } else {
        self.usernameTextField.text = @"";
        self.passwordTextField.text = @"";
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:KisRememberPwd] && self.usernameTextField.text.length != 0 && self.passwordTextField.text.length != 0) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KisRememberPwd];
        [self.checklistBtn setImage:[UIImage imageNamed:@"选中"] forState:UIControlStateNormal];
        self.enterBtn.enabled = YES;
    }
    
    [self.enterBtn setTitle:@"登录" forState:UIControlStateNormal];
    self.captchaButton.hidden = YES;
    self.checklistBtn.hidden = NO;
    self.mobileBtn.hidden = NO;
    self.userBtn.hidden = YES;
    self.loginLabel.text = @"- - - - -手机验证码登录- - - - -";
    
    BOOL enable = (_usernameTextField.text.length != 0 && _passwordTextField.text.length != 0);
    self.checklistBtn.enabled = enable;
    self.enterBtn.enabled = enable;
}

- (BOOL)isValidMobile:(NSString *)phone {
    NSString *phoneRegex = @"^1[3|4|5|7|8][0-9]{9}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:phone];
}

@end
