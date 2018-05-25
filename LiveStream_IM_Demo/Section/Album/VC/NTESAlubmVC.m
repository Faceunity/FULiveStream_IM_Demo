//
//  NTESAlubmVC.m
//  NTESUpadateUI
//
//  Created by Netease on 17/2/23.
//  Copyright © 2017年 Netease. All rights reserved.
//  相册选择视频页面

#import "NTESAlubmVC.h"
#import "NTESAlbumService.h"
#import "NTESAlbumHeader.h"
#import "NTESAlbumCell.h"
#import "NTESAlubmBottomBar.h"
#import "NTESRecordVC.h"
#import "NTESVideoTrimmerVC.h"
#import <Photos/Photos.h>

#define ITEM_COUNT_LINE (3)
#define ITEM_INTERVAL (2.0)

@interface NTESAlubmVC () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NTESAlbumBottomBarProtocol, PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) NSMutableDictionary *selectVideoItems;

@property(nonatomic, strong) NSMutableArray *selectItems;

@property (nonatomic, strong) NSMutableArray<NSIndexPath *> *selectIndexPaths;

@property (nonatomic, strong) NSArray <NTESAlbumGroupEntity *>*groups;

@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UICollectionView *lists;
@property (nonatomic, strong) NTESAlubmBottomBar *bottomBar;

@end

@implementation NTESAlubmVC

- (BOOL)isStatusBarVisible {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"选择视频";
    self.navigationItem.leftBarButtonItems = nil;
    
    _selectIndexPaths = [NSMutableArray array];
    _selectVideoItems = [NSMutableDictionary dictionary];
    _selectItems = [NSMutableArray array];

    //添加控件
    [self.view addSubview:self.lists];
    [self.view addSubview:self.bottomBar];
    
    //权限申请
    __weak typeof(self) weakSelf = self;
    [NTESAuthorizationHelper requestAblumAuthorityWithCompletionHandler:^(NSError *error) {
        if (error) {
            [weakSelf showDissmissMessage];
        }
        else
        {
            [weakSelf loadAlbumDatas];
        }
    }];
}

- (void)configNavigationBar {
    UIImage *backImg = [UIImage imageWithColor:UIColorFromRGB(0xf7f7f9) size:CGSizeMake(100, 100)];
    [self.navigationController.navigationBar setBackgroundImage:backImg forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:![self isNaviBarVisible] animated:YES];
    [self configNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.lists.frame.size.width != self.view.frame.size.width) {
        
        self.bottomBar.frame = CGRectMake(0,
                                          self.view.height - 43.0,
                                          self.view.width,
                                          43.0);
        self.lists.frame = CGRectMake(0,
                                      0,
                                      self.view.width,
                                      self.view.height - self.bottomBar.height);
    }
}

+ (instancetype)albumWithMaxNumber:(NSInteger)maxNumber withMinDuration:(CGFloat)duration selected:(NTESAlubmSelectBlock)selected
{
    NTESAlubmVC *vc = [NTESAlubmVC new];
    vc.maxNumber = maxNumber;
    vc.minDuration = duration;
    vc.selected = selected;
    return vc;
}

- (void)loadAlbumDatas
{
    //读取数据
    __weak typeof(self) weakSelf = self;
    [[NTESAlbumService shareInstance] videoGroupsWithAscending:NO
                                               withMinDuration:self.minDuration
                                                      complete:^(NSArray<NTESAlbumGroupEntity *> *groups) {
        weakSelf.groups = groups;
        [weakSelf.lists reloadData];
    }];
}

- (void)showDissmissMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"请开启相册访问权限"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        
        __weak typeof(self) weakSelf = self;
        [alert showAlertWithCompletionHandler:^(NSInteger index) {
            [weakSelf dismissVC];
        }];
    });
}

//VC消失
- (void)dismissVC
{
    WEAK_SELF(weakSelf);
    NSInteger count = self.navigationController.viewControllers.count;
    if ([UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if ([self.navigationController.viewControllers[count - 2] isKindOfClass:[NTESRecordVC class]])
    {
        //这里只有一个，所以直接写死
        NTESAlbumVideoEntity *videoEntity = _selectItems[0];
        [SVProgressHUD showWithStatus:@"视频载入中..."];
        [[NTESAlbumService shareInstance] cacheVideoWithAlbumVideoKey:videoEntity.assetKey
                                                             complete:^(NSError *error, NSString *filePath) {
                                                                 //FIX ME:
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     if (filePath) {
                                                                         //清空选择的数据
                                                                         [SVProgressHUD dismiss];
                                                                         [weakSelf refreshUI];
                                                                         NTESVideoTrimmerVC *trimmerVC = [[NTESVideoTrimmerVC alloc] initWithVideoURL:filePath trimDuration:weakSelf.minDuration];
                                                                         [weakSelf.navigationController pushViewController:trimmerVC animated:YES];
                                                                     }
                                                                 });
                                                             }];

    }
    else
    {
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }
}

- (void)refreshUI {
    
    [self collectionView:self.lists didSelectItemAtIndexPath:_selectIndexPaths[0]];
    [self.selectItems removeAllObjects];
}


