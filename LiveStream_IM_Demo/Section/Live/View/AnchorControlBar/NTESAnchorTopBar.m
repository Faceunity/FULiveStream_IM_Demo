//
//  NTESAnchorTopBar.m
//  NEUIDemo
//
//  Created by Netease on 17/1/6.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESAnchorTopBar.h"
#import "NTESAvatarCell.h"

@interface NTESAnchorTopBar () <UICollectionViewDelegate, UICollectionViewDataSource>
{
    NSArray *_userInfos;
}
@property (weak, nonatomic) IBOutlet UICollectionView *userList;
@property (weak, nonatomic) IBOutlet UILabel *roomIdLab;
@property (weak, nonatomic) IBOutlet UILabel *usersOfRoom;
@property (weak, nonatomic) IBOutlet UIView *roomInfoContainerView;
@property (weak, nonatomic) IBOutlet UIButton *videoBtn;
@property (weak, nonatomic) IBOutlet UIButton *audioBtn;
@property (weak, nonatomic) IBOutlet UIButton *cameraBtn;

@end

@implementation NTESAnchorTopBar

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.userList.delegate = self;
    self.userList.dataSource = self;
    [self.userList registerClass:[NTESAvatarCell class] forCellWithReuseIdentifier:@"cell"];
}

+ (instancetype)topBarInstance
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([NTESAnchorTopBar class]) owner:nil options:nil];
    return array.lastObject;
}

- (void)hiddenChatroomView:(BOOL)isHidden
{
    _roomInfoContainerView.hidden = isHidden;
    _userList.hidden = isHidden;
    _audioBtn.hidden = isHidden;
}

- (void)hiddenVideo:(BOOL)isHidden
{
    _videoBtn.hidden = isHidden;
}

- (void)hiddenAudio:(BOOL)isHidden
{
    _audioBtn.hidden = isHidden;
}

- (void)hiddenCamera:(BOOL)isHidden
{
    _cameraBtn.hidden = isHidden;
}

- (void)refreshBarWithChatroom:(NTESChatroom *)chatroom
{
    _roomIdLab.text = [NSString stringWithFormat:@"%@", chatroom.roomId];
}

- (void)refreshBarWithAudiences:(NSArray <NTESMember *> *)audiences
{
    _userInfos = audiences;
    
    _usersOfRoom.text = [NSString stringWithFormat:@"%zi 人", _userInfos.count];
    
    [_userList reloadData];
}

- (void)sendTouchupInsideToAudio
{
    [_audioBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _userInfos.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NTESAvatarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NTESMember *userInfo = _userInfos[indexPath.row];
    [cell configCell:userInfo.avatarUrlString nickName:userInfo.showName isMute:userInfo.isMuted];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = self.userList.height - 4.0 * 2;
    CGFloat width = height - 19.0;
    return CGSizeMake(width, height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(topBar:didSelectMember:)]) {
        
        NTESMember *member = _userInfos[indexPath.row];
        [_delegate topBar:self didSelectMember:member];
    }
}

#pragma mark - Aciton
- (IBAction)videoBtnAction:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(topBar:videoOpen:)])
    {
        [_delegate topBar:self videoOpen:sender.selected];
    }
    
    sender.selected = !sender.selected;
}

- (IBAction)audioBtnAction:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(topBar:audioOpen:)]) {
        [_delegate topBar:self audioOpen:sender.selected];
    }
    
    sender.selected = !sender.selected;
}

- (IBAction)cameraAction:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(topBar:cameraIsFront:)]) {
        [_delegate topBar:self cameraIsFront:sender.selected];
    }
    sender.selected = !sender.selected;
}

- (IBAction)closeAction:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(topBarClose:)]) {
        [_delegate topBarClose:self];
    }
}

@end
