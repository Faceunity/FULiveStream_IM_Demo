//
//  NTESTextMessage.m
//  NEUIDemo
//
//  Created by Netease on 17/1/3.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESTextMessage.h"

#define DefaultFromColor UIColorFromRGB(0xc2ff9a)
#define DefaultMessageColor UIColorFromRGB(0xffffff)
#define DefaultNoticationColor [UIColor lightGrayColor]

@interface NTESTextMessage ()

@property (nonatomic, copy) NSString *showMessage;
@property (nonatomic, assign) NSRange fromRange;
@property (nonatomic, assign) NSRange messageRange;
@property (nonatomic, assign) NSRange noticationRange;
@property (nonatomic, assign) NSRange hightlightRange;

@end

@implementation NTESTextMessage

+ (NTESTextMessage *)systemMessage:(NSString *)message from:(NSString *)from
{
    NTESTextMessage *systemMessage = [[NTESTextMessage alloc] init];
    systemMessage.type = NTESMessageTypeNotification;
    systemMessage.showName = from;
    systemMessage.message = message;
    
    
    return systemMessage;
}

+ (NTESTextMessage *)textMessage:(NSString *)message sender:(NTESMember *)member
{
    NTESTextMessage *msg = [[NTESTextMessage alloc] init];
    msg.type = NTESMessageTypeChat;
    msg.showName = member.showName;
    msg.userId = member.userId;
    msg.message = message;
    return msg;
}


- (void)caculate:(CGFloat)width
{
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(width, MAXFLOAT)];
    YYTextLayout *textLayout = [YYTextLayout layoutWithContainer:container text:self.formatString];
    self.height = (textLayout.textBoundingSize.height + ChatCellDefaultChatInterval);
}

- (NSMutableAttributedString *)formatString
{
    NSMutableAttributedString *formatString = [[NSMutableAttributedString alloc] initWithString:self.showMessage];

    switch (_type)
    {
        case NTESMessageTypeChat:
        {
            [formatString yy_setColor:self.fromColor range:self.fromRange];
            [formatString yy_setColor:self.messageColor range:self.messageRange];
            [formatString yy_setFont:[UIFont systemFontOfSize:14.0] range:NSMakeRange(0, self.showMessage.length)];
            
            __weak typeof(self) weakSelf = self;
            [formatString yy_setTextHighlightRange:self.hightlightRange
                                             color:nil
                                   backgroundColor:nil
                                         tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                                             if (weakSelf.messageClickBlock) {
                                                 weakSelf.messageClickBlock(weakSelf.userId);
                                             }
                                         }];
            break;
        }
        default:
        {
            [formatString yy_setColor:self.noticationColor range:self.noticationRange];
            [formatString yy_setFont:[UIFont systemFontOfSize:14.0] range:NSMakeRange(0, self.showMessage.length)];
            break;
        }
    }

    return formatString;
}


- (NSString *)showMessage
{
    _showMessage = [NSString stringWithFormat:@"%@  %@",_showName, _message];
    
    return _showMessage;
}

- (NSRange)fromRange
{
    NSRange range = NSMakeRange(0, 0);
    
    if (_type == NTESMessageTypeChat)
    {
        range = NSMakeRange(0, self.showName.length);
    }
    
    return range;
}

- (NSRange)messageRange
{
    NSRange range = NSMakeRange(self.showMessage.length - _message.length, _message.length);
    return range;
}

- (NSRange)noticationRange
{
    NSRange range = NSMakeRange(0, self.showMessage.length);
    return range;
}

- (NSRange)hightlightRange
{
    NSRange range = NSMakeRange(0, 0);
    
    if (_type == NTESMessageTypeChat)
    {
        range = NSMakeRange(0, self.showMessage.length);
    }
    return range;
}

- (UIColor *)fromColor
{
    return (_fromColor ?: DefaultFromColor);
}

-(UIColor *)messageColor
{
    return (_messageColor ?: DefaultMessageColor);
}

- (UIColor *)noticationColor
{
    return (_noticationColor ?: DefaultNoticationColor);
}

@end
