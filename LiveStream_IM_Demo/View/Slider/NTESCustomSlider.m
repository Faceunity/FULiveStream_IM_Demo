//
//  NTESCustomSlider.m
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/6/23.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESCustomSlider.h"

@interface NTESCustomSlider ()

@property(nonatomic, assign) CGFloat lowerTouchOffset;
@property(nonatomic, assign) CGFloat upperTouchOffset;
@property(nonatomic, assign) CGFloat stepValueInternal;

@property(nonatomic, strong) UIImageView *track;
@property(nonatomic, strong) UIImageView *trackBackground;
@property(nonatomic, assign) CGPoint lowerCenter;
@property(nonatomic, assign) CGPoint upperCenter;

@end

@implementation NTESCustomSlider

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    _minimumValue = 0.;
    _maximumValue = 1.;
    _minimumRange = 0.;
    _stepValue = 0.;
    _stepValueInternal = 0.;
    
    _continuous = YES;
    
    _lowerValue = _minimumValue;
    _upperValue = _maximumValue;
    
    _lowerMaximumValue = NAN;
    _upperMinimumValue = NAN;
    _upperHandleHidden = NO;
    _lowerHandleHidden = NO;
    
    _lowerHandleHiddenWidth = 2.f;
    _upperHandleHiddenWidth = 2.f;
    
    _lowerTouchEdgeInsets = UIEdgeInsetsMake(-5, -5, -5, -5);
    _upperTouchEdgeInsets = UIEdgeInsetsMake(-5, -5, -5, -5);
    
    [self addSubViews];
    
    [self.lowerHandle addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    [self.upperHandle addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    
}

- (void)dealloc {
    [self.lowerHandle removeObserver:self forKeyPath:@"frame"];
    [self.upperHandle removeObserver:self forKeyPath:@"frame"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"frame"]) {
        if (object == self.lowerHandle) {
            self.lowerCenter = self.lowerHandle.center;
        }else if (object == self.upperHandle) {
            self.upperCenter = self.upperHandle.center;
        }
    }
}

#pragma mark - properties

- (void)setLowerValue:(CGFloat)lowerValue {
    CGFloat value = lowerValue;
    
    if (_stepValueInternal > 0) {
        value = roundf(value / _stepValueInternal)*self.stepValueInternal;
    }
    
    value = MIN(value, _maximumValue);
    value = MAX(value, _minimumValue);
    
    if (!isnan(_lowerMaximumValue)) {
        value = MIN(value, _lowerMaximumValue);
    }
    
    value = MIN(value, _upperValue - _minimumRange);
    _lowerValue = value;
    
    [self setNeedsLayout];
}

- (void)setUpperValue:(CGFloat)upperValue {
    CGFloat value = upperValue;
    
    if (_stepValueInternal > 0) {
        value = roundf(value/_stepValueInternal) * _stepValueInternal;
    }
    
    value = MAX(value, _minimumValue);
    value = MIN(value, _maximumValue);
    
    if (!isnan(_upperMinimumValue)) {
        value = MAX(value, _upperMinimumValue);
    }
    
    value = MAX(value, _lowerValue + _minimumRange);
    
    _upperValue = value;
    
    [self setNeedsLayout];
}

- (void)setLowerValue:(CGFloat)lowerValue upperValue:(CGFloat)upperValue animated:(BOOL)animated {
    if((!animated) && (isnan(lowerValue) || lowerValue==_lowerValue) && (isnan(upperValue) || upperValue==_upperValue))
    {
        //nothing to set
        return;
    }
    
    __block void (^setValuesBlock)(void) = ^ {
        
        if(!isnan(lowerValue))
        {
            [self setLowerValue:lowerValue];
        }
        if(!isnan(upperValue))
        {
            [self setUpperValue:upperValue];
        }
        
    };
    
    if(animated)
    {
        [UIView animateWithDuration:0.25  delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             
                             setValuesBlock();
                             [self layoutSubviews];
                             
                         } completion:^(BOOL finished) {
                             
                         }];
        
    }
    else
    {
        setValuesBlock();
    }
}

- (void)setLowerValue:(CGFloat)lowerValue animated:(BOOL) animated
{
    [self setLowerValue:lowerValue upperValue:NAN animated:animated];
}

