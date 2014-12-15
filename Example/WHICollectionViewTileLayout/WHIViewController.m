//
//  WHIViewController.m
//  WHICollectionViewTileLayout
//
//  Created by johnnyfuchs on 12/11/2014.
//  Copyright (c) 2014 johnnyfuchs. All rights reserved.
//

#import "WHIViewController.h"
#import "WHICollectionViewTileLayout.h"

@interface WHIViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong) UICollectionView *cv;
@property(nonatomic, strong) WHICollectionViewTileLayout *layout;
@end

@implementation WHIViewController

- (void)viewDidLoad
{

    self.layout = [[WHICollectionViewTileLayout alloc] init];
    self.layout.columnCount = 7;
    self.layout.aspectRatio = .67;
    self.layout.itemSpacing = 2;
    [self.layout setSpanForIndexPath:^WHISpan(NSIndexPath *indexPath) {
        return WHISpanMake(arc4random_uniform(3)+1, arc4random_uniform(3)+1);
    }];
    
    self.cv = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.layout];
    self.cv.translatesAutoresizingMaskIntoConstraints = NO;
    self.cv.backgroundColor = [UIColor colorWithRed:226./255. green:237./255. blue:202./255. alpha:1];
    [self.cv registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.cv.delegate = self;
    self.cv.dataSource = self;
    [self.view addSubview:self.cv];

    NSDictionary *views = @{ @"cv":self.cv };
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cv]|" options:0 metrics:nil views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[cv]|" options:0 metrics:nil views:views]];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    switch(toInterfaceOrientation){

        case UIInterfaceOrientationUnknown:
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            self.layout.columnCount = 7;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            self.layout.columnCount = 14;
            break;
    }
    [self.cv.collectionViewLayout prepareLayout];
    [self.cv reloadData];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5000;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.contentView.layer.borderWidth = 2;
    cell.contentView.layer.borderColor = [UIColor colorWithRed:153./255. green:153./255. blue:141./255. alpha:1].CGColor;
    cell.contentView.backgroundColor = [UIColor colorWithRed:219./255. green:168./255. blue:167./255. alpha:1];
    return cell;
}


@end
