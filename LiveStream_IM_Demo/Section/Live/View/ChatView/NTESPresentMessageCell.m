//
//  NTESPresentMessageCell.m
//  NEUIDemo
//
//  Created by Netease on 17/1/5.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESPresentMessageCell.h"
#import "NTESPresentMessage.h"
#import "NTESMember.h"

@interface NTESPresentMessageCell ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *avatar;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) YYLabel *contentLabel;
@property (nonatomic, strong) UIImageView *presentImageView;
@property (nonatomic, strong) YYLabel *countLabel;
@property (nonatomic, weak) NTESPresentMessage *present;
@end

@implementation NTESPresentMessageCell

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
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.alpha = 0.0;
        [self.contentView addSubview:self.backgroundImageView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.avatar];
        [self.contentView addSubview:self.contentLabel];
        [self.contentView addSubview:self.presentImageView];
        [self.contentView addSubview:self.countLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //背景图片
    self.backgroundImageView.frame = CGRectMake(self.bounds.origin.x + 8.0,
                                           self.bounds.origin.y + 8.0,
                                           self.bounds.size.width - 2 * 8.0 - 40.0,
                                           self.bounds.size.height - 2 * 8.0);
    self.backgroundView.layer.cornerRadius = self.backgroundView.height/2;
    
    //头像
    self.avatar.frame = CGRectMake(self.backgroundImageView.left - 4.0,
                                   self.backgroundImageView.top - 4.0,
                                   self.backgroundImageView.height + 8.0,
                                   self.backgroundImageView.height + 8.0);
    self.avatar.layer.cornerRadius = self.avatar.height/2;
    
    
    //礼物个数
    self.countLabel.frame = CGRectMake(self.backgroundImageView.right + 8.0,
                                         self.backgroundImageView.top,
                                         40.0,
                                         self.backgroundImageView.height);
    
    //礼物图片
    self.presentImageView.frame = CGRectMake(self.backgroundImageView.right - self.backgroundImageView.height,
                                             self.backgroundImageView.top - 4.0,
                                             self.backgroundImageView.height,
                                             self.backgroundImageView.height);
    //姓名
    [self.nameLabel sizeToFit];
    self.nameLabel.frame = CGRectMake(self.avatar.right + 8.0,
                                      self.backgroundImageView.top + 4.0,
                                      self.presentImageView.left - self.avatar.right - 8.0*2,
                                      self.nameLabel.height);
    //信息
    [self.contentLabel sizeToFit];
    self.contentLabel.frame = CGRectMake(self.nameLabel.left,
                                         self.nameLabel.bottom + 4.0,
                                         self.nameLabel.width,
                                         self.contentLabel.height);
}

- (CGSize)sizeOfAttrString:(NSMutableAttributedString *)attrString
{
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(CGFLOAT_MAX, MAXFLOAT)];
    YYTextLayout *textLayout = [YYTextLayout layoutWithContainer:container text:attrString];
    return textLayout.textBoundingSize;
}

- (void)refreshWithPresent:(NTESPresentMessage *)present
{
    if ([present isKindOfClass:[NSNull class]]) {
        return;
    }
    
    _present = present;
    
    if (present.sender)
    {
        //头像
        [self.avatar setCircleImageWithUrl:present.sender.avatarUrlString];

        //姓名
        self.nameLabel.text = present.sender.showName;
    }

    //信息
    NSString *name = present.present.name;
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"送了%@",name]];
    [attrString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:11.f],NSForegroundColorAttributeName:UIColorFromRGB(0xffffff)} range:NSMakeRange(0, 2)];
    [attrString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:11.f],NSForegroundColorAttributeName:UIColorFromRGB(0x6aa1d9)} range:NSMakeRange(attrString.length - name.length, name.length)];
    [self.contentLabel setAttributedText:attrString];
    self.contentLabel.size = [self sizeOfAttrString:attrString];
    
    //礼物图片
    self.presentImageView.image = [UIImage imageNamed:present.present.icon];
    [self.presentImageView sizeToFit];
    
    //个数
    NSString *count = [NSString stringWithFormat:@"x%zd",present.present.count];
    attrString = [[NSMutableAttributedString alloc] initWithString:count];
    [attrString addAttributes:@{
                                NSFontAttributeName:[UIFont boldSystemFontOfSize:18.f],
                                NSForegroundColorAttributeName:UIColorFromRGB(0x238efa),
                                NSStrokeColorAttributeName:[UIColor whiteColor],
                                NSStrokeWidthAttributeName:@(-5.0f)
                                } range:NSMakeRange(0, 1)];
    
    [attrString addAttributes:@{
                                NSFontAttributeName:[UIFont boldSystemFontOfSize:22.f],
                                NSForegroundColorAttributeName:UIColorFromRGB(0x238efa),
                                NSStrokeColorAttributeName:[UIColor whiteColor],
                                NSStrokeWidthAttributeName:@(-5.0f)
                                } range:NSMakeRange(1, count.length-1)];
    [self.countLabel setAttributedText:attrString];
    self.countLabel.size = [self sizeOfAttrString:attrString];
}

#pragma mark - Public
- (void)show
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    
    self.contentView.right = 0;
    [self setNeedsLayout];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.contentView.alpha = 1.0;
        self.contentView.left = 0;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(hide) withObject:nil afterDelay:1.0];
    }];
}

- (void)hide
{
    [UIView animateWithDuration:0.2 animations:^{
        self.contentView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (_delegate && [_delegate respondsToSelector:@selector(cellDidHide:present:)]) {
            [self.delegate cellDidHide:self present:_present];
        }
    }];
}

#pragma mark - Get
- (UIImageView *)backgroundImageView
{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 110, 30)];
        _backgroundImageView.image = [[UIImage imageNamed:@"icon_live_present_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch];
    }
    return _backgroundImageView;
}

- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont systemFontOfSize:8.f];
        _nameLabel.textColor = UIColorFromRGB(0xb4b3b2);
    }
    return _nameLabel;
}

- (UIImageView *)avatar
{
    if (!_avatar) {
        _avatar = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        _avatar.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _avatar;
}

- (YYLabel *)contentLabel
{
    if (!_contentLabel) {
        _contentLabel = [[YYLabel alloc] initWithFrame:CGRectZero];
        _contentLabel.backgroundColor = [UIColor clearColor];
    }
    return _contentLabel;
}

- (UIImageView *)presentImageView
{
    if (!_presentImageView) {
        _presentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _presentImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _presentImageView;
}

- (YYLabel *)countLabel
{
    if (!_countLabel) {
        _countLabel = [[YYLabel alloc] initWithFrame:CGRectZero];
        _countLabel.backgroundColor = [UIColor clearColor];
    }
    return _countLabel;
}


@end
