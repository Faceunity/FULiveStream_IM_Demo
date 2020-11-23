//
//  NENavigationController.m
//  LSMediaCaptureDemo
//
//  Created by taojinliang on 2016/12/29.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "NENavigationController.h"

@interface NENavigationController ()

@end

@implementation NENavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 画面旋转
-(BOOL)shouldAutorotate
{
    return [self.topViewController shouldAutorotate];
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
- (NSUInteger)supportedInterfaceOrientations
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
#endif
{
    return [self.topViewController supportedInterfaceOrientations];
}

@end
