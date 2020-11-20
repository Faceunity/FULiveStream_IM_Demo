//
//  NEInputTableViewCell.h
//  LSMediaCaptureDemo
//
//  Created by emily on 16/10/21.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "NERootTableViewCell.h"

@interface NEInputTableViewCell : NERootTableViewCell <UITextViewDelegate>

@property(nonatomic, strong) UITextView *inputTextView;

@end
