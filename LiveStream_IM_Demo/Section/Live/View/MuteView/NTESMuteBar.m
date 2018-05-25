//
//  NTESMuteBar.m
//  NEUIDemo
//
//  Created by Netease on 17/1/6.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESMuteBar.h"

@interface NTESMuteBar ()

@property (weak, nonatomic) IBOutlet UIImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLab;
@property (weak, nonatomic) IBOutlet UIButton *kickBtn;
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;

@property (strong, nonatomic) UIAlertView *kickAlert;
@property (strong, nonatomic) UIAlertView *muteAlert;

@end

@implementation NTESMuteBar

+ (instancetype)instancView
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([NTESMuteBar class]) owner:nil options:nil];
    return array.lastObject;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = UIColorFromRGBA(0x0, 0.8);
    _avatorImageView.layer.cornerRadius = 34.0;
}

#pragma mark - Setter/Getter
- (void)setUserInfo:(NTESMember *)userInfo
{
    if (userInfo.showName) {
        _userNameLab.text = userInfo.showName;
    }
    
    //image
    [_avatorImageView setCircleImageWithUrl:userInfo.avatarUrlString];
    
    if (userInfo.isKicked)
    {
        _kickBtn.enabled = NO;
        _muteBtn.enabled = NO;
    }
    else
    {
        _kickBtn.enabled = YES;
        _muteBtn.enabled = YES;
        
        if (userInfo.isMuted) //已经被禁言了
        {
            [_muteBtn setTitle:@"解禁" forState:UIControlStateNormal];
        }
        else
        {
            [_muteBtn setTitle:@"禁言" forState:UIControlStateNormal];
        }
    }

    _userInfo = userInfo;
}

- (UIAlertView *)kickAlert
{
    if (!_kickAlert) {
        _kickAlert = [[UIAlertView alloc] initWithTitle:nil
                                                message:@"确定将此人踢出直播间?"
                                               delegate:nil
                                      cancelButtonTitle:@"取消"
                                      otherButtonTitles:@"确定", nil];
    }
    return _kickAlert;
}

- (UIAlertView *)muteAlert
{
    if (!_muteAlert) {
        _muteAlert = [[UIAlertView alloc] initWithTitle:nil
                                                message:@"确定将此人在该直播间禁言?"
                                               delegate:nil
                                      cancelButtonTitle:@"取消"
                                      otherButtonTitles:@"确定", nil];
    }
    return _muteAlert;
}

#pragma mark - Action
- (IBAction)kickAction:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
    [self.kickAlert showAlertWithCompletionHandler:^(NSInteger index) {

        if (index == 1) {
            if (weakSelf.kickBlock) {
                weakSelf.kickBlock(weakSelf.userInfo);
            }
        }
    }];
}

- (IBAction)muteAction:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
    [self.muteAlert showAlertWithCompletionHandler:^(NSInteger index) {

        if (index == 1) {
            if (weakSelf.muteBlock) {
                weakSelf.muteBlock(weakSelf.userInfo);
            }
        }
    }];
}

@end
