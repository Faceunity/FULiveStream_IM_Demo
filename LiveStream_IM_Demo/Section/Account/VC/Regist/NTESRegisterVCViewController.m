//
//  NTESRegisterVCViewController.m
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/6/30.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESRegisterVCViewController.h"
#import "UIButton+Captcha.h"
#import "NTESLoginVC.h"
#import "NTESEncryption.h"

@interface NTESRegisterVCViewController ()

@property(nonatomic, strong) UIImageView *logoImg;

@property(nonatomic, strong) UIView *inputContainerView;
@property(nonatomic, strong) UITextField *accountTextfield;//账号
@property(nonatomic, strong) UITextField *nicknameTextfield;//昵称
@property(nonatomic, strong) UITextField *mobileTextfield;//手机号
@property(nonatomic, strong) UITextField *verifyCodeTextfield;//验证码
@property(nonatomic, strong) UITextField *passwordTextfield;//密码

@property(nonatomic, strong) UIImageView *accountImg;
@property(nonatomic, strong) UIImageView *nickImg;
@property(nonatomic, strong) UIImageView *mobileImg;
@property(nonatomic, strong) UIImageView *verifyImg;
@property(nonatomic, strong) UIImageView *passwordImg;

@property(nonatomic, strong) UIView *line1;
@property(nonatomic, strong) UIView *line2;
@property(nonatomic, strong) UIView *line3;
@property(nonatomic, strong) UIView *line4;
@property(nonatomic, strong) UIView *line5;

@property(nonatomic, strong) UIButton *registerBtn;
@property(nonatomic, strong) UIButton *goLoginBtn;

@property(nonatomic, strong) UIButton *captchaBtn;

@end

@implementation NTESRegisterVCViewController

- (BOOL)isNaviBarVisible {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupSubViews];
    [self setupConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.captchaBtn releaseTimeAtCaptchaButton];
}

