//
//  NTESActionSheet+NTESBlock.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/1/23.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESActionSheet.h"

typedef void (^ActionSheetBlock)(NSInteger);

@interface NTESActionSheet (NTESBlock)<NTESActionSheetDelegate>
- (void)showInView: (UIView *)view completionHandler: (ActionSheetBlock)block;
- (void)clearActionBlock;
@end
