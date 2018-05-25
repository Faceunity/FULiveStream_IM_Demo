//
//  NTESUpdateDetailThumbCell.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/3/10.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESUpdateDetailThumbCell.h"

@interface NTESUpdateDetailThumbCell ()

@property (nonatomic, strong) UIImageView *imgView;

@end

@implementation NTESUpdateDetailThumbCell

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
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.imgView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!CGRectEqualToRect(_imgView.frame, self.contentView.bounds)) {
        _imgView.frame = self.contentView.bounds;
    }
}

#pragma mark - Public
- (void)configCellWithImage:(UIImage *)thumbImg imgUrl:(NSString *)imgUrl
{
    if (thumbImg) {
        _imgView.image = thumbImg;
    }
    else if (imgUrl)
    {
        NSURL *url = [NSURL URLWithString:imgUrl];
        [_imgView yy_setImageWithURL:url options:YYWebImageOptionSetImageWithFadeAnimation];
    }
}

#pragma mark - Getter
- (UIImageView *)imgView
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imgView;
}

@end
