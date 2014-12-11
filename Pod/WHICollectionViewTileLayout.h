//
// Created by Johnny Sparks on 11/12/14.
// Copyright (c) 2014 We Heart It. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

struct WHICoordinate {
    NSUInteger col;
    NSUInteger row;
};
typedef struct WHICoordinate WHICoordinate;

static inline WHICoordinate WHICoordinateMake(NSUInteger col, NSUInteger row)
{
    WHICoordinate coordinate; coordinate.col = col; coordinate.row = row; return coordinate;
}

typedef WHICoordinate WHISpan;
static inline WHISpan WHISpanMake(NSUInteger col, NSUInteger row) __attribute__((weakref ("WHICoordinateMake")));


@interface WHICollectionViewTileLayout : UICollectionViewLayout

@property (nonatomic) NSUInteger columnCount;
@property (nonatomic) CGFloat aspectRatio;
@property (nonatomic) CGFloat itemSpacing;

@property (nonatomic, copy) WHISpan (^spanForIndexPath)(NSIndexPath *);

@end