- (void)setUpperValue:(CGFloat)upperValue animated:(BOOL) animated
{
    [self setLowerValue:NAN upperValue:upperValue animated:animated];
}

- (void) setLowerHandleHidden:(BOOL)lowerHandleHidden
{
    _lowerHandleHidden = lowerHandleHidden;
    [self setNeedsLayout];
}

- (void) setUpperHandleHidden:(BOOL)upperHandleHidden
{
    _upperHandleHidden = upperHandleHidden;
    [self setNeedsLayout];
}

- (UIImage *)trackBackgroundImage {
    if (!_trackBackgroundImage) {
        UIImage *img = [UIImage imageNamed:@"slider-trackBackground"];
        img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0., 2., 0., 2.)];
        _trackBackgroundImage = img;
    }
    return _trackBackgroundImage;
}

- (UIImage *)trackImage {
    if (!_trackImage) {
        UIImage *img = [UIImage imageNamed:@"slider-default7-track"];
        img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0., 2., 0., 2.)];
        _trackImage = img;
    }
    return _trackImage;
}

- (UIImage *)trackCrossedOverImage {
    if (!_trackCrossedOverImage) {
        UIImage *img = [UIImage imageNamed:@"slider-trackCrossedOver"];
        img = [img resizableImageWithCapInsets:UIEdgeInsetsMake(0., 2., 0., 2.)];
        _trackCrossedOverImage = img;
    }
    return _trackCrossedOverImage;
}

- (UIImage *)lowerHandleImageNormal {
    if (!_lowerHandleImageNormal) {
        UIImage *img = [UIImage imageNamed:@"白点"];
        _lowerHandleImageNormal = [img imageWithAlignmentRectInsets:UIEdgeInsetsMake(-1, 8, 1, 8)];
    }
    return _lowerHandleImageNormal;
}

- (UIImage *)lowerHandleImageHighlighted {
    if (!_lowerHandleImageHighlighted) {
        UIImage *img = [UIImage imageNamed:@"Oval"];
        _lowerHandleImageHighlighted = [img imageWithAlignmentRectInsets:UIEdgeInsetsMake(-1, 8, 1, 8)];
    }
    return _lowerHandleImageHighlighted;
}

- (UIImage *)upperHandleImageNormal {
    if (!_upperHandleImageNormal) {
        UIImage *img = [UIImage imageNamed:@"白点"];
        _upperHandleImageNormal = [img imageWithAlignmentRectInsets:UIEdgeInsetsMake(-1, 8, 1, 8)];
    }
    return _upperHandleImageNormal;
}

- (UIImage *)upperHandleImageHighlighted {
    if (!_upperHandleImageHighlighted) {
        UIImage *img = [UIImage imageNamed:@"Oval"];
        _upperHandleImageHighlighted = [img imageWithAlignmentRectInsets:UIEdgeInsetsMake(-1, 8, 1, 8)];
    }
    return _upperHandleImageHighlighted;
}

-(float)lowerValueForCenterX:(float)x
{
    float _padding = _lowerHandle.frame.size.width/2.0f;
    float value = _minimumValue + (x-_padding) / (self.frame.size.width-(_padding*2)) * (_maximumValue - _minimumValue);
    
    value = MAX(value, _minimumValue);
    value = MIN(value, _upperValue - _minimumRange);
    
    return value;
}

-(float)upperValueForCenterX:(float)x
{
    float _padding = _upperHandle.frame.size.width/2.0;
    
    float value = _minimumValue + (x-_padding) / (self.frame.size.width-(_padding*2)) * (_maximumValue - _minimumValue);
    
    value = MIN(value, _maximumValue);
    value = MAX(value, _lowerValue+_minimumRange);
    
    return value;
}

- (UIEdgeInsets)trackAlignmentInsets
{
    UIEdgeInsets lowerAlignmentInsets = self.lowerHandleImageNormal.alignmentRectInsets;
    UIEdgeInsets upperAlignmentInsets = self.upperHandleImageNormal.alignmentRectInsets;
    
    CGFloat lowerOffset = MAX(lowerAlignmentInsets.right, upperAlignmentInsets.left);
    CGFloat upperOffset = MAX(upperAlignmentInsets.right, lowerAlignmentInsets.left);
    
    CGFloat leftOffset = MAX(lowerOffset, upperOffset);
    CGFloat rightOffset = leftOffset;
    CGFloat topOffset = lowerAlignmentInsets.top;
    CGFloat bottomOffset = lowerAlignmentInsets.bottom;
    
    return UIEdgeInsetsMake(topOffset, leftOffset, bottomOffset, rightOffset);
}


