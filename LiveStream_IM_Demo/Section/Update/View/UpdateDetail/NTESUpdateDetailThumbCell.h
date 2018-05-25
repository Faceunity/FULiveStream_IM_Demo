//
//  NTESUpdateDetailThumbCell.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/3/10.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NTESUpdateDetailThumbCell : UITableViewCell


/**
 配置cell，优先使用thumbImg

 @param thumbImg 图片对象
 @param imgUrl 图片网络url
 */
- (void)configCellWithImage:(UIImage *)thumbImg imgUrl:(NSString *)imgUrl;

@end
