//
//  NTESAudienceTopBar.m
//  NEUIDemo
//
//  Created by Netease on 17/1/4.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESAudienceTopBar.h"
#import "NTESAvatarCell.h"

@interface NTESAudienceTopBar ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSArray *_userInfos;
    
}
@property (weak, nonatomic) IBOutlet UIImageView *headerImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UICollectionView *audienceHeaderList;
@property (weak, nonatomic) IBOutlet UILabel *numberOfAudience;
@property (weak, nonatomic) IBOutlet UIView *containView;
@property (weak, nonatomic) IBOutlet UILabel *roomIdLab;

@end

@implementation NTESAudienceTopBar

+ (instancetype)topBarInstance
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([NTESAudienceTopBar class]) owner:nil options:nil];
    return [array lastObject];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _containView.backgroundColor = UIColorFromRGBA(0x0, .5f);
    _audienceHeaderList.delegate = self;
    _audienceHeaderList.dataSource = self;
    [_audienceHeaderList registerClass:[NTESAvatarCell class] forCellWithReuseIdentifier:@"avatarCell"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _containView.layer.cornerRadius = _containView.height / 2;
    _headerImage.layer.cornerRadius = _headerImage.height / 2;
}

#pragma mark -- API
- (void)refreshBarWithChatroom:(NTESChatroom *)chatroom
{
    _roomIdLab.text = (chatroom.roomId ?: @"");
}

- (void)refreshBarWithCreator:(NTESMember *)creator
{
    [_headerImage setCircleImageWithUrl:creator.avatarUrlString];
    _nameLab.text = creator.showName;
}

- (void)refreshBarWithAudiences:(NSArray <NTESMember *> *)audiences
{
    _userInfos = audiences;
    
    _numberOfAudience.text = [NSString stringWithFormat:@"%zi 人", _userInfos.count];
    
    [_audienceHeaderList reloadData];
}

#pragma mark - Action
//关闭
- (IBAction)closeAction:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(topBarClickClose:)]) {
        [_delegate topBarClickClose:self];
    }
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _userInfos.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NTESAvatarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"avatarCell" forIndexPath:indexPath];
    NTESMember *userInfo = _userInfos[indexPath.row];
    [cell configCell:userInfo.avatarUrlString nickName:userInfo.showName isMute:userInfo.isMuted];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = _headerImage.width;
    CGFloat height = collectionView.height;
    return CGSizeMake(width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return CGFLOAT_MIN;
}

@end
