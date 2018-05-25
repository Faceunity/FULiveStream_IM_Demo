//
//  NSDate+NSDateFormatter.h
//  TestControl
//
//  Created by lucky_li on 11-9-6.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

/*****************************************************************************************
 ** 使用方法：                                                                           **
 ** //-----时间转字符串                                                                   **
 ** NSDate *date = [NSDate date];                                                       **
 ** //本地时区                                                                           **
 ** NSString *text1 = [date stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];                   **
 ** //零时区                                                                             **
 ** NSString *text2 = [date stringWithFormat:@"yyyy-MM-dd HH:mm:ss"                     **
 **                                 timeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]]; **
 ** //-----字符串转时间                                                                   **
 ** NSString *text = @"2012-06-07 12:00:00 +0000";                                      **
 ** NSDate *date1 = [NSDate dateFromString:text withFormat:@"yyyy-MM-dd HH:mm:ss Z"];   **
 *****************************************************************************************/

#import <Foundation/Foundation.h>


@interface NSDate(NSDateFormatter)

//根据格式把时间转为字符串（默认使用本地所在时区）
- (NSString *)stringWithFormat:(NSString*)fmt;

//根据格式及时区把时间转为字符串
- (NSString *)stringWithFormat:(NSString*)fmt timeZone:(NSTimeZone *)timeZone;

//根据时间字符串及格式生成时间
+ (NSDate *)dateFromString:(NSString*)str withFormat:(NSString*)fmt;

//判断两个时间是否在同一天
- (BOOL)isTheSameDayWithDate:(NSDate *)theDate;

@end
