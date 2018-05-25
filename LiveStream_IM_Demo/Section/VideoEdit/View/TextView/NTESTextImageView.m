//
//  NTESTextImageView.m
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/9/12.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESTextImageView.h"

#define IMAGE_ICON_SIZE   20
#define MAX_FONT_SIZE     500

@interface NTESTextImageView () {
    CGPoint prevPoint;
    CGPoint touchLocation;
    
    CGPoint beginningPoint;
    CGPoint beginningCenter;
    
    CGRect beginBounds;
    
    CGRect initialBounds;
    CGFloat initialDistance;
    
    CGFloat deltaAngle;
    
}

//@property(nonatomic, strong) UIImageView *resizingControl; //旋转图片
@property(nonatomic, strong) UITextView *textView;
@property(nonatomic, strong) UILabel *placeHolder;

@property(nonatomic, assign) BOOL isDeleting;

@end

@implementation NTESTextImageView

- (instancetype)initWithFrame:(CGRect)frame andSize:(CGSize)superSize andText:(NSString *)text andColor:(UIColor *)color andBackImage:(UIImage *)TextImage {
    self = [super initWithFrame:frame];
    if (self) {
        //计算出所在的位置   0 左上 1 右上 2左下 3右下
        self.backImg = TextImage;
        self.userInteractionEnabled = YES;
        UIFont * font = [UIFont systemFontOfSize:14];
        self.curFont = font;
        self.minFontSize = font.pointSize;
        [self createTextViewWithFrame:CGRectZero text:nil font:nil];
        self.textColor = color;
        
        UIPanGestureRecognizer *moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveGestureAction:)];
        [self addGestureRecognizer:moveGesture];
        
        [self layoutSubViewWithFrame:frame];
        CGFloat cFont = 1;
        self.textView.text = text;
        self.miniSize = CGSizeMake(IMAGE_ICON_SIZE, IMAGE_ICON_SIZE);
        if (self.miniSize.height >  frame.size.height ||
            self.miniSize.width  >  frame.size.width  ||
            self.miniSize.height <= 0 || self.miniSize.width <= 0)
        {
            self.miniSize = CGSizeMake(frame.size.width/3.f, frame.size.height/3.f);
        }
        CGSize  tSize = [self textSizeWithFont:cFont text:text];
        do
        {
            tSize = [self textSizeWithFont:++cFont text:text];
        }
        while (![self isBeyondSize:tSize] && cFont < MAX_FONT_SIZE);
        if (cFont < /*self.minFontSize*/0) return nil;
        cFont = (cFont < MAX_FONT_SIZE) ? cFont : self.minFontSize;
        [self.textView setFont:[self.curFont fontWithSize:--cFont]];
        [self centerTextVertically];
    }
    return self;
}

- (NSString *)textString {
    return self.textView.text;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    UIImage * image = self.backImg;
    self.image = image;
}

- (void)createTextViewWithFrame:(CGRect)frame text:(NSString *)text font:(UIFont *)font {
    UITextView *textView = [[UITextView alloc] initWithFrame:frame];
    textView.backgroundColor = [UIColor clearColor];
    textView.scrollEnabled = NO;
    textView.delegate = self;
    [textView setTextColor:self.textColor];
    textView.keyboardType  = UIKeyboardTypeDefault;
    textView.returnKeyType = UIReturnKeyDone;
    textView.textAlignment = NSTextAlignmentCenter;
    [textView setText:text];
    [textView setFont:font];
    [textView setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self addSubview:textView];
    [self sendSubviewToBack:textView];
    textView.contentOffset = CGPointZero;
    [self setTextView:textView];
}

#pragma mark - 手势
- (void)moveGestureAction:(UIPanGestureRecognizer * )recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged || recognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint translation = [recognizer translationInView:self.superview];
        CGPoint newCenter = CGPointMake(self.center.x + translation.x, self.center.y + translation.y );
        CGFloat halfx = CGRectGetMinX(self.superview.bounds) + self.width/2;
        newCenter.x = MAX(halfx, newCenter.x);
        newCenter.x = MIN(self.superview.bounds.size.width - halfx, newCenter.x);
        
        CGFloat halfy = CGRectGetMinY(self.superview.bounds) + self.height/2;
        newCenter.y = MAX(halfy, newCenter.y);
        newCenter.y = MIN(self.superview.bounds.size.height - halfy, newCenter.y);
        
        [self setCenter:newCenter];
        
        [recognizer setTranslation:CGPointZero inView:self.superview];
        
    }
}

