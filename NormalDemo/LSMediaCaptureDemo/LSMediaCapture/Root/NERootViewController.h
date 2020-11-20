//
//  NERootViewController.h
//  LSMediaCaptureDemo
//
//  Created by emily on 16/10/20.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NERootViewController : UIViewController

- (void)configNavigationBarWithLeftButtonTitle:(NSString *)leftTitle rightTitle:(NSString *)rightTitle;

- (void)navigationBarLeftButtonTapped:(UIButton *)sender;
- (void)navigationBarRightButtonTapped:(UIButton *)sender;

- (void)popViewController;

@property(nonatomic, copy) NSString *naviBarLeftTitle;
@property(nonatomic, copy) NSString *naviBarRightTitle;

@end
