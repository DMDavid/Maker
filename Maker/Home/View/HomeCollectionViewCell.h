//
//  HomeCollectionViewCell.h
//  Maker
//
//  Created by David on 2018/12/7.
//  Copyright © 2018 David. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CellDidClickBlock)(void);

@interface HomeCollectionViewCell : UICollectionViewCell


@property (nonatomic, copy) CellDidClickBlock cellDidClickBlock;

@property (nonatomic, strong) UIButton *clickButton;

@end
