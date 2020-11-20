//
//  NESettingTableViewCell.m
//  LSMediaCaptureDemo
//
//  Created by emily on 16/11/14.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "NESettingTableViewCell.h"
#import "Masonry.h"
#import "NEInternalMacro.h"

@interface NESettingTableViewCell () <UITextFieldDelegate>

@property(nonatomic, strong) UIView *line;

@end

@implementation NESettingTableViewCell

- (void)setupSubViews {
    self.inputTF = ({
        UITextField *tf = [UITextField new];
        tf.backgroundColor = [UIColor clearColor];
        tf.textColor = [UIColor blackColor];
        tf.keyboardType = UIKeyboardTypeNumberPad;
        tf;
    });
    self.line = ({
        UIView *line = [UIView new];
        line.backgroundColor = [UIColor colorWithRed:0.808 green:0.851 blue:0.906 alpha:1.00];
        line;
    });
    
    [self.contentView addSubview:self.inputTF];
    [self.contentView addSubview:self.line];
}

- (void)setupConstraints {
    [self.inputTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.top.equalTo(self.contentView.mas_top).offset(5);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-5);
        make.width.equalTo(@120);
    }];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.contentView.mas_width);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.equalTo(@1);
    }];
}

-(void)reloadData {
    
}

@end
