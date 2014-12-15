//
// Created by Johnny Sparks on 11/12/14.
// Copyright (c) 2014 We Heart It. All rights reserved.
//

#import "WHICollectionViewTileLayout.h"

static NSString *kMaxColumnExceededWarning = @"The maximum number of columns is 32";

static const int kDefaultCollectionViewColumnCount = 2;
static const int kMaxColumns = 64;
static const int kMaxRows = 20000;

@interface WHICollectionViewTileLayout ()
@property(nonatomic, strong) NSMutableArray *allAttributes;
@property(nonatomic) CGFloat contentHeight;
@property(nonatomic) CGSize itemSize;
@property (nonatomic) NSUInteger topRow;
@property (nonatomic) NSUInteger bottomRow;
@end

@implementation WHICollectionViewTileLayout {
    uint64_t _buckets[kMaxRows];
    NSUInteger _columnCount;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    CGRect oldBounds = self.collectionView.bounds;
    return CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds);
}

- (void)prepareLayout
{
    [super prepareLayout];
    self.allAttributes = nil;               // clear the index path cache
    self.contentHeight = 0;                 // zero the content height
    memset(_buckets, 0, sizeof(_buckets));  // zero out the buckets
    _bottomRow = 0;
    _topRow = 0;
    _itemSize = CGSizeZero;

    for (NSUInteger section = 0; section < [self.collectionView numberOfSections]; section++){
        NSInteger numberOfItemsInSection = [self.collectionView numberOfItemsInSection:section];
        NSMutableArray *sectionAttributes = self.allAttributes[section];
        for (uint item = 0; item < numberOfItemsInSection; item++) {
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:item inSection:section]];
            sectionAttributes[item] = attributes;
            self.contentHeight = MAX(CGRectGetMaxY(attributes.frame), self.contentHeight);
        }
    }
}

#pragma mark required overrides

- (CGSize)collectionViewContentSize
{
    return CGSizeMake(self.collectionView.frame.size.width, self.contentHeight);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *indexPaths = [self indexPathsInRect:rect];
    NSMutableArray *attributes = [NSMutableArray new];
    [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
        [attributes addObject:self.allAttributes[indexPath.section][indexPath.row]];
    }];

    return attributes;
}


- (NSArray *) indexPathsInRect:(CGRect)rect
{
    NSMutableArray *indexPaths = [NSMutableArray new];
    [self.allAttributes enumerateObjectsUsingBlock:^(NSArray *sectionAttributes, NSUInteger section, BOOL *stop) {
        [sectionAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attributes, NSUInteger item, BOOL *stop2) {
            if(CGRectIntersectsRect(attributes.frame, rect)) {
                [indexPaths addObject:[NSIndexPath indexPathForItem:item inSection:section]];
            }
        }];
    }];
    return indexPaths;
}

#pragma mark calculating layout

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    WHISpan span = self.spanForIndexPath(indexPath);
    WHICoordinate coordinate = [self coordinatesAfterAddingSpan:span];
    attributes.frame = [self frameForCellWithCoordinate:coordinate andSpan:span];
    return attributes;
}

- (CGRect) frameForCellWithCoordinate:(WHICoordinate)coordinate andSpan:(WHISpan)span
{
    CGPoint origin = [self originForCellWithCoordinate:coordinate];
    CGSize size = [self sizeForCellWithSpan:span];
    CGRect frame = CGRectMake(origin.x, origin.y, size.width, size.height);
    return frame;
}

- (CGSize) sizeForCellWithSpan:(WHISpan)span
{
    CGFloat width  = span.col * self.itemSize.width - self.itemSpacing;
    CGFloat height = span.row * self.itemSize.height - self.itemSpacing;
    return CGSizeMake(width, height);
}

- (CGPoint)originForCellWithCoordinate:(WHICoordinate)coordinate
{
    CGFloat x = coordinate.col * self.itemSize.width + self.itemSpacing;
    CGFloat y = coordinate.row * self.itemSize.height + self.itemSpacing;
    return CGPointMake(x, y);
}

#pragma mark Filling Tiles

- (WHICoordinate) coordinatesAfterAddingSpan:(WHISpan)span
{
    WHICoordinate coordinate = [self firstFittingCoordinatesForSpan:span];
   [self fillTilesAtCoordinate:coordinate withSpan:span];
    return coordinate;
}

