//
//  NSString+NTES.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/1/9.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NTES)

- (CGSize)stringSizeWithFont:(UIFont *)font;

- (NSUInteger)getBytesLength;

- (NSString *)stringByDeletingPictureResolution;

- (NSString *)removeSpace;

+ (BOOL)checkRoomNumber:(NSString *)roomNumber;

+ (BOOL)checkUserName:(NSString*) username;

+ (BOOL)checkPassword:(NSString*) password;

+ (BOOL)checkNickName : (NSString*) nickName;

+ (BOOL)checkPullUrl: (NSString *) pullUrl;

+ (BOOL)checkDemandUrl:(NSString *)demandUrl;

+ (BOOL)checkVideoName:(NSString *)videoName;

/**
 *  计算文本占用的宽高
 *
 *  @param font    显示的字体
 *  @param maxSize 最大的显示范围
 *
 *  @return 占用的宽高
 */
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;


/**
 转换时间字符串

 @param second 秒
 @param minDigits 最小位数 ［2, 3］。 2 - 00:00 ，3 － 00:00:00
 @return 时间字符串
 */
+ (NSString *)timeStringWithSecond:(NSInteger)second minDigits:(NSInteger)minDigits;

@end
