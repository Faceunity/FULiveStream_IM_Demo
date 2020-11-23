//
//  NERootTableViewCell.m
//  LSMediaCaptureDemo
//
//  Created by emily on 16/10/20.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "NERootTableViewCell.h"

@implementation NERootTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        
        [self setupSubViews];
        [self setupConstraints];
    }
    return self;
}

- (void)reloadData {
    //override when inheritted
}

+ (NSString *)cellIdentifier {
    return NSStringFromClass([self class]);
}

+ (instancetype)dequeueReuseableCellForTabelView:(UITableView *)tableView {
    id cell = [tableView dequeueReusableCellWithIdentifier:[self cellIdentifier]];
    if (!cell) {
      cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self cellIdentifier]];
    }
    return cell;
}

- (void)setupConstraints {
    NSAssert(0, @"need overwrite");
}

- (void)setupSubViews {
    NSAssert(0, @"need overwrite");
}



@end
