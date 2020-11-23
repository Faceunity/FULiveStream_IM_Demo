//
//  NESelectViewTableViewCell.m
//  LSMediaCaptureDemo
//
//  Created by emily on 16/10/20.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#import "NESelectViewTableViewCell.h"
#import "Masonry.h"
#import "NEInternalMacro.h"

@interface NESelectViewTableViewCell ()

@end

@implementation NESelectViewTableViewCell

- (void)setupSubViews {
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.button1 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 1;
        [btn setImage:[UIImage imageNamed:@"btn_player_unselected"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"btn_player_selected"] forState:UIControlStateSelected];
        [btn setTitle:@"超清" forState:UIControlStateNormal];
        btn.titleLabel.font = FONT(16.f);
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        [btn addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:[[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
        btn;
    });
    
    self.button2 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 2;
        [btn setImage:[UIImage imageNamed:@"btn_player_unselected"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"btn_player_selected"] forState:UIControlStateSelected];
        [btn setTitle:@"高清" forState:UIControlStateNormal];
        btn.titleLabel.font = FONT(16.f);
        [btn addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];;
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        [btn setTitleColor:[[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
        btn;
    });
    
    self.button3 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 3;
        [btn setImage:[UIImage imageNamed:@"btn_player_unselected"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"btn_player_selected"] forState:UIControlStateSelected];
        [btn setTitle:@"标清" forState:UIControlStateNormal];
        btn.titleLabel.font = FONT(16.f);
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        [btn setTitleColor:[[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    self.button4 = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 4;
        [btn setImage:[UIImage imageNamed:@"btn_player_unselected"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"btn_player_selected"] forState:UIControlStateSelected];
        [btn setTitle:@"流畅" forState:UIControlStateNormal];
        btn.titleLabel.font = FONT(16.f);
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
        [btn setTitleColor:[[UIColor alloc] initWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:1.0] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    
    [@[_button1, _button2, _button3, _button4] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.contentView addSubview:view];
    }];
    
}

- (void)setupConstraints {
    UIView *backView = self.contentView;
    CGFloat offWidth = UIScale(40);

    [self.button1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(backView.mas_centerY);
        make.centerX.equalTo(backView.mas_left).offset(offWidth);
        make.height.equalTo(backView.mas_height);
    }];
    
    [self.button2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(backView.mas_centerY);

        make.centerX.equalTo(backView.mas_left).offset(offWidth*3);
        make.height.equalTo(backView.mas_height);
    }];
    
    [self.button3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(backView.mas_centerY);
//        make.centerX.equalTo(backView.mas_centerX).multipliedBy(1.25);
        make.centerX.equalTo(backView.mas_left).offset(offWidth*5);
        make.height.equalTo(backView.mas_height);
    }];
    
    [self.button4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(backView.mas_centerY);
//        make.centerX.equalTo(backView.mas_centerX).multipliedBy(1.75);
        make.centerX.equalTo(backView.mas_left).offset(offWidth*7);
//        make.width.equalTo(@100);
        make.height.equalTo(backView.mas_height);
    }];
}

- (void)reloadData {
    
}

- (void)btnTapped:(UIButton *)sender {
    sender.selected = !sender.selected;
    [@[_button1, _button2, _button3, _button4]enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
        if (btn.tag == sender.tag) {
            btn.selected = YES;
        }
        else {
            btn.selected = NO;
        }
        [btn setImage:[UIImage imageNamed:@"btn_player_unselected"] forState:UIControlStateNormal];
    }];
    if (sender.selected) {
        [sender setImage:[UIImage imageNamed:@"btn_player_selected"] forState:UIControlStateNormal];
    }
    else
        [sender setImage:[UIImage imageNamed:@"btn_player_unselected"] forState:UIControlStateNormal];
}


@end
