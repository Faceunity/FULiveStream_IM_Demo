//
//  NTESNormalMessageCell.m
//  NEUIDemo
//
//  Created by Netease on 17/1/4.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESNormalMessageCell.h"
#import "NTESTextMessage.h"

#define ChatCellDefaultMessageFont [UIFont systemFontOfSize:14]

@interface NTESNormalMessageCell ()

@property (nonatomic, strong) YYLabel *attributedLabel;

@end

@implementation NTESNormalMessageCell

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
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.attributedLabel];
    }
    return self;
}


- (void)refresh:(NTESTextMessage *)model
{
    [self.attributedLabel setAttributedText:model.formatString];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.attributedLabel.frame = CGRectMake(self.contentView.left + ChatCellDefaultChatInterval,
                                            self.contentView.top,
                                            self.contentView.width - ChatCellDefaultChatInterval,
                                            self.contentView.height - ChatCellDefaultChatInterval);
}

#pragma mark - Get
- (YYLabel *)attributedLabel
{
    if (!_attributedLabel)
    {
        _attributedLabel = [[YYLabel alloc] init];
        _attributedLabel.numberOfLines = 0;
        _attributedLabel.font = ChatCellDefaultMessageFont;
        _attributedLabel.backgroundColor = [UIColor clearColor];
        _attributedLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    return _attributedLabel;
}

@end
