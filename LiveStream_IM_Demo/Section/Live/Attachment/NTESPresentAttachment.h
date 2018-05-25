//
//  NTESPresentAttachment.h
//  NIMLiveDemo
//
//  Created by chris on 16/3/30.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTESPresentAttachment : NSObject<NIMCustomAttachment>

@property (nonatomic,assign) NSInteger presentType; //此类型请在 Presents.plist 中定义,为各礼物的 key 值。

@property (nonatomic,assign) NSInteger count;

@end
