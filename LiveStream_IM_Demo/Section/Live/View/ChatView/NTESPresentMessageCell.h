//
//  NTESPresentMessageCell.h
//  NEUIDemo
//
//  Created by Netease on 17/1/5.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NTESPresentMessage;
@protocol NTESPresentMessageCellDelegate;

@interface NTESPresentMessageCell : UITableViewCell

@property (nonatomic, weak) id <NTESPresentMessageCellDelegate> delegate;

- (void)refreshWithPresent:(NTESPresentMessage *)message;
- (void)show;
- (void)hide;

@end

@protocol NTESPresentMessageCellDelegate <NSObject>

- (void)cellDidHide:(NTESPresentMessageCell *)cell
            present:(NTESPresentMessage *)present;

@end
