//
//  NTESChatView.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/1/11.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESChatView.h"

@interface NTESChatView ()<NTESNormalMessageViewProtocol>

@property (nonatomic, strong) NTESNormalMessageView *normalMsgView;
@property (nonatomic, strong) NTESPresentMessageView *presentMsgView;

@end

@implementation NTESChatView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self customInit];
    }
    return self;
}

- (void)customInit
{
    [self addSubview:self.normalMsgView];
    [self addSubview:self.presentMsgView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.presentMsgView.frame = CGRectMake(0,
                                           0,
                                           200,
                                           96.0);
    self.normalMsgView.frame = CGRectMake(0,
                                          self.presentMsgView.bottom,
                                          self.width,
                                          self.height - self.presentMsgView.bottom);
}

- (void)addNormalMessages:(NSArray <NTESTextMessage *> *)normalMessages
{
    [self.normalMsgView addMessages:normalMessages];
}

- (void)addPresentMessage:(NTESPresentMessage *)presentMessage
{
    [self.presentMsgView addPresent:presentMessage];
}

#pragma mark - Getter/Setter
- (NTESNormalMessageView *)normalMsgView
{
    if (!_normalMsgView) {
        _normalMsgView = [[NTESNormalMessageView alloc] init];
        _normalMsgView.delegate = self;
    }
    return _normalMsgView;
}

- (NTESPresentMessageView *)presentMsgView
{
    if (!_presentMsgView) {
        _presentMsgView = [[NTESPresentMessageView alloc] init];
    }
    return _presentMsgView;
}

#pragma mark - <NTESNormalMessageViewProtocol>
- (void)normalMessageView:(NTESNormalMessageView *)chatView clickUserId:(NSString *)userId
{
    if (_delegate && [_delegate respondsToSelector:@selector(chatView:clickUserId:)])
    {
        [_delegate chatView:self clickUserId:userId];
    }
}

@end
