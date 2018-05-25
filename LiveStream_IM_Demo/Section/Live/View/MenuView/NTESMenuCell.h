//
//  NTESMenuCell.h
//  NEUIDemo
//
//  Created by Netease on 17/1/6.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESCollectionCell.h"

@interface NTESMenuCell : NTESCollectionCell

- (void)refreshCell:(NSString *)title icon:(NSString *)icon selectIcon:(NSString *)selectIcon;

@end
