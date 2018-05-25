//
//  NTESTextAttachmentView.h
//  LiveStream_IM_Demo
//
//  Created by emily on 2017/8/25.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESBaseView.h"

@class NTESTextAttachmentView;
@protocol NTESTextAttachmentViewDelegate <NSObject>

- (void)textAttachment:(NTESTextAttachmentView *)textAttachmentView selectTextStyle:(NSInteger)index;

- (void)textAttachment:(NTESTextAttachmentView *)textAttachmentView selectTextColor:(NSInteger)index;

@end

@interface NTESTextAttachmentView : NTESBaseView

@property(nonatomic, weak) id<NTESTextAttachmentViewDelegate> delegate;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;

@end
