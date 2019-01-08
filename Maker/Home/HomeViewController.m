//
//  HomeViewController.m
//  Maker
//
//  Created by David on 2018/12/7.
//  Copyright © 2018 David. All rights reserved.
//

#import "HomeViewController.h"
#import "HomeCollectionViewCell.h"
#import "KeyFrameMakerViewController.h"

@interface HomeViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *mainCollectionView;

@end

@implementation HomeViewController

static NSString *cellIdentifer = @"cellIdentifer";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.mainCollectionView registerClass:[HomeCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifer];
    
}


// 设置cell大小 itemSize：可以给每一个cell指定不同的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat margin = 30;
    CGFloat itemWidth = [UIScreen mainScreen].bounds.size.width - 2 * margin;
    CGFloat itemHeight = 400;
    return CGSizeMake(itemWidth, itemHeight);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifer forIndexPath:indexPath];
    
    [cell.clickButton setTitle:@"定格动画" forState:UIControlStateNormal];
    
    __weak typeof(self) weakSelf = self;
    cell.cellDidClickBlock = ^{
        [weakSelf pushToKeyFrameMakerController];
    };
    
    return cell;
}

- (void)pushToKeyFrameMakerController {
    KeyFrameMakerViewController *viewController = [[KeyFrameMakerViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
