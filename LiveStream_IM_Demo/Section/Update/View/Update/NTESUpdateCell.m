//
//  NTESUpdateCell.m
//  NTESUpadateUI
//
//  Created by Netease on 17/2/24.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESUpdateCell.h"
#import "NTESTopAlignmentLabel.h"
#import "NTESUpdateProcessView.h"

@interface NTESUpdateCell ()
//UI
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) NTESTopAlignmentLabel *titleLab;
@property (nonatomic, strong) UILabel *resultLab;
@property (nonatomic, strong) UILabel *processLab;
@property (nonatomic, strong) UILabel *processValueLab;
@property (nonatomic, strong) NTESUpdateProcessView *processBar;
@property (nonatomic, strong) UIActivityIndicatorView *active;
@property (nonatomic, strong) UIButton *retryBtn;
//Model,通过KVO监测状态改变
@property(nonatomic, strong) NTESVideoEntity *item;

@end

@implementation NTESUpdateCell

- (void)dealloc
{
    [self.item removeObserver:self forKeyPath:@"state"];
    [self.item removeObserver:self forKeyPath:@"updateProcess"];
    Class cellClass = NSClassFromString(@"NTESUpdateCell");
    NSLog(@"[%@] 释放了", cellClass);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.line];
        [self addSubview:self.imgView];
        [self addSubview:self.titleLab];
        [self addSubview:self.processBar];
        [self addSubview:self.processLab];
        [self addSubview:self.processValueLab];
        [self addSubview:self.resultLab];
        [self addSubview:self.active];
        [self addSubview:self.retryBtn];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_line.width != self.width)
    {
        _line.frame = CGRectMake(0, self.height - 1.0, self.width, 1.0);
        _imgView.frame = CGRectMake(15, 15, 80, 60);
        _retryBtn.frame = CGRectMake(self.width - 15 - 50, _imgView.bottom - 25, 50, 25);
    }
    
    _titleLab.frame = CGRectMake(_imgView.right + 16,
                                 _imgView.top - 2,
                                 self.contentView.width - _imgView.right - 16*2,
                                 36);
    _processBar.frame = CGRectMake(_titleLab.left,
                                   _imgView.bottom - 4.0,
                                   self.width - _titleLab.left - 16.0,
                                   4.0);
    _processLab.frame = CGRectMake(_titleLab.left,
                                   _processBar.top - 6 - _processLab.height,
                                   _processLab.width,
                                   _processLab.height);
    _processValueLab.frame = CGRectMake(_processLab.right + 4,
                                        _processLab.top,
                                        40,
                                        _processValueLab.height);
        
    _resultLab.frame = CGRectMake(_imgView.right + 15,
                                  _imgView.bottom - 4.0 - _resultLab.height,
                                  _resultLab.width,
                                  _resultLab.height);
        
    _active.left = _resultLab.right + 12.0;
    _active.centerY = _resultLab.centerY;
}


