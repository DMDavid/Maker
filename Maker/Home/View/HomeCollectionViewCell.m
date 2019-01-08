//
//  HomeCollectionViewCell.m
//  Maker
//
//  Created by David on 2018/12/7.
//  Copyright © 2018 David. All rights reserved.
//

#import "HomeCollectionViewCell.h"

@interface HomeCollectionViewCell ()


@end

@implementation HomeCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.layer.cornerRadius = 12;
        self.layer.masksToBounds = YES;
        
        [self addSubview:self.clickButton];
        
        [self.clickButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self);
        }];
        
    }
    return self;
}

- (void)CellDidCLickAction {
    if (self.cellDidClickBlock) {
        self.cellDidClickBlock();
    }
}

- (UIButton *)clickButton {
    if (!_clickButton) {
        _clickButton = [[UIButton alloc] init];
        [_clickButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_clickButton addTarget:self action:@selector(CellDidCLickAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clickButton;
}

@end
