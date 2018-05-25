//
//  NTESAnchorConfigCell.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/1/10.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESAnchorConfigCell.h"

@interface NTESAnchorConfigCell ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UISwitch *switchView;
@property (nonatomic, strong) UILabel *accessoryLab;
@property (nonatomic, strong) UIView *line;

@end

@implementation NTESAnchorConfigCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setSeparatorInset:UIEdgeInsetsZero];
        [self setLayoutMargins:UIEdgeInsetsZero];
        [self addSubview:self.titleLab];
        [self addSubview:self.switchView];
        [self addSubview:self.accessoryLab];
        [self addSubview:self.line];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLab.frame = CGRectMake(16.0, 0, self.titleLab.width, self.contentView.height);
    self.switchView.left = self.contentView.width - self.switchView.width - 16.0;
    self.switchView.centerY = self.contentView.height / 2;
    self.accessoryLab.frame = CGRectMake(self.contentView.width - 48.0,
                                         0,
                                         48.0,
                                         self.contentView.height - 1.0);
    self.line.frame = CGRectMake(0, self.height - 1, self.width, 1);
}

- (void)config:(NSString *)title switchIsOn:(BOOL)isOn
{
    self.accessoryType = UITableViewCellAccessoryNone;
    self.accessoryLab.hidden = YES;
    self.switchView.hidden = NO;
    self.switchView.on = isOn;
    self.titleLab.text = title;
    [self.titleLab sizeToFit];
    
    [self setNeedsLayout];
}

- (void)config:(NSString *)title accessory:(NSString *)accessory
{
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.switchView.hidden = YES;
    self.accessoryLab.hidden = NO;
    self.accessoryLab.text = accessory;
    self.titleLab.text = title;
    [self.titleLab sizeToFit];
    
    [self setNeedsLayout];
}

- (void)switchAction:(UISwitch *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(configCell:switchIsOn:)]) {
        [_delegate configCell:self  switchIsOn:sender.isOn];
    }
}

#pragma mark - Getter/Setter
- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:15.0];
    }
    return _titleLab;
}

- (UISwitch *)switchView
{
    if (!_switchView) {
        _switchView = [[UISwitch alloc] init];
        _switchView.on = NO;
        _switchView.hidden = YES;
        [_switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _switchView;
}

- (UILabel *)accessoryLab
{
    if (!_accessoryLab) {
        _accessoryLab = [[UILabel alloc] init];
        _accessoryLab.font = [UIFont systemFontOfSize:14.0];
        _accessoryLab.textColor = [UIColor lightGrayColor];
        _accessoryLab.textAlignment = NSTextAlignmentRight;
        _accessoryLab.hidden = YES;
    }
    return _accessoryLab;
}

- (UIView *)line
{
    if (!_line) {
        _line = [UIView new];
        _line.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    return _line;
}

@end
