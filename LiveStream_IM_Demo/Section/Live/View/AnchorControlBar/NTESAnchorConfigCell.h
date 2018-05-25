//
//  NTESAnchorConfigCell.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/1/10.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NTESAnchorConfigCellProtocol;

@interface NTESAnchorConfigCell : UITableViewCell

@property (nonatomic, weak) id <NTESAnchorConfigCellProtocol> delegate;

- (void)config:(NSString *)title switchIsOn:(BOOL)isOn;

- (void)config:(NSString *)title accessory:(NSString *)accessory;

@end


@protocol NTESAnchorConfigCellProtocol <NSObject>

//开关事件
- (void)configCell:(NTESAnchorConfigCell *)cell switchIsOn:(BOOL)isOn;

@end
