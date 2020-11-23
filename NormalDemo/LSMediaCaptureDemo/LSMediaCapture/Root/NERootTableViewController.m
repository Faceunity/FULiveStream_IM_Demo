//
//  NERootTableViewController.m
//  LSMediaCaptureDemo
//
//  Created by emily on 16/10/20.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "NERootTableViewController.h"

@interface NERootTableViewController ()

@end

@implementation NERootTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] bounds] style:UITableViewStylePlain];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.tableFooterView = [UIView new];
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        tableView;
    });
    
    [self registerCells];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)registerCells {
    NSAssert(0, @"need rewrite");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    return cell;
}

@end
