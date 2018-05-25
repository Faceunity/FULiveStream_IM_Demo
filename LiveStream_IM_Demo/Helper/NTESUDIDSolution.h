//
//  NTESUDIDSolution.h
//  XL
//
//  Created by Wesley Lin on 1/2/14.
//
//

#import <Foundation/Foundation.h>

/*
 特殊说明：
 UDID解决方案如下：
 iOS5 或更早则使用MAC地址生成MD5字串进而产生UDID
 iOS6 或以上，则使用identifierForVendor来生成MD5字串进而产生UDID
 
 需要注意的是，identifierForVendor在厂商的所有应用被卸载后会被重置
 
 需要注意的是： 不用对这里生成的UDID进行持久化。
 */
@interface NTESUDIDSolution : NSObject

// 长度为32的字串, 具有唯一性, 一般不直接用这个
+ (NSString*)xlUDID_MD5;

// 本质上相当于截取xlUDID末尾的一部分, 满足 8 <= length <= 40 则唯一性有所保证
+ (NSString*)xlUDID_HashToLength:(NSInteger)length;

// 长度为40的字串, 由 xlUDID_MD5 加上 哈希值 拼接而成, 和xlUDID_MD5一样的唯一性
+ (NSString*)xlUDID;

@end
