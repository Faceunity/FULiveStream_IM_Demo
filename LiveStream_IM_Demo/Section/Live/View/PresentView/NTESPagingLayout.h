//
//  NTESPagingLayout.h
//  LiveStream_IM_Demo
//
//  Created by Netease on 17/1/19.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NTESPagingLayout : UICollectionViewLayout

@property (nonatomic, assign) CGFloat minimumLineSpacing; //行间距

@property (nonatomic, assign) CGFloat minimumInteritemSpacing; //item间距

@property (nonatomic, assign) CGSize itemSize; //item大小

@property (nonatomic, assign) UIEdgeInsets sectionInset;

@end
