//
//  NERootTableViewCell.h
//  LSMediaCaptureDemo
//
//  Created by emily on 16/10/20.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NERootTableViewCell : UITableViewCell

@property(nonatomic, strong) id data;

- (void)reloadData;

+ (instancetype)dequeueReuseableCellForTabelView:(UITableView *)tableView;
+ (NSString *)cellIdentifier;

- (void)setupSubViews;
- (void)setupConstraints;

@end