- (void)configCellWithItem:(NTESVideoEntity *)item
{
    if (self.item) {
        [self.item removeObserver:self forKeyPath:@"state"];
        [self.item removeObserver:self forKeyPath:@"updateProcess"];
    }
    self.item = item;
    [self.item addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    [self.item addObserver:self forKeyPath:@"updateProcess" options:NSKeyValueObservingOptionNew context:nil];
    
    if (item)
    {
        if (item.title && ![item.title isEqualToString:_titleLab.text])
        {
            _titleLab.text = [item.title stringByDeletingPathExtension];
        }
        
        if (item.thumbImg)
        {
            if (item.thumbImg != _imgView.image)
            {
                _imgView.image = item.thumbImg;
            }
        }
        else if (item.thumbImgUrl)
        {
            [_imgView yy_setImageWithURL:[NSURL URLWithString:item.thumbImgUrl]
                             placeholder:[UIImage imageNamed:@"thumb_defuault"]
                                 options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
        }
        else
        {
            _imgView.image = [UIImage imageNamed:@"thumb_defuault"];
        }
        
        if (item.updateProcess != _progress)
        {
            self.progress = item.updateProcess;
        }
        
        if (self.state != item.state)
        {
            self.state = item.state;
        }
        
        //因为reload之后active会停止 所以这里重新配置一下
//        if (self.state == NTESVideoItemTransCoding || self.state == NTESVideoItemCaching)
//        {
//            [self.active startAnimating];
//        }
//        else
//        {
//            [self.active stopAnimating];
//        }
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    NTESVideoEntity *item = object;
    if ([keyPath isEqualToString:@"state"]) {
        self.state = item.state;
        switch (item.state) {
            case NTESVideoItemUpdating:
            {
                [self.active stopAnimating];
//                self.state = item.state;
            }
                break;
            case NTESVideoItemTransCoding:
            case NTESVideoItemCaching:
            {
                [self.active startAnimating];
            }
                break;
            default:
            {
                [self.active stopAnimating];
            }
                break;
        }
    }
    if ([keyPath isEqualToString:@"updateProcess"]) {
        self.progress = item.updateProcess;
    }
}

#pragma mark - Action
- (void)btnAction:(UIButton *)btn
{
    if (_delegate && [_delegate respondsToSelector:@selector(updateCellRetryAction:)]) {
        [_delegate updateCellRetryAction:self];
    }
}

#pragma mark - Setter
- (void)setProgress:(CGFloat)progress
{
    if (_progress == progress) {
        return;
    }
    
    if (progress >= 0 && progress <= 1)
    {
        _progress = progress;
        
        _processValueLab.text = [NSString stringWithFormat:@"(%zi%%)", (NSInteger)(_progress*100)];
        _processBar.progress = progress;
    }
}

- (void)setState:(NTESVideoItemState)state
{
    if (_state == state) {
        return;
    }

    _state = state;
    
    switch (state)
    {
        case NTESVideoItemNormal: //正常
        {
            self.processLab.hidden = YES;
            self.processBar.hidden = YES;
            self.processValueLab.hidden = YES;
            [self.active stopAnimating];
            self.resultLab.textColor = UIColorFromRGB(0x999999);
            self.resultLab.text = @"正常";
            [self.resultLab sizeToFit];
            self.resultLab.hidden = NO;
            self.retryBtn.hidden = YES;
            self.titleLab.textColor = [UIColor blackColor];
            self.titleLab.numberOfLines = 2;
            self.accessoryType = UITableViewCellAccessoryNone;
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
        case NTESVideoItemUnexist: //不存在
        {
            self.processLab.hidden = YES;
            self.processBar.hidden = YES;
            self.processValueLab.hidden = YES;
            [self.active stopAnimating];
            self.resultLab.textColor = UIColorFromRGB(0x999999);
            self.resultLab.text = @"不存在";
            [self.resultLab sizeToFit];
            self.resultLab.hidden = NO;
            self.retryBtn.hidden = YES;
            self.titleLab.numberOfLines = 2;
            self.titleLab.textColor = [UIColor blackColor];
            self.accessoryType = UITableViewCellAccessoryNone;
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
        case NTESVideoItemWaiting: //等待中
        {
            self.processLab.text = @"等待中";
            [self.processLab sizeToFit];
            self.processLab.hidden = NO;
            self.processBar.hidden = NO;
            self.processValueLab.hidden = NO;
            self.resultLab.hidden = YES;
            [self.active stopAnimating];
            self.retryBtn.hidden = YES;
            self.titleLab.numberOfLines = 1;
            self.titleLab.textColor = UIColorFromRGB(0x999999);
            self.accessoryType = UITableViewCellAccessoryNone;
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
        case NTESVideoItemCaching:
        {
            self.processLab.hidden = YES;
            self.processBar.hidden = YES;
            self.processValueLab.hidden = YES;
            [self.active startAnimating];
            self.resultLab.textColor = UIColorFromRGB(0x999999);
            self.resultLab.text = @"缓存中";
            [self.resultLab sizeToFit];
            self.resultLab.hidden = NO;
            self.retryBtn.hidden = YES;
            self.titleLab.numberOfLines = 2;
            self.titleLab.textColor = [UIColor blackColor];
            self.accessoryType = UITableViewCellAccessoryNone;
            self.selectionStyle = UITableViewCellSelectionStyleGray;
            break;
        }
        case NTESVideoItemUpdating: //上传中
        {
            self.processLab.text = @"上传中";
            [self.processLab sizeToFit];
            self.processLab.hidden = NO;
            self.processBar.hidden = NO;
            self.processValueLab.hidden = NO;
            [self.active stopAnimating];
            self.resultLab.hidden = YES;
            self.retryBtn.hidden = YES;
            self.titleLab.numberOfLines = 1;
            self.titleLab.textColor = UIColorFromRGB(0x999999);
            self.accessoryType = UITableViewCellAccessoryNone;
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
        case NTESVideoItemUpdateFail: //上传失败
        {
            self.processLab.hidden = YES;
            self.processBar.hidden = YES;
            self.processValueLab.hidden = YES;
            [self.active stopAnimating];
            self.resultLab.textColor = UIColorFromRGB(0xf05b60);
            self.resultLab.text = @"上传失败";
            [self.resultLab sizeToFit];
            self.resultLab.hidden = NO;
            self.retryBtn.hidden = NO;
            self.titleLab.numberOfLines = 1;
            self.titleLab.textColor = [UIColor blackColor];
            self.accessoryType = UITableViewCellAccessoryNone;
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
        case NTESVideoItemTransCoding: //转码中
        {
            self.processLab.hidden = YES;
            self.processBar.hidden = YES;
            self.processValueLab.hidden = YES;
            [self.active startAnimating];
            self.resultLab.textColor = UIColorFromRGB(0x999999);
            self.resultLab.text = @"转码中";
            [self.resultLab sizeToFit];
            self.resultLab.hidden = NO;
            self.retryBtn.hidden = YES;
            self.titleLab.numberOfLines = 2;
            self.titleLab.textColor = [UIColor blackColor];
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            self.selectionStyle = UITableViewCellSelectionStyleGray;
            break;
        }
        case NTESVideoItemTransCodeFail: //转码失败
        {
            self.processLab.hidden = YES;
            self.processBar.hidden = YES;
            self.processValueLab.hidden = YES;
            [self.active stopAnimating];
            self.resultLab.textColor = UIColorFromRGB(0xf05b60);
            self.resultLab.text = @"转码失败";
            [self.resultLab sizeToFit];
            self.resultLab.hidden = NO;
            self.retryBtn.hidden = YES;
            self.titleLab.numberOfLines = 2;
            self.titleLab.textColor = [UIColor blackColor];
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            self.selectionStyle = UITableViewCellSelectionStyleGray;
            break;
        }
        case NTESVideoItemComplete:
        {
            self.processLab.hidden = YES;
            self.processBar.hidden = YES;
            self.processValueLab.hidden = YES;
            [self.active stopAnimating];
            self.resultLab.textColor = UIColorFromRGB(0x999999);
            self.resultLab.text = @"完成";
            [self.resultLab sizeToFit];
            self.resultLab.hidden = NO;
            self.retryBtn.hidden = YES;
            self.titleLab.numberOfLines = 2;
            self.titleLab.textColor = [UIColor blackColor];
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            self.selectionStyle = UITableViewCellSelectionStyleGray;
            break;
        }
        default:
            break;
    }
}


#pragma mark - Getter
- (UIView *)line
{
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = UIColorFromRGB(0xc8c7cc);
    }
    return _line;
}

- (UIImageView *)imgView
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
    }
    return _imgView;
}

- (NTESTopAlignmentLabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[NTESTopAlignmentLabel alloc] init];
        _titleLab.font = [UIFont systemFontOfSize:15.0];
        _titleLab.textColor = UIColorFromRGB(0x333333);
        _titleLab.numberOfLines = 2;
        _titleLab.text = @"这是测试这是测试";
        _titleLab.contentMode = UIViewContentModeTop;
    }
    return _titleLab;
}

- (UILabel *)resultLab
{
    if (!_resultLab) {
        _resultLab = [[UILabel alloc] init];
        _resultLab.font = [UIFont systemFontOfSize:12.0];
        _resultLab.textColor = UIColorFromRGB(0x999999);
        _resultLab.text = @"转码中";
        [_resultLab sizeToFit];
    }
    return _resultLab;
}

- (UILabel *)processLab
{
    if (!_processLab) {
        _processLab = [UILabel new];
        _processLab.font = [UIFont systemFontOfSize:12.0];
        _processLab.textColor = UIColorFromRGB(0x999999);
        _processLab.text = @"上传中";
        [_processLab sizeToFit];
    }
    return _processLab;
}

- (UILabel *)processValueLab
{
    if (!_processValueLab) {
        _processValueLab = [UILabel new];
        _processValueLab.font = [UIFont systemFontOfSize:12.0];
        _processValueLab.textColor = UIColorFromRGB(0x999999);
        _processValueLab.text = [NSString stringWithFormat:@"(%zi%%)", (NSInteger)(_progress*100)];
        [_processValueLab sizeToFit];
    }
    return _processValueLab;
}

- (NTESUpdateProcessView *)processBar
{
    if (!_processBar) {
        _processBar = [NTESUpdateProcessView new];
        _processBar.progress = 0.0;
    }
    return _processBar;
}

- (UIActivityIndicatorView *)active
{
    if (!_active) {
        _active = [[UIActivityIndicatorView alloc] init];
        _active.transform = CGAffineTransformMakeScale(0.7, 0.7);
        _active.hidesWhenStopped = YES;
        _active.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
    return _active;
}

- (UIButton *)retryBtn
{
    if (!_retryBtn) {
        _retryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_retryBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_retryBtn setTitle:@"重试" forState:UIControlStateNormal];
        _retryBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_retryBtn setBackgroundImage:[UIImage imageNamed:@"btn_normal_blue"] forState:UIControlStateNormal];
        [_retryBtn setBackgroundImage:[UIImage imageNamed:@"btn_pressed_blue"] forState:UIControlStateHighlighted];
        [_retryBtn setBackgroundImage:[UIImage imageNamed:@"btn_disabled_blue"] forState:UIControlStateDisabled];
        [_retryBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _retryBtn;
}

@end
