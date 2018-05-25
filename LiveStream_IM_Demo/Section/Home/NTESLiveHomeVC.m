//
//  NTESLiveHomeVC.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/3/1.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESLiveHomeVC.h"
#import "NTESAudienceConfigVC.h"
#import "NTESAnchorConfigVC.h"

@interface NTESLiveHomeVC ()

@property (nonatomic, strong) UIImageView *bgImgView;
@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UIButton *anchorBtn;
@property (nonatomic, strong) UIButton *audienceBtn;

@end

@implementation NTESLiveHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.bgImgView];
    [self.view addSubview:self.titleLab];
    [self.view addSubview:self.anchorBtn];
    [self.view addSubview:self.audienceBtn];
}

- (void)configNavigationBar {
    UIImage *backImg = [UIImage imageWithColor:UIColorFromRGB(0xf7f7f9) size:CGSizeMake(100, 100)];
    [[UINavigationBar appearance] setBackgroundImage:backImg forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (!CGRectEqualToRect(self.bgImgView.frame, self.view.bounds)) {
        self.bgImgView.frame = self.view.bounds;
        
        self.titleLab.top = 118 * UISreenHeightScale;
        self.titleLab.centerX = self.view.width/2;
        
        CGFloat width = 120 * UISreenWidthScale;
        CGFloat interval = 65.0 * UISreenWidthScale;
        self.anchorBtn.frame = CGRectMake((self.view.width - interval - width * 2)/2,
                                          60 * UISreenHeightScale + _titleLab.bottom,
                                          width,
                                          width);
        self.audienceBtn.frame = CGRectMake(_anchorBtn.right + interval,
                                            _anchorBtn.top,
                                            width,
                                            width);
    }
}

#pragma mark - Action
- (void)btnAction:(UIButton *)btn
{
    switch (btn.tag)
    {
        case 10: //主播
        {
            NSLog(@"进入主播配置页面");
            NTESAnchorConfigVC *push = [NTESAnchorConfigVC new];
            [self.navigationController pushViewController:push animated:YES];
            break;
        }
        case 11: //观众
        {
            NSLog(@"进入观众配置页面");
            NTESAudienceConfigVC *push = [NTESAudienceConfigVC new];
            [self.navigationController pushViewController: push animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Getter
- (UIImageView *)bgImgView
{
    if (!_bgImgView) {
        _bgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_home"]];
    }
    return _bgImgView;
}

- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        _titleLab.textColor = UIColorFromRGB(0x666666);
        _titleLab.font = [UIFont systemFontOfSize:17.0];
        _titleLab.text = @"请选择您的身份，开始体验";
        [_titleLab sizeToFit];
    }
    return _titleLab;
}

- (UIButton *)anchorBtn
{
    if (!_anchorBtn) {
        _anchorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_anchorBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
        [_anchorBtn setTitle:@"主播" forState:UIControlStateNormal];
        _anchorBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_anchorBtn setBackgroundImage:[UIImage imageNamed:@"btn_home_choose"] forState:UIControlStateNormal];
        [_anchorBtn setBackgroundImage:[UIImage imageNamed:@"btn_home_choose_n"] forState:UIControlStateHighlighted];
        _anchorBtn.tag = 10;
        [_anchorBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _anchorBtn;
}

- (UIButton *)audienceBtn
{
    if (!_audienceBtn)
    {
        _audienceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_audienceBtn setTitleColor:UIColorFromRGB(0x333333) forState:UIControlStateNormal];
        [_audienceBtn setTitle:@"观众" forState:UIControlStateNormal];
        [_audienceBtn setBackgroundImage:[UIImage imageNamed:@"btn_home_choose"] forState:UIControlStateNormal];
        [_audienceBtn setBackgroundImage:[UIImage imageNamed:@"btn_home_choose_n"] forState:UIControlStateHighlighted];
        _audienceBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        _audienceBtn.tag = 11;
        [_audienceBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _audienceBtn;
}

@end
