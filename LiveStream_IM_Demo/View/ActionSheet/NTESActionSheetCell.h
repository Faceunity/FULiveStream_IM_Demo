//
//  NTESActionSheetCell.h
//  NTESActionSheet
//
//  Created by liuhu on 16/5/17.
//  Copyright © 2016年 LEA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NTESActionSheetCell : UITableViewCell
@property (nonatomic,strong) UILabel *actionLabel ;
- (void)buildUI;
@end
