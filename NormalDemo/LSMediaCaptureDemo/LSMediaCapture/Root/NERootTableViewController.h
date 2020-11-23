//
//  NERootTableViewController.h
//  LSMediaCaptureDemo
//
//  Created by emily on 16/10/20.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "NERootViewController.h"

@interface NERootTableViewController : NERootViewController <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UITableView *tableView;

- (void)registerCells;

@end
