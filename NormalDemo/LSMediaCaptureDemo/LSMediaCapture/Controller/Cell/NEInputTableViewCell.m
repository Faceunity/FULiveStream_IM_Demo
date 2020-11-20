//
//  NEInputTableViewCell.m
//  LSMediaCaptureDemo
//
//  Created by emily on 16/10/21.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "NEInputTableViewCell.h"
#import "Masonry.h"
#import "NEInternalMacro.h"

@interface NEInputTableViewCell ()

@end

@implementation NEInputTableViewCell

- (void)setupSubViews {
    self.inputTextView = ({
        UITextView *textView = [UITextView new];
        textView.backgroundColor = [UIColor whiteColor];
        textView.font = FONT(16.f);
        textView.textColor = [UIColor blackColor];
        textView.returnKeyType = UIReturnKeyDefault;
        textView.keyboardType = UIKeyboardTypeDefault;
        textView.scrollEnabled = YES;
        textView.dataDetectorTypes = UIDataDetectorTypeAll;
        //FIX ME:alter with a picture as background is better
        textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        textView.layer.borderWidth = 1.f;
        textView.layer.cornerRadius = 5.0;
        textView.editable = YES;
        textView.selectable = YES;
        textView;
    });
    [self.contentView addSubview:self.inputTextView];
}

- (void)setupConstraints {
    [self.inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(10);
        make.top.equalTo(self.contentView).offset(10);
        make.bottom.right.equalTo(self.contentView).offset(-10);
   }];
}

- (void)reloadData {
    
}

@end
