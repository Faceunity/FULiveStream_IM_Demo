//
//  NTESDemandHomeVC.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/2/28.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESDemandHomeVC.h"
#import "NTESSegmentControl.h"
#import "NTESDemandUpdateVC.h"
#import "NTESDemandVC.h"

@interface NTESDemandHomeVC ()

@property (nonatomic, strong) NTESSegmentControl *segCtl;
@property (nonatomic, strong) NTESDemandUpdateVC *updateVC;
@property (nonatomic, strong) NTESDemandVC *domandVC;

@end

@implementation NTESDemandHomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupSubViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (!CGRectEqualToRect(_segCtl.frame, self.view.bounds)) {
        _segCtl.frame = self.view.bounds;
    }
}

- (void)setupSubViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.segCtl];
}

- (BOOL)shouldAutorotate
{
    if (_segCtl.selectedSegmentIndex == 0) {
        return [self.updateVC shouldAutorotate];
    }
    else if (_segCtl.selectedSegmentIndex == 1) {
        return [self.domandVC shouldAutorotate];
    }
    else {
        return NO;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if (_segCtl.selectedSegmentIndex == 0) {
        return [self.updateVC supportedInterfaceOrientations];
    }
    else if (_segCtl.selectedSegmentIndex == 1) {
        return [self.domandVC supportedInterfaceOrientations];
    }
    else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

#pragma mark - Getter
- (NTESSegmentControl *)segCtl
{
    if (!_segCtl) {
        NSArray *items = @[self.updateVC.view, self.domandVC.view];
        _segCtl = [[NTESSegmentControl alloc] initWithItems:items enableEdgePan:YES andHighlightTitle:NO];
        _segCtl.headerBackColor = UIColorFromRGB(0xf7f7f9);
        _segCtl.showSeparateLine = YES;
        [_segCtl setTitle:@"视频管理" forSegmentAtIndex:0];
        [_segCtl setTitle:@"地址播放" forSegmentAtIndex:1];
        [self addChildViewController:_updateVC];
        [self addChildViewController:_domandVC];
    }
    return _segCtl;
}

- (NTESDemandUpdateVC *)updateVC
{
    if (!_updateVC) {
        _updateVC = [NTESDemandUpdateVC new];
    }
    return _updateVC;
}

- (NTESDemandVC *)domandVC
{
    if (!_domandVC) {
        _domandVC = [NTESDemandVC new];
    }
    return _domandVC;
}


@end