- (void)layoutSubViewWithFrame:(CGRect)frame
{
    CGRect tRect = frame;
    tRect.size.width = self.bounds.size.width * 0.9f;
    tRect.size.height = self.bounds.size.height * 0.9f;
    tRect.origin.x = (self.bounds.size.width - tRect.size.width) * 0.5;
    tRect.origin.y = (self.bounds.size.height - tRect.size.height) * 0.5;
    [self.textView setFrame:tRect];
}

- (void)changeTextColor:(UIColor *)colorType{
    self.textView.textColor = colorType;
    self.textColor = colorType;
}

#pragma mark - textViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [self endEditing:YES];
        return NO;
        
    }
    _isDeleting = (range.length >= 1 && text.length == 0);
    
    if (textView.font.pointSize <= self.minFontSize && !_isDeleting) return NO;

    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSString *calcStr = textView.text;
    NSLog(@"calcStr:%@", calcStr);
    
    CGFloat cFont = self.textView.font.pointSize;
    CGSize  tSize = [self textSizeWithFont:cFont text:nil];
    
    self.textView.textContainerInset = UIEdgeInsetsZero;
    
    if (textView.text.length < 1) {
        [self.textView setText:@"哈哈哈"];
        self.textView.textColor = self.textColor;
    }
    
    if (_isDeleting)
    {
        do
        {
            tSize = [self textSizeWithFont:++cFont text:nil];
        } while (![self isBeyondSize:tSize] && cFont < MAX_FONT_SIZE);
        
        cFont = (cFont < MAX_FONT_SIZE) ? cFont : self.minFontSize;
        [self.textView setFont:[self.curFont fontWithSize:--cFont]];
    }
    else
    {
        NSLog(@"---%d",[self isBeyondSize:tSize]);
        
        while ([self isBeyondSize:tSize] && cFont > 0)
        {
                tSize = [self textSizeWithFont:--cFont text:nil];
        }
        
        [self.textView setFont:[self.curFont fontWithSize:cFont]];
    }
    [self centerTextVertically];
    
    NSString *lang = [[textView textInputMode] primaryLanguage]; // 获取当前键盘输入模式
    //简体中文输入,第三方输入法所有模式下都会显示“zh-Hans”
    if([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [textView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        //没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if(!position) {
            textView.text = calcStr;
        }
    } else{
        textView.text = calcStr;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
}

#pragma mark - Private

- (CGSize)textSizeWithFont:(CGFloat)font text:(NSString *)string
{
    NSString *text = string ? string : self.textView.text;
    
    CGFloat pO = self.textView.textContainer.lineFragmentPadding * 2;
    CGFloat cW = self.textView.frame.size.width - pO;
    
//    CGSize  tH = [text sizeWithFont:[self.curFont fontWithSize:font]
//                  constrainedToSize:CGSizeMake(cW, MAXFLOAT)
//                      lineBreakMode:NSLineBreakByWordWrapping];
    CGSize tH = [text boundingRectWithSize:CGSizeMake(cW, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil].size;
    return  tH;
}

- (BOOL)isBeyondSize:(CGSize)size
{
    CGFloat ost = _textView.textContainerInset.top + _textView.textContainerInset.bottom;
    return size.height + ost > self.textView.frame.size.height;
}

- (void)centerTextVertically
{
    CGSize  tH     = [self textSizeWithFont:self.textView.font.pointSize text:nil];
    CGFloat offset = (self.textView.frame.size.height - tH.height)/2.f;
    
    self.textView.textContainerInset = UIEdgeInsetsMake(offset, 0, offset, 0);
    
#if TEST_CENTER_ALIGNMENT
    [self.indicatorView setFrame:CGRectMake(0, offset, self.frame.size.width, tH.height)];
#else
    // ...
#endif
}

- (UIImage *)imageWithText
{
    NSString *text = self.textView.text;
    NSMutableParagraphStyle* paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    NSDictionary*attribute = @{NSForegroundColorAttributeName:self.textColor,
                               NSFontAttributeName:self.curFont,
                               NSParagraphStyleAttributeName:paragraphStyle};
    CGSize size = [text boundingRectWithSize:CGSizeMake(self.textView.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    // optional: add a shadow, to avoid clipping the shadow you should make the context size bigger
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetShadowWithColor(ctx, CGSizeMake(1.0, 1.0), 5.0, [[UIColor grayColor] CGColor]);
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    [text drawInRect:CGRectMake(0, 0, self.textView.width, size.height) withAttributes:attribute];
    
    // transfer image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
