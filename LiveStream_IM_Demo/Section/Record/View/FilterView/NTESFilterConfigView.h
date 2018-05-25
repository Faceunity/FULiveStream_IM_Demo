//
//  NTESFilterConfigView.h
//  ShortVideoProcess_Demo
//
//  Created by Netease on 17/4/1.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESBaseView.h"

typedef void(^NTESFilterConfigSelectedBlock)(NSInteger index);

@interface NTESFilterConfigView : NTESBaseView

@property (nonatomic, strong) NSArray <NSString *>*datas;

@property (nonatomic, assign) NSInteger selectIndex;

@property (nonatomic, copy) NTESFilterConfigSelectedBlock selectBlock;

- (void)showInView:(UIView *)view complete:(void (^)())complete;

- (void)dismissComplete:(void (^)())complete;

@end
