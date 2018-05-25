//
//  NTESAlbumCell.m
//  ShortVideo_Demo
//
//  Created by Netease on 17/2/13.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESAlbumCell.h"

@interface NTESAlbumCell ()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *durationLab;

@property (nonatomic, strong) UIImageView *selectView;

@property (nonatomic, strong) UIImage *selectImg;

@property (nonatomic, strong) UIImage *unselectImg;

@property (nonatomic, strong) UIView *maskView;

@end

@implementation NTESAlbumCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.imageView];
        [self addSubview:self.durationLab];
        [self addSubview:self.selectView];
        [self addSubview:self.maskView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!CGRectEqualToRect(self.imageView.frame, self.bounds))
    {
        self.imageView.frame = self.bounds;
        self.durationLab.frame = CGRectMake(self.imageView.width - self.durationLab.width - 10,
                                            self.imageView.height - self.durationLab.height - 10,
                                            self.durationLab.width,
                                            self.durationLab.height);
        self.selectView.frame = CGRectMake(self.imageView.right - 20 - 4,
                                           self.imageView.top + 4,
                                           20,
                                           20);
        self.maskView.frame = self.bounds;
    }
}

- (void)selectedCell:(BOOL)isSelect
{
    self.selectView.image = (isSelect ? self.selectImg : self.unselectImg);
}

- (void)confgiWithItem:(NTESAlbumVideoEntity *)item
{
    if (item) {
        self.imageView.image = item.thumbImg;
        self.durationLab.text = [NSString timeStringWithSecond:(NSInteger)item.duration minDigits:2];
        [self.durationLab sizeToFit];
    }
}

#pragma mark - Getter/Setter
- (UIImage *)selectImg
{
    if (!_selectImg) {
        _selectImg = [UIImage imageNamed:@"album_video_selected"];
    }
    return _selectImg;
}

- (UIImage *)unselectImg
{
    if (!_unselectImg) {
        _unselectImg = [UIImage imageNamed:@"album_video_unselected"];
    }
    return _unselectImg;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [UIColor blackColor];
    }
    return _imageView;
}

- (UILabel *)durationLab
{
    if (!_durationLab)
    {
        _durationLab = [[UILabel alloc] init];
        _durationLab.text = @"00:00";
        _durationLab.font = [UIFont systemFontOfSize:12.0];
        _durationLab.textColor = [UIColor whiteColor];
        [_durationLab sizeToFit];
        _durationLab.textAlignment = NSTextAlignmentCenter;
    }
    
    return _durationLab;
}

- (UIImageView *)selectView
{
    if (!_selectView) {
        _selectView = [[UIImageView alloc] init];
        _selectView.image = self.unselectImg;
        _selectView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _selectView;
}

- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [UIView new];
        _maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _maskView.hidden = YES;
    }
    return _maskView;
}

@end
