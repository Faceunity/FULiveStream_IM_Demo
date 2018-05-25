//
//  NTESUpdateDetailStateCell.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/3/10.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESUpdateDefine.h"

@class NTESVideoFormatEntity;
@protocol NTESUpdateDetailStateCellProtocol;

@interface NTESUpdateDetailStateCell : UITableViewCell

@property (nonatomic, weak) id <NTESUpdateDetailStateCellProtocol> delegate;

- (void)configCellWithFormatItem:(NTESVideoFormatEntity *)item
                           state:(NTESVideoItemState)state
                        delegate:(id <NTESUpdateDetailStateCellProtocol>)delegate;

@end

@protocol NTESUpdateDetailStateCellProtocol <NSObject>
@optional

- (void)stateCell:(NTESUpdateDetailStateCell *)cell playName:(NSString *)name url:(NSString *)playUrl;

- (void)stateCell:(NTESUpdateDetailStateCell *)cell share:(NSString *)shareUrl;

- (void)stateCell:(NTESUpdateDetailStateCell *)cell delFormat:(NTESVideoFormat)format;

@end