- (CGRect)trackRect
{
    CGRect retValue;
    
    UIImage* currentTrackImage = self.trackCrossedOverImage;
    
    retValue.size = CGSizeMake(currentTrackImage.size.width, currentTrackImage.size.height);
    
    if(currentTrackImage.capInsets.top || currentTrackImage.capInsets.bottom)
    {
        retValue.size.height=self.bounds.size.height;
    }
    
    float lowerHandleWidth = _lowerHandleHidden ? _lowerHandleHiddenWidth : _lowerHandle.frame.size.width;
    float upperHandleWidth = _upperHandleHidden ? _upperHandleHiddenWidth : _upperHandle.frame.size.width;
    
    float xLowerValue = ((self.bounds.size.width - lowerHandleWidth) * (_lowerValue - _minimumValue) / (_maximumValue - _minimumValue))+(lowerHandleWidth/2.0f);
    float xUpperValue = ((self.bounds.size.width - upperHandleWidth) * (_upperValue - _minimumValue) / (_maximumValue - _minimumValue))+(upperHandleWidth/2.0f);
    
    retValue.origin = CGPointMake(xLowerValue, (self.bounds.size.height/2.0f) - (retValue.size.height/2.0f));
    retValue.size.width = xUpperValue-xLowerValue;
    
    UIEdgeInsets alignmentInsets = [self trackAlignmentInsets];
    retValue = UIEdgeInsetsInsetRect(retValue,alignmentInsets);
    
    return retValue;
}

-(CGRect) trackBackgroundRect
{
    CGRect trackBackgroundRect;
    
    trackBackgroundRect.size = CGSizeMake(_trackBackgroundImage.size.width, _trackBackgroundImage.size.height);
    
    if(_trackBackgroundImage.capInsets.top || _trackBackgroundImage.capInsets.bottom)
    {
        trackBackgroundRect.size.height=self.bounds.size.height;
    }
    
    if(_trackBackgroundImage.capInsets.left || _trackBackgroundImage.capInsets.right)
    {
        trackBackgroundRect.size.width=self.bounds.size.width;
    }
    
    trackBackgroundRect.origin = CGPointMake(0, (self.bounds.size.height/2.0f) - (trackBackgroundRect.size.height/2.0f));
    
    // Adjust the track rect based on the image alignment rects
    
    UIEdgeInsets alignmentInsets = [self trackAlignmentInsets];
    trackBackgroundRect = UIEdgeInsetsInsetRect(trackBackgroundRect,alignmentInsets);
    
    return trackBackgroundRect;
}

//returms the rect of the tumb image for a given track rect and value
- (CGRect)thumbRectForValue:(float)value image:(UIImage*) thumbImage
{
    CGRect thumbRect;
    UIEdgeInsets insets = thumbImage.capInsets;
    
    thumbRect.size = CGSizeMake(thumbImage.size.width, thumbImage.size.height);
    
    if(insets.top || insets.bottom)
    {
        thumbRect.size.height=self.bounds.size.height;
    }
    
    float xValue = ((self.bounds.size.width-thumbRect.size.width)*((value - _minimumValue) / (_maximumValue - _minimumValue)));
    thumbRect.origin = CGPointMake(xValue, (self.bounds.size.height/2.0f) - (thumbRect.size.height/2.0f));
    
    return CGRectIntegral(thumbRect);
    
}

#pragma mark - layout

