//
//  NTESPresentMessageView.m
//  NEUIDemo
//
//  Created by Netease on 17/1/5.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NTESPresentMessageView.h"
#import "NTESPresentMessageCell.h"
#import "NTESPresentMessage.h"

@interface NTESPresentMessageView ()<UITableViewDelegate,UITableViewDataSource, NTESPresentMessageCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger lastAnimateIndex;
@property (nonatomic, strong) NSMutableArray<NTESPresentMessage *> *prepareDatas;
@property (nonatomic, strong) NSMutableArray *datas;
@end

@implementation NTESPresentMessageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self customInit];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.tableView.frame = self.bounds;
}

- (void)customInit
{
    [self addSubview:self.tableView];
    
    _datas = [@[[NSNull null],[NSNull null]] mutableCopy];
    _prepareDatas = [[NSMutableArray alloc] init];
}

- (void)checkPrepareData
{
    NTESPresentMessage *present = self.prepareDatas.firstObject;
    if (!present || ![self.datas containsObject:[NSNull null]]) {
        return;
    }
    NSArray *array = [NSArray arrayWithArray:self.datas];
    BOOL find = NO;
    NSInteger index = array.count - 1;
    for (;index >= 0; index--) {
        NSObject *object = array[index];
        if ([object isKindOfClass:[NSNull class]]) {
            find = YES;
            break;
        }
    }
    if (!find) {
        //全满了就替换最老的一个
        index = labs(self.lastAnimateIndex - 1) % 2;
    }
    
    self.datas[index]  = present;
    
    NTESPresentMessageCell *cell = self.tableView.visibleCells[index];
    
    [cell refreshWithPresent:present];
    [cell show];
    
    [self.prepareDatas removeObject:present];
    
    self.lastAnimateIndex = index;
}

#pragma mark - Public
- (void)addPresent:(NTESPresentMessage *)present
{
    [self.prepareDatas addObject:present];
    [self checkPrepareData];
}


#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NTESPresentMessageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.delegate = self;
    [cell refreshWithPresent:self.datas[indexPath.row]];
    return cell;
}

#pragma mark - NTESPresentMessageCellDelegate
- (void)cellDidHide:(NTESPresentMessageCell *)cell present:(NTESPresentMessage *)present
{
    NSInteger index = [self.tableView indexPathForCell:cell].row;
    if (present == self.datas[index]) {
        self.datas[index] = [NSNull null];
        [self checkPrepareData];
    }
}

#pragma mark - Get
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.userInteractionEnabled = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[NTESPresentMessageCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

@end
