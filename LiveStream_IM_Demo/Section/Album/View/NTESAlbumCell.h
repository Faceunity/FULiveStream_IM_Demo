//
//  NTESAlbumCell.h
//  ShortVideo_Demo
//
//  Created by Netease on 17/2/13.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTESAlbumVideoEntity.h"

@interface NTESAlbumCell : UICollectionViewCell

- (void)confgiWithItem:(NTESAlbumVideoEntity *)item;

- (void)selectedCell:(BOOL)isSelect;

@end
