//
//  NTESPresentShopCell.m
//  NIMLiveDemo
//
//  Created by chris on 16/3/29.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NTESPresentShopCell.h"
#import "UIView+NTES.h"

@interface NTESPresentShopCell()

@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,strong) UILabel *nameLabel;

@property (nonatomic,strong) UIView *right_line;

@end

@implementation NTESPresentShopCell

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    self.contentView.layer.borderColor = [[UIColor blueColor] CGColor];
    self.contentView.layer.borderWidth = (selected ? 1.f : 0.f);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView = [[UIImageView alloc] init];
        [self addSubview:self.imageView];
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.font = [UIFont systemFontOfSize:13.f];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.nameLabel];
    }
    return self;
}

- (void)refreshPresent:(NTESPresent *)present
{
    UIImage *image = [UIImage imageNamed:present.icon];
    self.imageView.image = image;
    [self.imageView sizeToFit];
    
    self.nameLabel.text = present.name;
    [self.nameLabel sizeToFit];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.imageView.center = CGPointMake(self.width/2, (self.height - self.nameLabel.height)/2);
    self.nameLabel.frame = CGRectMake(0,
                                      self.imageView.bottom + 12.0,
                                      self.width,
                                      self.nameLabel.height);
}

@end
