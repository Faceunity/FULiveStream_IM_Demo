//
//  NTESFrameView.m
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/6/2.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESFrameView.h"
#import "NTESCoverView.h"

#define CoverWidth 158

#define thumbWidth 4

@interface NTESFrameView () <UIScrollViewDelegate>

@property(nonatomic, strong) NSURL *videoURL;

@property(nonatomic, strong) AVAsset *asset;

@property(nonatomic, strong) UIScrollView *scrollView;

//遮挡view
@property(nonatomic, strong) NTESCoverView *coverView;

@property(nonatomic, strong) UIView *frameView;

//显示起始时间
@property(nonatomic, strong) UILabel *startTimeLabel;

@property(nonatomic, assign) CGFloat startTime;

@property(nonatomic, strong) AVAssetImageGenerator *imageGenerator;

@property(nonatomic, assign) CGFloat thumWidth;

@property(nonatomic, assign) CGFloat widthPerSecond;

@end

@implementation NTESFrameView

- (instancetype)initWithFrame:(CGRect)frame videoURL:(NSURL *)videoURL trimDuration:(CGFloat)duration {
    if (self = [super initWithFrame:frame]) {
        self.trimDuration = duration;
        self.videoURL = videoURL;
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.45];
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.thumWidth = thumbWidth;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.alwaysBounceHorizontal = NO;
    [self addSubview:self.scrollView];
    
    self.frameView = [[UIView alloc] initWithFrame:CGRectMake(_coverView.origin.x, 0, self.scrollView.width, self.height)];
    [self.frameView.layer setMasksToBounds:YES];
    [self.scrollView addSubview:self.frameView];
    
    //trim video显示的片段
    self.coverView = ({
        NTESCoverView *coverView = [[NTESCoverView alloc] initWithFrame:CGRectMake(self.width/2 - CoverWidth/2, 0, CoverWidth, self.height) duration:self.trimDuration];
        coverView;
    });
    [self addSubview:self.coverView];
    
    self.startTimeLabel = ({
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.coverView.origin.x - 20, self.coverView.origin.y - 25, 40, 20)];
        label.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:12.f];
        label.hidden = YES;
        label;
    });
    [self addSubview:self.startTimeLabel];
    
    [self getVideoFrame];
}

#pragma mark - Video
- (void)getVideoFrame {
    self.asset = [[AVURLAsset alloc] initWithURL:self.videoURL options:nil];
    self.imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:self.asset];
    
    if ([self isRetina]) {
        self.imageGenerator.maximumSize = CGSizeMake(100 * 2, self.height * 2);
    } else {
        self.imageGenerator.maximumSize = CGSizeMake(100, self.height);
    }
    int picWidth = 0;

    //first frame
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef halfWayImage = [self.imageGenerator copyCGImageAtTime:kCMTimeZero actualTime:&actualTime error:&error];
    UIImage *videoScreen = nil;

    if (halfWayImage) {
        if ([self isRetina]) {
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
        }else {
            videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
        }
        UIImageView *tmpView = [[UIImageView alloc] initWithImage:videoScreen];
        picWidth = self.height * (tmpView.width / tmpView.height);
        CGRect rect = CGRectMake(0, 0, picWidth, self.height);
        tmpView.frame = rect;
        [self.frameView addSubview:tmpView];

        CGImageRelease(halfWayImage);
    }
    
    Float64 duration = CMTimeGetSeconds([self.asset duration]);
    //每秒的宽度在trimDuration CoverWidth一定的时候，是一定的
    self.widthPerSecond = CoverWidth / self.trimDuration;

    //所有帧总长度，add在scrollView contentView上
    CGFloat frameViewWidth = duration * self.widthPerSecond;
    
    self.scrollView.frame = CGRectMake(0, 0, self.width, self.height);
    [self.scrollView setContentSize:CGSizeMake(frameViewWidth * 2, self.height)];
    self.frameView.frame = CGRectMake(self.coverView.origin.x, 0, frameViewWidth, self.height);

    
    //遮蔽的位置的frame数量
    NSInteger coverFramesNeeded = (CoverWidth / picWidth) + 1;
    NSInteger actualFramesNeeded = ((duration / self.trimDuration) * coverFramesNeeded)+1;
    
    //每一帧间隔时长
    Float64 durationPerFrame = duration / (actualFramesNeeded * 1.0);
    
        @autoreleasepool {
            NSMutableArray *times = @[].mutableCopy;

            int preferredWith = 0;
            for (int i = 1; i < actualFramesNeeded; ++i) {
                CMTime time = CMTimeMakeWithSeconds(i * durationPerFrame, 600);
                [times addObject:[NSValue valueWithCMTime:time]];
        
                UIImageView *tmp = [[UIImageView alloc] initWithImage:videoScreen];
                tmp.tag = i;
                CGRect currentFrame = tmp.frame;
                currentFrame.origin.x = i * picWidth;
                currentFrame.size.width = picWidth;
                preferredWith += currentFrame.size.width;
        
                if (i == actualFramesNeeded - 1) {
                    currentFrame.size.width -= 6;
                }
                tmp.frame = currentFrame;
                WEAK_SELF(weakSelf);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.frameView addSubview:tmp];
                });
            }
            WEAK_SELF(weakSelf);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                for (int i = 1; i < [times count]; ++i) {
                    CMTime time = [((NSValue *)[times objectAtIndex:i-1]) CMTimeValue];
            
                    CGImageRef halfWayImage = [weakSelf.imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
            
                    UIImage *videoScreen;
                    if ([weakSelf isRetina]){
                        videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage scale:2.0 orientation:UIImageOrientationUp];
                    } else {
                        videoScreen = [[UIImage alloc] initWithCGImage:halfWayImage];
                    }
            
                    CGImageRelease(halfWayImage);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImageView *imageView = (UIImageView *)[weakSelf.frameView viewWithTag:i];
                        [imageView setImage:videoScreen];
                
                    });
                }
            });
    }
    
}

- (BOOL)isRetina{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0));
}

#pragma mark - ScrollView Gesture

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.startTimeLabel.hidden = NO;
    
    CGPoint offset = scrollView.contentOffset;

    CGFloat maximumOffset = self.frameView.width - CoverWidth;
//    NSLog(@"Offset:%lf, frameView width:%lf, maximumoffset:%lf",offset.x, self.frameView.width, maximumOffset);

    if (offset.x >= maximumOffset) {
        scrollView.contentOffset = CGPointMake(maximumOffset, 0);
    }
    if (offset.x <= 0) {
        scrollView.contentOffset = CGPointMake(0, 0);
    }
    
    self.startTime = fabs(offset.x / self.widthPerSecond);
    
    self.startTimeLabel.text = [NSString stringWithFormat:@"%.1f", self.startTime];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(trimmerView:didEndChangeStartTime:)]) {
        [self.delegate trimmerView:self didEndChangeStartTime:self.startTime];
    }
    self.startTimeLabel.hidden = YES;
}

@end