- (void)addSubViews {
    self.track = [[UIImageView alloc] initWithImage:self.trackImage];
    self.track.frame = [self trackRect];
    
    //lower Handle
    self.lowerHandle = [[UIImageView alloc] initWithImage:self.lowerHandleImageNormal highlightedImage:self.lowerHandleImageHighlighted];
    self.lowerHandle.frame = [self thumbRectForValue:_lowerValue image:self.lowerHandleImageNormal];
    
    //upper handle
    self.upperHandle = [[UIImageView alloc] initWithImage:self.upperHandleImageNormal highlightedImage:self.upperHandleImageHighlighted];
    self.upperHandle.frame = [self thumbRectForValue:_upperValue image:self.upperHandleImageNormal];
    
    //track background
    self.trackBackground = [[UIImageView alloc] initWithImage:self.trackBackgroundImage];
    self.trackBackground.frame = [self trackBackgroundRect];
    
    [@[self.trackBackground,
       self.track,
       self.lowerHandle,
       self.upperHandle] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
           [self addSubview:view];
       }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    //单个slider处理
    if (_lowerHandleHidden) {
        _lowerValue = _minimumValue;
    }
    
    if (_upperHandleHidden) {
        _upperValue = _maximumValue;
    }
    self.trackBackground.frame = [self trackBackgroundRect];
    self.track.frame = [self trackRect];
    self.track.image = self.trackCrossedOverImage;
    
    // Layout the lower handle
    self.lowerHandle.frame = [self thumbRectForValue:_lowerValue image:self.lowerHandleImageNormal];
    self.lowerHandle.image = self.lowerHandleImageNormal;
    self.lowerHandle.highlightedImage = self.lowerHandleImageHighlighted;
    self.lowerHandle.hidden = self.lowerHandleHidden;
    
    // Layoput the upper handle
    self.upperHandle.frame = [self thumbRectForValue:_upperValue image:self.upperHandleImageNormal];
    self.upperHandle.image = self.upperHandleImageNormal;
    self.upperHandle.highlightedImage = self.upperHandleImageHighlighted;
    self.upperHandle.hidden= self.upperHandleHidden;
    
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, MAX(self.lowerHandleImageNormal.size.height, self.upperHandleImageNormal.size.height));
}

#pragma mark - Touch handling

-(BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint = [touch locationInView:self];
    
    
    //Check both buttons upper and lower thumb handles because
    //they could be on top of each other.
    
    if(CGRectContainsPoint(UIEdgeInsetsInsetRect(_lowerHandle.frame, self.lowerTouchEdgeInsets), touchPoint))
    {
        _lowerHandle.highlighted = YES;
        _lowerTouchOffset = touchPoint.x - _lowerHandle.center.x;
    }
    
    if(CGRectContainsPoint(UIEdgeInsetsInsetRect(_upperHandle.frame, self.upperTouchEdgeInsets), touchPoint))
    {
        _upperHandle.highlighted = YES;
        _upperTouchOffset = touchPoint.x - _upperHandle.center.x;
    }
    
    _stepValueInternal= _stepValueContinuously ? _stepValue : 0.0f;
    
    return YES;
}


-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(!_lowerHandle.highlighted && !_upperHandle.highlighted ){
        return YES;
    }
    
    CGPoint touchPoint = [touch locationInView:self];
    
    if(_lowerHandle.highlighted)
    {
        //get new lower value based on the touch location.
        //This is automatically contained within a valid range.
        float newValue = [self lowerValueForCenterX:(touchPoint.x - _lowerTouchOffset)];
        
        //if both upper and lower is selected, then the new value must be LOWER
        //otherwise the touch event is ignored.
        if(!_upperHandle.highlighted || newValue<_lowerValue)
        {
            _upperHandle.highlighted=NO;
            [self bringSubviewToFront:_lowerHandle];
            
            [self setLowerValue:newValue animated:_stepValueContinuously ? YES : NO];
        }
        else
        {
            _lowerHandle.highlighted=NO;
        }
    }
    
    if(_upperHandle.highlighted )
    {
        float newValue = [self upperValueForCenterX:(touchPoint.x - _upperTouchOffset)];
        
        //if both upper and lower is selected, then the new value must be HIGHER
        //otherwise the touch event is ignored.
        if(!_lowerHandle.highlighted || newValue>_upperValue)
        {
            _lowerHandle.highlighted=NO;
            [self bringSubviewToFront:_upperHandle];
            [self setUpperValue:newValue animated:_stepValueContinuously ? YES : NO];
        }
        else
        {
            _upperHandle.highlighted=NO;
        }
    }
    
    
    //send the control event
    if(_continuous)
    {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
    
    //redraw
    [self setNeedsLayout];
    
    return YES;
}



-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _lowerHandle.highlighted = NO;
    _upperHandle.highlighted = NO;
    
    if(_stepValue>0)
    {
        _stepValueInternal=_stepValue;
        
        [self setLowerValue:_lowerValue animated:YES];
        [self setUpperValue:_upperValue animated:YES];
    }
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
