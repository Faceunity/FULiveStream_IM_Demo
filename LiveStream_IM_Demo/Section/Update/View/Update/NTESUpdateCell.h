//
//  NTESUpdateCell.h
//  NTESUpadateUI
//
//  Created by Netease on 17/2/24.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESVideoEntity.h"

@protocol NTESUpdateCellProtocol;

@interface NTESUpdateCell : UITableViewCell

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) NTESVideoItemState state;
@property (nonatomic, weak) id <NTESUpdateCellProtocol> delegate;

- (void)configCellWithItem:(NTESVideoEntity *)item;

@end

@protocol NTESUpdateCellProtocol <NSObject>
@optional
- (void)updateCellRetryAction:(NTESUpdateCell *)cell;
@end
