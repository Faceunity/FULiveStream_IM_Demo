//
//  NSDate+NSDateFormatter.m
//  TestControl
//
//  Created by lucky_li on 11-9-6.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSDate+NSDateFormatter.h"

@implementation NSDate(NSDateFormatter)

//根据格式把时间转为字符串
- (NSString *)stringWithFormat:(NSString*)fmt {
    
	NSDateFormatter *df=[[NSDateFormatter alloc] init];
	[df setDateFormat:fmt];
    NSString *dateString=[df stringFromDate:self];

	
    return dateString;
	
}

//根据格式及时区把时间转为字符串
- (NSString *)stringWithFormat:(NSString*)fmt timeZone:(NSTimeZone *)timeZone {

	NSDateFormatter *df=[[NSDateFormatter alloc] init];
	[df setDateFormat:fmt];
    
    [df setTimeZone:timeZone];
    
    NSString *dateString=[df stringFromDate:self];
	
	
    return dateString;    
    
}

//根据时间字符串及格式生成时间
+ (NSDate *)dateFromString:(NSString*)str withFormat:(NSString*)fmt {
    
	NSDateFormatter *df=[[NSDateFormatter alloc] init];
	
    [df setDateFormat:fmt];
	NSDate *date=[df dateFromString:str];

	
    return date;
}

//判断两个时间是否在同一天
- (BOOL)isTheSameDayWithDate:(NSDate *)theDate {

    if (theDate == nil) {
        
        return NO;
        
    }
    
    NSString *day1=[self stringWithFormat:@"yyyy-MM-dd"];
    NSString *day2=[theDate stringWithFormat:@"yyyy-MM-dd"];
    if ([day1 isEqualToString:day2]) {
        
        return YES;
        
    } else {
        
        return NO;
        
    }
    
}

@end
