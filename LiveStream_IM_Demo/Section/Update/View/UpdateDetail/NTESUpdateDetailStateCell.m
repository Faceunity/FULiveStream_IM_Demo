//
//  NTESUpdateDetailStateCell.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/3/10.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESUpdateDetailStateCell.h"
#import "NTESTopAlignmentLabel.h"
#import "NTESVideoFormatEntity.h"
#import "NTESVideoEntity.h"

@interface NTESUpdateDetailStateCell ()

@property (nonatomic, weak) NTESVideoEntity *entity;

@property (nonatomic, assign) NTESVideoItemState state;
@property (nonatomic, assign) NTESVideoFormat format;
@property (nonatomic, copy)   NSString *videoUrl;
@property (nonatomic, copy)   NSString *videoName;
@property (nonatomic, assign) CGFloat  fileSize;

@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UILabel *formatLab;
@property (nonatomic, strong) UILabel *sizeLab;
@property (nonatomic, strong) NTESTopAlignmentLabel *urlLab;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *shareBtn;
@property (nonatomic, strong) UIButton *deleteBtn;

@end

@implementation NTESUpdateDetailStateCell

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
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.line];
        [self addSubview:self.formatLab];
        [self addSubview:self.sizeLab];
        [self addSubview:self.urlLab];
        [self addSubview:self.playBtn];
        [self addSubview:self.shareBtn];
        [self addSubview:self.deleteBtn];

    };
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _formatLab.frame = CGRectMake(16,
                                  16,
                                  _formatLab.width,
                                  _formatLab.height);
    
    _sizeLab.left = _formatLab.right + 16.0;
    _sizeLab.centerY = _formatLab.centerY;
    
    if (_line.width != self.width)
    {
        _line.frame = CGRectMake(0, self.height - 1.0, self.width, 1);
        
        _deleteBtn.frame = CGRectMake(self.contentView.right - 60 - 16.0,
                                      self.contentView.height - 35.0 - 16.0,
                                      60.0,
                                      35.0);
        _shareBtn.frame = CGRectMake(_deleteBtn.left - _deleteBtn.width - 10.0,
                                     _deleteBtn.top,
                                     _deleteBtn.width,
                                     _deleteBtn.height);
        _playBtn.frame = CGRectMake(_shareBtn.left - _shareBtn.width - 10.0,
                                    _shareBtn.top,
                                    _shareBtn.width,
                                    _shareBtn.height);
        
        _urlLab.frame = CGRectMake(_formatLab.left,
                                   _formatLab.bottom + 10.0,
                                   self.contentView.width - 16 * 2,
                                   _shareBtn.top - 10.0 - _formatLab.bottom - 10.0);
    }
}

#pragma mark - Public
- (void)configCellWithFormatItem:(NTESVideoFormatEntity *)item
                           state:(NTESVideoItemState)state
                        delegate:(id <NTESUpdateDetailStateCellProtocol>)delegate
{
    if (item)
    {
        self.format = item.format;
        self.videoUrl = item.url;
        if (item.url != nil) //只要存在url，说明是转码成功的，此时可以忽略外部状态
        {
            state = NTESVideoItemComplete;
        }
        self.state = state;
        self.fileSize = item.size;
        self.delegate = delegate;
    }
}

#pragma mark - Action
- (void)btnAction:(UIButton *)btn
{
    switch (btn.tag)
    {
        case 10: //播放
        {
            if (_delegate && [_delegate respondsToSelector:@selector(stateCell:playName:url:)]) {
                [_delegate stateCell:self playName:_videoName url:_videoUrl];
            }
            break;
        }
        case 11: //分享
        {
            if (_delegate && [_delegate respondsToSelector:@selector(stateCell:share:)]) {
                [_delegate stateCell:self share:_videoUrl];
            }
            break;
        }
        case 12: //删除
        {
            if (_delegate && [_delegate respondsToSelector:@selector(stateCell:delFormat:)]) {
                [_delegate stateCell:self delFormat:_format];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - Setter
- (void)setFileSize:(CGFloat)fileSize
{
    if (fileSize != _fileSize) {
        _fileSize = fileSize;
        
        NSString *fileSizeStr = [NSString stringWithFormat:@"%.02f MB", fileSize];
        self.sizeLab.text = fileSizeStr;
        [self.sizeLab sizeToFit];
    }
}

- (void)setFormat:(NTESVideoFormat)format
{
    switch (format)
    {
        case NTESVideoFormatSHDMP4:
        {
            self.formatLab.text = @"高清MP4";
            break;
        }
        case NTESVideoFormatHDFLV:
        {
            self.formatLab.text = @"标清FLV";
            break;
        }
        case NTESVideoFormatSDHLS:
        {
            self.formatLab.text = @"流畅HLS";
            break;
        }
        default:
            break;
    }
    
    [self.formatLab sizeToFit];
    _format = format;
}

- (void)setState:(NTESVideoItemState)state
{
    if (_state != state)
    {
        //更新状态
        switch (state) {
            case NTESVideoItemTransCoding:
            {
                self.urlLab.textColor = UIColorFromRGB(0x999999);
                self.urlLab.text = @"转码中...";
                self.playBtn.enabled = NO;
                self.shareBtn.enabled = NO;
                self.deleteBtn.enabled = NO;
                break;
            }
            case NTESVideoItemTransCodeFail:
            {
                self.urlLab.textColor = UIColorFromRGB(0xf05b60);
                self.urlLab.text = @"转码失败!请检查您上传的视频是否正确，或联系您的技术支持";
                self.playBtn.enabled = NO;
                self.shareBtn.enabled = NO;
                self.deleteBtn.enabled = NO;
                break;
            }
            case NTESVideoItemComplete:
            {
                self.urlLab.textColor = UIColorFromRGB(0x999999);
                self.urlLab.text = (_videoUrl ?: @"");
                self.playBtn.enabled = YES;
                self.shareBtn.enabled = YES;
                self.deleteBtn.enabled = YES;
                break;
            }
            default:
                break;
        }
        _state = state;
    }
}


#pragma mark - Getter
-(UIView *)line
{
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = UIColorFromRGB(0xc8c7cc);
    }
    return _line;
}

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

- (UIButton *)deleteBtn
{
    if (!_deleteBtn) {
        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
        [_deleteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"btn_normal_red"] forState:UIControlStateNormal];
        [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"btn_pressed_red"] forState:UIControlStateHighlighted];
        [_deleteBtn setBackgroundImage:[UIImage imageNamed:@"btn_disabled_red"] forState:UIControlStateDisabled];
        _deleteBtn.tag = 12;
        [_deleteBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}

@end
