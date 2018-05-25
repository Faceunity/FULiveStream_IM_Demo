//
//  NTESPresentBoxCell.h
//  NIMLiveDemo
//
//  Created by chris on 16/3/31.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "NTESCollectionCell.h"
#import "NTESPresentMessage.h"

@interface NTESPresentBoxCell : NTESCollectionCell

- (void)refreshPresent:(NTESPresent *)present
                 count:(NSInteger)count;

@end
