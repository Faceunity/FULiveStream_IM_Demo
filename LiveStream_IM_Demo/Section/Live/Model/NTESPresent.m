//
//  NTESPresent.m
//  NIMLiveDemo
//
//  Created by chris on 16/3/29.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NTESPresent.h"

@implementation NTESPresent

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _type  = [[aDecoder decodeObjectForKey:@"type"] integerValue];
        _count = [[aDecoder decodeObjectForKey:@"count"] integerValue];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _icon = [aDecoder decodeObjectForKey:@"icon"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:@(self.type)  forKey:@"type"];
    [encoder encodeObject:@(self.count) forKey:@"count"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.icon forKey:@"icon"];
}

@end
