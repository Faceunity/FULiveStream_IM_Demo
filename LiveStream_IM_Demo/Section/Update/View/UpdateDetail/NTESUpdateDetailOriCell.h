//
//  NTESUpdateDetailOriCell.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/3/13.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NTESVideoEntity;
@protocol NTESUpdateDetailOriCellProtocol;

@interface NTESUpdateDetailOriCell : UITableViewCell

@property (nonatomic, weak) id <NTESUpdateDetailOriCellProtocol> delegate;

- (void)configCellWithItem:(NTESVideoEntity *)item delegate:(id <NTESUpdateDetailOriCellProtocol>)delegate;

@end

@protocol NTESUpdateDetailOriCellProtocol <NSObject>

@optional

- (void)oriCell:(NTESUpdateDetailOriCell *)cell playName:(NSString *)name url:(NSString *)playUrl;

- (void)oriCell:(NTESUpdateDetailOriCell *)cell share:(NSString *)shareUrl;

@end
