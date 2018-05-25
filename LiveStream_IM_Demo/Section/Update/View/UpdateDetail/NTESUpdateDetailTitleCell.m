//
//  NTESUpdateDetailTitleCell.m
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/3/13.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESUpdateDetailTitleCell.h"

@implementation NTESUpdateDetailTitleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.textLabel.frame = CGRectMake(16.0, 0, self.width, self.height);
}

@end