- (void) fillTilesAtCoordinate:(WHICoordinate) coordinate withSpan:(WHISpan)span
{
    NSAssert(coordinate.row + span.row < kMaxRows, @"Max row exceeded");

    uint64_t colBit;
    for(uint64_t col = coordinate.col; col < coordinate.col + span.col; col ++){
        for(uint64_t row = coordinate.row; row < coordinate.row + span.row; row ++){
            colBit = (uint64_t)1 << col;
            _buckets[row] += colBit;
        }
    }

    _topRow = MAX(_topRow, coordinate.row + span.row);
}

#pragma mark Finding Empty Tiles

- (NSUInteger)bottomRow
{
    NSUInteger cols = self.columnCount;
    uint64_t fullRowValue = ((uint64_t)1 << cols) - 1;
    while(fullRowValue == _buckets[_bottomRow]){
        _bottomRow++;
    }
    return _bottomRow;
}

- (BOOL) tileFilledAtCoordinates:(WHICoordinate) coordinate
{
    uint64_t col = coordinate.col;
    uint64_t colBit = (uint64_t)1 << col;
    return (BOOL) (_buckets[coordinate.row] & colBit);
}

- (WHICoordinate) firstFittingCoordinatesForSpan:(WHISpan)span
{
    NSUInteger minRow = self.bottomRow;
    NSUInteger maxCol = self.columnCount - span.col;
    BOOL spanFits;
    BOOL tileOccupied;
    NSUInteger endCol;
    NSUInteger endRow;
    NSUInteger searchCol;
    uint64_t colBit;

    while(YES){
        for(searchCol = 0; searchCol <= maxCol; searchCol++){
            endCol = searchCol + span.col;
            endRow = minRow + span.row;
            spanFits = YES;

            for(uint64_t col=searchCol; col <  endCol; col++){
                for(uint64_t row= minRow; row < endRow; row++){
                    colBit = (uint64_t)1 << col;
                    tileOccupied = (BOOL) (_buckets[row] & colBit);
                    if(tileOccupied){
                        spanFits = NO;
                        break;
                    }
                }
            }

            if(spanFits){
                return WHICoordinateMake(searchCol, minRow);
            }
        }
        minRow++;
    }
}

-(void) logRows:(NSUInteger)rows
{
    NSLog(@"\n\n");
    for(int row=0; row < rows; row++){
        NSMutableString *rowString = [@"" mutableCopy];
        for(int col=0; col < self.columnCount; col++){
            [rowString appendFormat:@"%@", [self tileFilledAtCoordinates:WHICoordinateMake(col, row)] ? @"X" : @"-"];
        }
        NSLog(@"%@", rowString);
    }
    NSLog(@"\n\n");
}


#pragma mark lazy loaded initializers

- (NSUInteger)columnCount
{
    if(!_columnCount){
        _columnCount = kDefaultCollectionViewColumnCount;
    }
    return _columnCount;
}

- (void)setColumnCount:(NSUInteger)columnCount
{
    NSAssert(columnCount <= kMaxColumns, kMaxColumnExceededWarning);
    _columnCount = columnCount;
}

- (CGFloat)aspectRatio
{
    if(!_aspectRatio){
        _aspectRatio = 1.0f;
    }
    return _aspectRatio;
}

- (WHISpan (^)(NSIndexPath *))spanForIndexPath
{
    if(!_spanForIndexPath){
        _spanForIndexPath = ^WHISpan(NSIndexPath *path) {
            return WHISpanMake(1, 1);
        };
    }
    return _spanForIndexPath;
}

- (NSMutableArray *)allAttributes {
    if(!_allAttributes){
        _allAttributes = [NSMutableArray new];
        for(uint i=0; i < self.columnCount; i++){
            _allAttributes[i] = [NSMutableArray new];
        }
    }
    return _allAttributes;
}

- (CGSize)itemSize
{
    if(CGSizeEqualToSize(_itemSize, CGSizeZero)){
        CGFloat width = (self.collectionView.frame.size.width - self.itemSpacing) / self.columnCount;
        CGFloat height = width * self.aspectRatio;
        _itemSize = CGSizeMake(width, height);
    }
    return _itemSize;
}

@end