//
//  ARDstatsView.m
//  LSMediaCaptureDemo
//
//  Created by NetEase on 16/8/9.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "NEStatsView.h"


@implementation NEStatsView {
    UILabel *_statsLabel;
   
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _statsLabel = [[UILabel alloc] initWithFrame:frame];
        _statsLabel.numberOfLines = 0;
        _statsLabel.font = [UIFont fontWithName:@"Roboto" size:12];
        _statsLabel.adjustsFontSizeToFitWidth = YES;
        _statsLabel.minimumScaleFactor = 0.6;
        _statsLabel.textColor = [UIColor greenColor];
        [self addSubview:_statsLabel];
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.6];
      
    }
    return self;
}

- (void)setStats:(NSString *)stats {
    
    _statsLabel.text = stats;
}

- (void)layoutSubviews {
    _statsLabel.frame = self.bounds;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [_statsLabel sizeThatFits:size];
}

@end
