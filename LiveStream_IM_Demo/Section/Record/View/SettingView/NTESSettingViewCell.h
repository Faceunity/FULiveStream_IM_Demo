//
//  NTESSettingViewCell.h
//  ShortVideo_Demo
//
//  Created by Netease on 17/2/17.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CellSelecedBlock)(NSInteger index);

@interface NTESSettingViewCell : UITableViewCell

@property (nonatomic, copy) NSString *titleStr;

@property (nonatomic, strong) NSArray *datas;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, copy) CellSelecedBlock selectedBlock;

- (void)configCellWithTitle:(NSString *)title datas:(NSArray *)datas selecedIndex:(NSInteger)selectedIndex;

@end
