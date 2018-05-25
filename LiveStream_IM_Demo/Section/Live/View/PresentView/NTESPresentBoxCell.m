//
//  NTESPresentBoxCell.m
//  NIMLiveDemo
//
//  Created by chris on 16/3/31.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NTESPresentBoxCell.h"
#import "UIView+NTES.h"

@interface NTESPresentBoxCell()

@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,strong) UILabel *nameLabel;

@property (nonatomic,strong) UIView *right_line;

@property (nonatomic,strong) UIView *bottom_line;

@end

@implementation NTESPresentBoxCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imageView];
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.font = [UIFont systemFontOfSize:13.f];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        UIView *view = [[UIView alloc] initWithFrame:self.bounds];
        view.backgroundColor = [UIColor blackColor];
        self.selectedBackgroundView = view;
        [self addSubview:self.nameLabel];
    }
    return self;
}

- (void)refreshPresent:(NTESPresent *)present
                 count:(NSInteger)count
{
    UIImage *image = [UIImage imageNamed:present.icon];
    self.imageView.image = image;
    [self.imageView sizeToFit];
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    [attr appendAttributedString:
     [[NSAttributedString alloc] initWithString:[present.name stringByAppendingString:@" x "]
                                                attributes:@{NSFontAttributeName:self.nameLabel.font,
                                                             NSForegroundColorAttributeName:[UIColor whiteColor]}]];
    [attr appendAttributedString:
     [[NSAttributedString alloc] initWithString:@(count).stringValue
                                     attributes:@{NSFontAttributeName:self.nameLabel.font,
                                                  NSForegroundColorAttributeName:UIColorFromRGB(0xffff66)}]];
    [self.nameLabel setAttributedText:attr];
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