//移除视频
- (void)removeSelectVideo:(NSIndexPath *)indexPath cell:(NTESAlbumCell *)cell
{
    //视频
    [_selectIndexPaths removeObject:indexPath];
    [cell selectedCell:NO];
    
    //移除视频
    [_selectVideoItems removeObjectForKey:indexPath];
    _bottomBar.count = _selectVideoItems.count;
}

//添加视频
- (void)addSelectVideo:(NSIndexPath *)indexPath cell:(NTESAlbumCell *)cell
{
    NTESAlbumGroupEntity *group = _groups[indexPath.section];
    __block NTESAlbumVideoEntity *item = group.items[indexPath.row];
    UIAlertView *alert = nil;
    
    //添加视频
    __weak typeof(self) weakSelf = self;
    void (^doAddVideo)() = ^(){
        [weakSelf.selectIndexPaths addObject:indexPath];
        [weakSelf.selectVideoItems setObject:item forKey:indexPath];
        [cell selectedCell:YES];
        weakSelf.bottomBar.count = weakSelf.selectVideoItems.count;
    };
    
    //检查个数
    if (_selectVideoItems.count >= _maxNumber)
    {
        alert = [[UIAlertView alloc] initWithTitle:nil
                                           message:[NSString stringWithFormat:@"您最多可以选择%zi个视频", _maxNumber]
                                          delegate:nil
                                 cancelButtonTitle:@"我知道了"
                                 otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    //检查大小
    if (item.size >= 1 * 1024)
    {
        alert = [[UIAlertView alloc] initWithTitle:nil
                                           message:@"单个视频不可超过1G，请重新选择"
                                          delegate:nil
                                 cancelButtonTitle:@"重新选择视频"
                                 otherButtonTitles: nil];
        [alert show];
    }
    else if (item.size < 1 * 1024 && item.size > 512)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"建议选择512M以下的视频上传，您选择了512M以上的视频。"
                                                           delegate:nil
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"保持选择", nil];
        [alertView showAlertWithCompletionHandler:^(NSInteger index) {
            if (index == 1) {
                doAddVideo();
            }
        }];
    }
    else
    {
        doAddVideo();
    }
}

#pragma mark - photoChange

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    [self loadAlbumDatas];
}

#pragma mark - <NTESAlbumBottomBarProtocol>
//底部确认事件
- (void)BottomBarSureAction:(NTESAlubmBottomBar *)bar
{
    __weak typeof(self) weakSelf = self;
    [_selectIndexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NTESAlbumVideoEntity *entity = [weakSelf.selectVideoItems objectForKey:obj];
        
        if (entity) {
            [weakSelf.selectItems addObject:entity];
        }
    }];
    
    //用于上传视频的回调，在添加视频剪辑的时候无用
    if (_selected) {
        _selected(self.selectItems);
    }

    [self dismissVC];
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegate>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _groups.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NTESAlbumGroupEntity *group = _groups[section];
    return group.items.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NTESAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NTESAlbumCell" forIndexPath:indexPath];
    NTESAlbumGroupEntity *group = _groups[indexPath.section];
    NTESAlbumVideoEntity *item = group.items[indexPath.row];
    [cell confgiWithItem:item];
    return cell;
}

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = [[UICollectionReusableView alloc] initWithFrame:CGRectZero];
    
    if (kind == UICollectionElementKindSectionHeader)
    {
        NTESAlbumHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                         withReuseIdentifier:@"HeaderView"
                                                                                forIndexPath:indexPath];
        NTESAlbumGroupEntity *group = _groups[indexPath.section];
        [headerView configHeader:group.dateStr hiddenClear:YES clearBlock:nil];
        reusableview = headerView;
    }
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (collectionView.bounds.size.width - (ITEM_COUNT_LINE - 1) * ITEM_INTERVAL) / ITEM_COUNT_LINE;
    return CGSizeMake(width, width);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(collectionView.bounds.size.width, 50.0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NTESAlbumCell *cell = (NTESAlbumCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([_selectIndexPaths containsObject:indexPath]) {
        [self removeSelectVideo:indexPath cell:cell];
    }
    else
    {
        [self addSelectVideo:indexPath cell:cell];
    }
}

#pragma mark - Getter
- (UICollectionViewFlowLayout *)layout
{
    if (!_layout) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        _layout.minimumLineSpacing = ITEM_INTERVAL;
        _layout.minimumInteritemSpacing = ITEM_INTERVAL;
        _layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _layout;
}

- (UICollectionView *)lists
{
    if (!_lists) {
        _lists = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) collectionViewLayout:self.layout];
        _lists.showsVerticalScrollIndicator = NO;
        _lists.showsHorizontalScrollIndicator = NO;
        _lists.delegate = self;
        _lists.dataSource = self;
        _lists.backgroundColor = [UIColor whiteColor];
        [_lists registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"defaultCell"];
        [_lists registerClass:[NTESAlbumCell class] forCellWithReuseIdentifier:@"NTESAlbumCell"];
        [_lists registerClass:[NTESAlbumHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
    }
    return _lists;
}

- (NTESAlubmBottomBar *)bottomBar
{
    if (!_bottomBar) {
        _bottomBar = [[NTESAlubmBottomBar alloc] init];
        _bottomBar.maxCount = _maxNumber;
        _bottomBar.delegate = self;
    }
    return _bottomBar;
}

@end
