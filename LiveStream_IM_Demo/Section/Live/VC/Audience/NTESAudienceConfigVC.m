//
//  NTESAudienceConfigVC.m
//  NEUIDemo
//
//  Created by Netease on 17/1/3.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESAudienceConfigVC.h"
#import "NTESSegmentControl.h"
#import "NTESRoomNumberVC.h"
#import "NTESRoomAddressVC.h"

@interface NTESAudienceConfigVC ()

@property (nonatomic, strong) NTESSegmentControl *segCtl;
@end

@implementation NTESAudienceConfigVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupSubViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
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
    self.title = @"我是观众";
    self.navigationItem.leftBarButtonItems = nil;
    
    NTESRoomNumberVC *numberRoomVC = [NTESRoomNumberVC new];
    NTESRoomAddressVC *addressRoomVC = [NTESRoomAddressVC new];
    
    _segCtl = [[NTESSegmentControl alloc] initWithItems:@[numberRoomVC.view, addressRoomVC.view] enableEdgePan:NO andHighlightTitle:NO];
    _segCtl.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64.0);
    [_segCtl setTitle:@"房间号观看" forSegmentAtIndex:0];
    [_segCtl setTitle:@"地址观看" forSegmentAtIndex:1];
    [self.view addSubview:_segCtl];
    
    [self addChildViewController:numberRoomVC];
    [self addChildViewController:addressRoomVC];
}

@end