- (void)setupSubViews {
    //设置背景图片
    UIImage *backGroundImage=[UIImage imageNamed:@"bg_denglu"];
    self.view.contentMode=UIViewContentModeScaleAspectFill;
    self.view.layer.contents=(__bridge id _Nullable)(backGroundImage.CGImage);
    
    _logoImg = ({
        UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo1"]];
        img;
    });
    
    _inputContainerView = ({
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor clearColor];
        view;
    });
    
    _line1 = ({
        UIView *line = [UIView new];
        line.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        line;
    });
    
    _line2 = ({
        UIView *line = [UIView new];
        line.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        line;
    });
    
    _line3 = ({
        UIView *line = [UIView new];
        line.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        line;
    });
    
    _line4 = ({
        UIView *line = [UIView new];
        line.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        line;
    });
    
    _line5 = ({
        UIView *line = [UIView new];
        line.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        line;
    });
    
    _accountImg = ({
        UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_yonghuming_"]];
        img;
    });
    _nickImg = ({
        UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nicheng"]];
        img;
    });
    
    _mobileImg = ({
        UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mobile"]];
        img;
    });
    
    _verifyImg = ({
        UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verify"]];
        img;
    });
    
    _passwordImg = ({
        UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_mima_"]];
        img;
    });
    
    _accountTextfield = ({
        UITextField *tf = [UITextField new];
        tf.placeholder = @"账号限6~20位字母或者数字";
        tf.textColor = [UIColor whiteColor];
        tf.font = [UIFont systemFontOfSize:15.f];
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        tf.keyboardType = UIKeyboardTypeDefault;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        [tf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        tf;
    });
    
    _nicknameTextfield = ({
        UITextField *tf = [UITextField new];
        tf.placeholder = @"昵称限10位汉字、字母或者数字";
        tf.textColor = [UIColor whiteColor];
        tf.font = [UIFont systemFontOfSize:15.f];
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        tf.keyboardType = UIKeyboardTypeDefault;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        [tf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        tf;
    });
    
    _mobileTextfield = ({
        UITextField *tf = [UITextField new];
        tf.placeholder = @"请输入手机号码";
        tf.textColor = [UIColor whiteColor];
        tf.font = [UIFont systemFontOfSize:15.f];
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        tf.keyboardType = UIKeyboardTypeNumberPad;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        [tf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        tf;
    });
    
    _verifyCodeTextfield = ({
        UITextField *tf = [UITextField new];
        tf.placeholder = @"请输入手机短信验证码";
        tf.textColor = [UIColor whiteColor];
        tf.font = [UIFont systemFontOfSize:15.f];
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        tf.keyboardType = UIKeyboardTypeNumberPad;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        [tf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

        tf;
    });
    
    _passwordTextfield = ({
        UITextField *tf = [UITextField new];
        tf.placeholder = @"密码限6~20位字母或数字";
        tf.textColor = [UIColor whiteColor];
        tf.secureTextEntry = YES;
        tf.clearButtonMode = UITextFieldViewModeWhileEditing;
        tf.font = [UIFont systemFontOfSize:15.f];
        tf.keyboardType = UIKeyboardTypeDefault;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        [tf addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

        tf;
    });
    
    _registerBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.frame = CGRectMake(0, 0, self.view.width - 40, 48);
        btn.layer.cornerRadius = 24;
        [btn setTitleColor:UIColorFromRGB(0x238efa) forState:UIControlStateNormal];
        [btn setTitle:@"注册" forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_wancheng_normal"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_wancheng_pressed"] forState:UIControlStateDisabled];
        [btn setBackgroundImage:[UIImage imageNamed:@"btn_wancheng_pressed"] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(doRegisterAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.enabled = NO;
        btn;
    });
    
    _goLoginBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:@"已有账号，快速登录 >" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(goLoginBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    _captchaBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor whiteColor];
        btn.layer.cornerRadius = 4;
        btn.layer.masksToBounds = YES;
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn setTitleColor:UIColorFromRGB(0x238efa) forState:UIControlStateNormal];
        [btn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(captchaButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    [@[_logoImg, _inputContainerView,
     _goLoginBtn] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
           [self.view addSubview:view];
       }];
    
    [@[_accountTextfield, _nicknameTextfield,
       _mobileTextfield, _verifyCodeTextfield,
       _passwordTextfield,_line1, _line2,
       _line3, _line4, _line5, _captchaBtn,
       _accountImg, _nickImg, _mobileImg,
       _verifyImg, _passwordImg, _registerBtn] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
           [self.inputContainerView addSubview:view];
       }];
    
    [self.view bringSubviewToFront:self.captchaBtn];
}

- (void)setupConstraints {
    [self.logoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(@56);
        make.height.equalTo(@57);
        make.top.equalTo(self.view.mas_top).offset(98);
    }];
    
    [self.inputContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.view.height == 568) {
            make.top.equalTo(self.view.mas_top).offset(180 * UISreenHeightScale);
        }
        else {
            make.top.equalTo(self.view.mas_top).offset(200 * UISreenHeightScale);
        }
        make.left.equalTo(self.view.mas_left).offset(20);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.height.equalTo(@332.5);
    }];
    [self.line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.inputContainerView.mas_width);
        make.left.equalTo(self.inputContainerView.mas_left);
        make.height.equalTo(@0.5);
        make.top.equalTo(self.inputContainerView.mas_top).offset(52);
    }];
    [self.line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.inputContainerView.mas_width);
        make.left.equalTo(self.inputContainerView.mas_left);
        make.height.equalTo(@0.5);
        make.top.equalTo(self.line1.mas_bottom).offset(52);
    }];
    [self.line3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.inputContainerView.mas_width);
        make.left.equalTo(self.inputContainerView.mas_left);
        make.height.equalTo(@0.5);
        make.top.equalTo(self.line2.mas_bottom).offset(52);
    }];
    [self.line4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.inputContainerView.mas_width);
        make.left.equalTo(self.inputContainerView.mas_left);
        make.height.equalTo(@0.5);
        make.top.equalTo(self.line3.mas_bottom).offset(52);
    }];
    [self.line5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.inputContainerView.mas_width);
        make.left.equalTo(self.inputContainerView.mas_left);
        make.height.equalTo(@0.5);
        make.top.equalTo(self.line4.mas_bottom).offset(52);
    }];
    [self.accountTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@52);
        make.left.equalTo(self.accountImg.mas_right).offset(8);
        make.bottom.equalTo(self.line1.mas_top);
        make.right.equalTo(self.inputContainerView.mas_right);
    }];
    [self.nicknameTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@52);
        make.left.equalTo(self.nickImg.mas_right).offset(8);
        make.bottom.equalTo(self.line2.mas_top);
        make.right.equalTo(self.inputContainerView.mas_right);
    }];
    [self.mobileTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@52);
        make.left.equalTo(self.mobileImg.mas_right).offset(8);
        make.bottom.equalTo(self.line3.mas_top);
        make.right.equalTo(self.inputContainerView.mas_right);
    }];
    [self.verifyCodeTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@52);
        make.left.equalTo(self.verifyImg.mas_right).offset(8);
        make.bottom.equalTo(self.line4.mas_top);
        make.right.equalTo(self.inputContainerView.mas_right);

    }];
    [self.passwordTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@52);
        make.left.equalTo(self.passwordImg.mas_right).offset(8);
        make.bottom.equalTo(self.line5.mas_top);
        make.right.equalTo(self.inputContainerView.mas_right);
    }];
    
    [self.registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(self.view.mas_width).multipliedBy(0.85);
        make.height.equalTo(@40);
        if (self.view.height == 568) {//5S
            make.bottom.equalTo(self.inputContainerView.mas_bottom).offset(-5);
        }
        else {
            make.bottom.equalTo(self.inputContainerView.mas_bottom).offset(-5);
        }
    }];
    
    [self.goLoginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@130);
        make.height.equalTo(@15);
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-41);
    }];
    
    [self.captchaBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mobileTextfield.mas_right).offset(-5);
        make.centerY.equalTo(self.mobileTextfield.mas_centerY);
        make.width.equalTo(@92);
        make.height.equalTo(@37);
    }];
    
    [self.accountImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@30);
        make.left.equalTo(self.inputContainerView.mas_left);
        make.centerY.equalTo(self.accountTextfield.mas_centerY);
    }];
    
    [self.nickImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@30);
        make.left.equalTo(self.inputContainerView.mas_left);
        make.centerY.equalTo(self.nicknameTextfield.mas_centerY);
    }];
    
    [self.mobileImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@30);
        make.left.equalTo(self.inputContainerView.mas_left);
        make.centerY.equalTo(self.mobileTextfield.mas_centerY);
    }];
    
    [self.verifyImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@30);
        make.left.equalTo(self.inputContainerView.mas_left);
        make.centerY.equalTo(self.verifyCodeTextfield.mas_centerY);
    }];
    
    [self.passwordImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@30);
        make.left.equalTo(self.inputContainerView.mas_left);
        make.centerY.equalTo(self.passwordTextfield.mas_centerY);
    }];
}

