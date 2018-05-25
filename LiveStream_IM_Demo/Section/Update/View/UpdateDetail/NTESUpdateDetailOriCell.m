//
//  NTESUpdateDetailOriCell.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/3/13.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESUpdateDetailOriCell.h"
#import "NTESTopAlignmentLabel.h"
#import "NTESVideoEntity.h"

@interface NTESUpdateDetailOriCell ()

@property (nonatomic, strong) UILabel *formatLab;
@property (nonatomic, strong) UILabel *sizeLab;
@property (nonatomic, strong) NTESTopAlignmentLabel *urlLab;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *shareBtn;

@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *videoFormat;
@property (nonatomic, assign) CGFloat fileSize;
@property (nonatomic, copy) NSString *videoName;

@end

@implementation NTESUpdateDetailOriCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.formatLab];
        [self addSubview:self.sizeLab];
        [self addSubview:self.urlLab];
        [self addSubview:self.playBtn];
        [self addSubview:self.shareBtn];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _formatLab.frame = CGRectMake(16, 16, _formatLab.width, _formatLab.height);
    _sizeLab.left = _formatLab.right + 16.0;
    _sizeLab.centerY = _formatLab.centerY;

    _shareBtn.frame = CGRectMake(self.contentView.right - 60 - 16.0,
                                 self.contentView.height - 35.0 - 16.0,
                                 60.0,
                                 35.0);
    _playBtn.frame = CGRectMake(_shareBtn.left - _shareBtn.width - 10.0,
                                _shareBtn.top,
                                _shareBtn.width,
                                _shareBtn.height);
    
    _urlLab.frame = CGRectMake(_formatLab.left,
                               _formatLab.bottom + 10.0,
                               self.contentView.width - 16 * 2,
                               _shareBtn.top - 10.0 - _formatLab.bottom - 10.0);
}

- (void)configCellWithItem:(NTESVideoEntity *)item delegate:(id <NTESUpdateDetailOriCellProtocol>)delegate
{
    if (item)
    {
        self.videoUrl = item.origUrl;
        
        self.videoFormat = item.extension;
        
        self.videoName = item.title;
        
        self.fileSize = item.fileSize;
        
        self.playBtn.enabled = ([_videoFormat isEqualToString:@"mp4"] || [_videoFormat isEqualToString:@"flv"]);

        _delegate = delegate;
    }
}

#pragma mark - Action
- (void)btnAction:(UIButton *)btn
{
    switch (btn.tag)
    {
        case 10: //播放
        {
            if (_delegate && [_delegate respondsToSelector:@selector(oriCell:playName:url:)]) {
                [_delegate oriCell:self playName:_videoName url:_videoUrl];
            }
            
            break;
        }
        case 11: //分享
        {
            if (_delegate && [_delegate respondsToSelector:@selector(oriCell:share:)]) {
                [_delegate oriCell:self share:_videoUrl];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - Setter
- (void)setVideoFormat:(NSString *)videoFormat
{
    if (![_videoFormat isEqualToString:videoFormat]) {
        videoFormat = ((videoFormat == nil) ? @"" : videoFormat);
        _videoFormat = videoFormat;
        _formatLab.text = videoFormat;
        [_formatLab sizeToFit];
    }
}

- (void)setVideoUrl:(NSString *)videoUrl
{
    if (![_videoUrl isEqualToString:videoUrl]) {
        videoUrl =  ((videoUrl == nil) ? @"" : videoUrl);
        _videoUrl = videoUrl;
        _urlLab.text = videoUrl;
    }
}

- (void)setFileSize:(CGFloat)fileSize
{
    if (fileSize != _fileSize) {
        _fileSize = fileSize;
        NSString *fileSizeStr = [NSString stringWithFormat:@"%.02f MB", fileSize];
        _sizeLab.text = fileSizeStr;
        [_sizeLab sizeToFit];
    }
}

#pragma mark - Getter
- (UILabel *)formatLab
{
    if (!_formatLab) {
        _formatLab = [[UILabel alloc] init];
        _formatLab.font = [UIFont systemFontOfSize:17.0];
        _formatLab.textColor = UIColorFromRGB(0x333333);
        _formatLab.text = @"未知";
        [_formatLab sizeToFit];
    }
    return _formatLab;
}

- (UILabel *)sizeLab
{
    if (!_sizeLab) {
        _sizeLab = [[UILabel alloc] init];
        _sizeLab.font = [UIFont systemFontOfSize:14.0];
        _sizeLab.textColor = UIColorFromRGB(0x999999);
        _sizeLab.text = @"未知";
        [_sizeLab sizeToFit];
    }
    return _sizeLab;
}

- (NTESTopAlignmentLabel *)urlLab
{
    if (!_urlLab) {
        _urlLab = [[NTESTopAlignmentLabel alloc] init];
        _urlLab.font = [UIFont systemFontOfSize:14.0];
        _urlLab.textColor = UIColorFromRGB(0x999999);
        _urlLab.numberOfLines = 0;
    }
    return _urlLab;
}

- (UIButton *)playBtn
{
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _playBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
        [_playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_playBtn setTitle:@"播放" forState:UIControlStateNormal];
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"btn_normal_blue"] forState:UIControlStateNormal];
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"btn_pressed_blue"] forState:UIControlStateHighlighted];
        [_playBtn setBackgroundImage:[UIImage imageNamed:@"btn_disabled_blue"] forState:UIControlStateDisabled];
        _playBtn.tag = 10;
        [_playBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UIButton *)shareBtn
{
    if (!_shareBtn) {
        _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
        [_shareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_shareBtn setTitle:@"分享" forState:UIControlStateNormal];
        [_shareBtn setBackgroundImage:[UIImage imageNamed:@"btn_normal_blue"] forState:UIControlStateNormal];
        [_shareBtn setBackgroundImage:[UIImage imageNamed:@"btn_pressed_blue"] forState:UIControlStateHighlighted];
        [_shareBtn setBackgroundImage:[UIImage imageNamed:@"btn_disabled_blue"] forState:UIControlStateDisabled];
        _shareBtn.tag = 11;
        [_shareBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareBtn;
}



@end