#pragma mark - Action

- (void)doRegisterAction:(UIButton *)sender {
    //检测网络
    WEAK_SELF(weakSelf);
    [[RealReachability sharedInstance] reachabilityWithBlock:^(ReachabilityStatus status) {
        if (status == RealStatusNotReachable) {
            [weakSelf.view makeToast:@"无网络，请检查网络设置" duration:2 position:CSToastPositionCenter];
        }
        else
        {
            [weakSelf doRegister];
        }
    }];
}

- (void)captchaButtonAction:(UIButton *)sender {
    
    NSString *phone = [self.mobileTextfield.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
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
        [[NTESLoginManager sharedManager] getRegisterVerifyCode:phone complete:^(NSError *error) {
            [SVProgressHUD dismiss];
            if (error)
            {
                NSString *cause = (error.userInfo[NTES_ERROR_MSG_KEY] ?: @"");
                NSString *toast = [NSString stringWithFormat:@"获取验证码失败: %@", cause];
                [weakSelf.view makeToast:toast duration:2 position:CSToastPositionCenter];
            }
            else
            {
                [weakSelf.view makeToast:@"获取验证码成功" duration:2 position:CSToastPositionCenter];
            }
        }];
    }
}

- (void)goLoginBtnAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldDidChange:(UITextField *)sender {
    BOOL enable = (_accountTextfield.text.length != 0 &&
                   _nicknameTextfield.text.length != 0 &&
                   _passwordTextfield.text.length != 0 &&
                   _mobileTextfield.text.length != 0 &&
                   _verifyCodeTextfield.text.length > 3);
    
    self.registerBtn.enabled = enable;
    
    if (sender == self.verifyCodeTextfield) {
        if (sender.text.length > 6){
            sender.text = [sender.text substringToIndex:6];
        }
    }
}

#pragma mark - 重载

- (void)doKeyboardChangedWithTransition:(YYKeyboardTransition)transition {
    CGFloat adjustDistance = 0.0;
    if (transition.toVisible) {
        if (self.view.height == 568) {//5S
            adjustDistance = 52 * UISreenHeightScale;
        }
        else {
            adjustDistance = 90 * UISreenHeightScale;
            
        }
        [UIView animateWithDuration:transition.animationDuration animations:^{
            _logoImg.hidden = YES;
            [self.inputContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_top).offset(adjustDistance);
            }];
            [self.view layoutIfNeeded];
        }];
    }
    else {
        if (self.view.height == 568) {//5S
            adjustDistance = 180 * UISreenHeightScale;
        }
        else {
            adjustDistance = 200 * UISreenHeightScale;
        }
        [UIView animateWithDuration:transition.animationDuration animations:^{
            _logoImg.hidden = NO;
            [self.inputContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.view.mas_top).offset(adjustDistance);
            }];
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark - Private

- (void)doRegister {
    NTESAccount *data = [[NTESAccount alloc] init];
    data.accid = self.accountTextfield.text;
    data.nickname= self.nicknameTextfield.text;
    data.password = [NTESEncryption md5EncryptWithString:self.passwordTextfield.text];
    data.phone = self.mobileTextfield.text;
    data.verifyCode = self.verifyCodeTextfield.text;
    if (![self check]) {
        return;
    }
    [SVProgressHUD showWithStatus:@"注册中..."];
    __weak typeof(self) weakSelf = self;
    [[NTESLoginManager sharedManager] registUser:data complete:^(NTESAccount *account, NSError *error) {
        [SVProgressHUD dismiss];
        if (error)
        {
            NSString *cause = (error.userInfo[NTES_ERROR_MSG_KEY] ?: @"");
            NSString *toast = [NSString stringWithFormat:@"注册失败: %@", cause];
            [weakSelf.view makeToast:toast duration:2 position:CSToastPositionCenter];
        }
        else
        {
            [weakSelf.view makeToast:@"注册成功" duration:2 position:CSToastPositionCenter];
            if (weakSelf.completeBlock) {
                weakSelf.completeBlock(data.accid, self.passwordTextfield.text);
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (BOOL)check{
    
    if (![NSString checkUserName:_accountTextfield.text])
    {
        [self.view makeToast:@"帐号限20位字母或者数字" duration:2.0 position:CSToastPositionCenter];
        return NO;
    }
    
    if (![NSString checkNickName:_nicknameTextfield.text])
    {
        [self.view makeToast:@"昵称限10位汉字、字母或者数字" duration:2.0 position:CSToastPositionCenter];
        return NO;
    }
    
    if (![NSString checkPassword:_passwordTextfield.text])
    {
        [self.view makeToast:@"密码限6~20位字母或数字" duration:2.0 position:CSToastPositionCenter];
        return NO;
    }
    
    return YES;
}

- (BOOL)isValidMobile:(NSString *)phone {
    NSString *phoneRegex = @"^1[3|4|5|7|8][0-9]{9}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:phone];
}

@end
