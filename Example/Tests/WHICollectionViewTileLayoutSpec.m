//
// Created by Johnny Sparks on 11/12/14.
// Copyright (c) 2014 We Heart It. All rights reserved.
//

#import "WHICollectionViewTileLayout.h"
#import "Specta.h"

@interface WHICollectionViewTileLayout (Tests)

@property (nonatomic) NSUInteger columnCount;
@property (nonatomic) CGSize itemSize;
@property (nonatomic) NSUInteger topRow;
@property (nonatomic) NSUInteger bottomRow;
@property(nonatomic, strong) NSMutableDictionary *indexPathAttributeMap;

- (CGRect)frameForCellWithCoordinate:(WHICoordinate)coordinate andSpan:(WHISpan)span;
- (WHICoordinate)coordinatesAfterAddingSpan:(WHISpan)span;
- (void) fillTilesAtCoordinate:(WHICoordinate) coordinate withSpan:(WHISpan)span;
- (WHICoordinate)firstFittingCoordinatesForSpan:(WHISpan)span;
- (CGSize)sizeForCellWithSpan:(WHISpan)span;
- (CGPoint)originForCellWithCoordinate:(WHICoordinate)coordinate;

-(void) logRows:(NSUInteger)rows;

@end

SpecBegin(WHICollectionViewTileLayout)

fdescribe(@"WHICollectionViewTileLayout", ^{

    __block WHICollectionViewTileLayout *layout;
    __block UICollectionView *collectionView;

    beforeEach(^{
        layout = [[WHICollectionViewTileLayout alloc] init];
        layout.itemSize = CGSizeMake(100, 100);
    });

    context(@"New structs", ^{

        it(@"defines a new WHICoordinate struct with generator", ^{
            WHICoordinate coordinate = WHICoordinateMake(10, 24);
            expect(coordinate.col).to.equal(10);
            expect(coordinate.row).to.equal(24);
        });

        it(@"defines a new WHISpan struct that works just like WHICoordinate and WHICoordinateMake", ^{
            WHISpan span = WHISpanMake(10, 24);
            expect(span.col).to.equal(10);
            expect(span.row).to.equal(24);
        });

    });

    context(@"Flood Layout", ^{

        it(@"Never has a nil indexPathAttributeMap", ^{
            layout.indexPathAttributeMap = nil;
            expect(layout.indexPathAttributeMap).toNot.beNil;
        });

        it(@"Doesn't throw an exception when an valid number of cols is set", ^{
            layout.columnCount = 20;
            expect(layout.columnCount).to.equal(20);
        });

        context(@"Mapps a col/row span to a cell size based on the layout itemSize", ^{

            it(@"works for a single cell", ^{
                CGSize size = [layout sizeForCellWithSpan:WHISpanMake(1, 1)];
                expect(CGSizeEqualToSize(size, CGSizeMake(100, 100))).to.beTruthy;
            });

            it(@"works for a wide cell", ^{
                CGSize size = [layout sizeForCellWithSpan:WHISpanMake(7, 1)];
                expect(CGSizeEqualToSize(size, CGSizeMake(700, 100))).to.beTruthy;
            });

            it(@"works for a tall cell", ^{
                CGSize size = [layout sizeForCellWithSpan:WHISpanMake(2, 8)];
                expect(CGSizeEqualToSize(size, CGSizeMake(200, 800))).to.beTruthy;
            });

        });

        context(@"Mapps a col/row coordinate to a cell origin based on the layout itemSize", ^{

            it(@"the first cell should always be zero zero", ^{
                CGPoint point = [layout originForCellWithCoordinate:WHICoordinateMake(0, 0)];
                expect(CGPointEqualToPoint(point, CGPointMake(0, 0))).to.beTruthy;
            });

            it(@"works for a wide cell", ^{
                CGPoint point = [layout originForCellWithCoordinate:WHICoordinateMake(7, 1)];
                expect(CGPointEqualToPoint(point, CGPointMake(700, 100))).to.beTruthy;
            });

            it(@"works for a tall cell", ^{
                CGPoint point = [layout originForCellWithCoordinate:WHICoordinateMake(2, 8)];
                expect(CGPointEqualToPoint(point, CGPointMake(200, 800))).to.beTruthy;
            });

        });

        context(@"Fitting cells", ^{

            it(@"has a bottom row of 0 when no cells have been added", ^{
                layout.columnCount = 3;
                expect(layout.bottomRow).to.equal(0);
            });

            it(@"has a bottom row of 0 when a 1x1 cell is added", ^{
                WHISpan span = WHISpanMake(1, 1);
                layout.columnCount = 3;
                [layout coordinatesAfterAddingSpan:span];
                expect(layout.bottomRow).to.equal(0);
            });

            it(@"has a bottom row of 0 when a 1x1 cell is added", ^{
                WHISpan span = WHISpanMake(1, 1);
                layout.columnCount = 3;
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                expect(layout.bottomRow).to.equal(0);
            });

            it(@"has a bottom row of 1 when a 3x1 cell is added", ^{
                WHISpan span = WHISpanMake(3, 1);
                layout.columnCount = 3;
                [layout coordinatesAfterAddingSpan:span];
                expect(layout.bottomRow).to.equal(1);
            });

            it(@"has a bottom row index of 3 when 5 1x3 cells are added", ^{
                WHISpan span = WHISpanMake(1, 3);
                layout.columnCount = 3;
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                expect(layout.bottomRow).to.equal(3);
            });

            it(@"has a bottom row index of 5 when 5 3x1 cells are added", ^{
                WHISpan span = WHISpanMake(3, 1);
                layout.columnCount = 3;
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                expect(layout.bottomRow).to.equal(5);
            });

            it(@"has a bottom row of 2 when a 2 2x2 cells are added", ^{
                WHISpan span = WHISpanMake(2, 2);
                layout.columnCount = 4;
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                expect(layout.bottomRow).to.equal(2);
            });

            it(@"can handle larger layouts", ^{
                WHISpan span = WHISpanMake(5, 5);
                layout.columnCount = 15;
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                expect(layout.bottomRow).to.equal(5);
            });

            it(@"skips the bottom cell if it doesn't fit", ^{
                layout.columnCount = 10;
                [layout coordinatesAfterAddingSpan:WHISpanMake(9, 1)];
                [layout coordinatesAfterAddingSpan:WHISpanMake(10, 1)];
                [layout coordinatesAfterAddingSpan:WHISpanMake(9, 1)];
                [layout coordinatesAfterAddingSpan:WHISpanMake(10, 1)];
                expect(layout.bottomRow).to.equal(0);
                [layout coordinatesAfterAddingSpan:WHISpanMake(1, 1)];
                expect(layout.bottomRow).to.equal(2);
                [layout coordinatesAfterAddingSpan:WHISpanMake(1, 1)];
                expect(layout.bottomRow).to.equal(4);
            });
            it(@"starts with the left most empty col", ^{
                WHISpan one = WHISpanMake(1, 1);
                WHISpan two = WHISpanMake(2, 2);
                layout.columnCount = 4;
                [layout coordinatesAfterAddingSpan:one];
                [layout coordinatesAfterAddingSpan:two];
                [layout coordinatesAfterAddingSpan:one];
                expect(layout.bottomRow).to.equal(1);
            });

            it(@"makes a U", ^{
                WHISpan one = WHISpanMake(1, 1);
                WHISpan two = WHISpanMake(2, 2);
                WHISpan tall = WHISpanMake(1, 2);
                layout.columnCount = 4;
                [layout coordinatesAfterAddingSpan:one];
                [layout coordinatesAfterAddingSpan:two];
                [layout coordinatesAfterAddingSpan:one];
                [layout coordinatesAfterAddingSpan:tall];
                [layout coordinatesAfterAddingSpan:tall];
                expect(layout.bottomRow).to.equal(2);
            });

            it(@"skips the bottom cell if it doesn't fit", ^{
                WHISpan full = WHISpanMake(3, 3);
                WHISpan wide = WHISpanMake(3, 1);
                WHISpan tall = WHISpanMake(1, 2);
                WHISpan square = WHISpanMake(2, 2);
                layout.columnCount = 3;
                [layout coordinatesAfterAddingSpan:wide];
                [layout coordinatesAfterAddingSpan:full];
                [layout coordinatesAfterAddingSpan:tall];
                [layout coordinatesAfterAddingSpan:square];
                [layout coordinatesAfterAddingSpan:tall];
                expect(layout.bottomRow).to.equal(6);
            });
            it(@"backfills gaps", ^{
                layout.columnCount = 3;
                [layout coordinatesAfterAddingSpan:WHISpanMake(2, 2)];
                [layout coordinatesAfterAddingSpan:WHISpanMake(1, 3)];
                [layout coordinatesAfterAddingSpan:WHISpanMake(2, 2)];
                [layout coordinatesAfterAddingSpan:WHISpanMake(1, 1)];
                expect(layout.bottomRow).to.equal(4);
            });

            it(@"can fit cells on the bottom row", ^{
                WHISpan span = WHISpanMake(1, 1);
                WHICoordinate coordinate = [layout firstFittingCoordinatesForSpan:span];
                expect(coordinate.col).to.equal(0);
                expect(coordinate.row).to.equal(0);
            });

            it(@"can fit a cell on the bottom row after filling part of the row", ^{
                WHISpan span = WHISpanMake(1, 1);
                [layout coordinatesAfterAddingSpan:span];
                WHICoordinate coordinate = [layout firstFittingCoordinatesForSpan:span];
                expect(coordinate.col).to.equal(1);
                expect(coordinate.row).to.equal(0);
            });

            it(@"can fit 2x2 cell on the bottom row after filling part of the row, and fills in the rest", ^{
                WHISpan span = WHISpanMake(1, 1);
                WHISpan twoByTwo = WHISpanMake(2, 2);
                layout.columnCount = 3;
                WHICoordinate twoByTwoCoordinate = [layout coordinatesAfterAddingSpan:twoByTwo];
                WHICoordinate coordinate = [layout firstFittingCoordinatesForSpan:span];
                WHICoordinate twoByTwoCoordinateTwo = [layout coordinatesAfterAddingSpan:twoByTwo];
                expect(twoByTwoCoordinate.col).to.equal(0);
                expect(twoByTwoCoordinate.row).to.equal(0);
                expect(coordinate.col).to.equal(2);
                expect(coordinate.row).to.equal(0);
                expect(twoByTwoCoordinateTwo.col).to.equal(0);
                expect(twoByTwoCoordinateTwo.row).to.equal(2);
                coordinate = [layout coordinatesAfterAddingSpan:span];
                expect(coordinate.col).to.equal(2);
                expect(coordinate.row).to.equal(0);
                coordinate = [layout coordinatesAfterAddingSpan:span];
                expect(coordinate.col).to.equal(2);
                expect(coordinate.row).to.equal(1);
                coordinate = [layout coordinatesAfterAddingSpan:span];
                expect(coordinate.col).to.equal(2);
                expect(coordinate.row).to.equal(2);
            });

            it(@"Small cells fill in the gaps of larger ones", ^{
                layout.columnCount = 5;
                WHISpan span;
                // needs deterministic layout
                for(int idx=0; idx<100; idx++){
                    switch (idx % 4){
                        case 0: span = WHISpanMake(1,4); break;
                        case 1: span = WHISpanMake(3,3); break;
                        case 2: span = WHISpanMake(2,1); break;
                        case 3: span = WHISpanMake(1,5); break;
                        default:break;
                    }
                    [layout coordinatesAfterAddingSpan:span];
                }
                // fill in the little ones
                for(int idx=0; idx<300; idx++){
                    uint spanRow = 1;
                    uint spanCol = 1;
                    [layout coordinatesAfterAddingSpan:WHISpanMake(spanCol, spanRow)];
                }
                expect(layout.bottomRow).to.equal(160);
                expect(layout.topRow).to.equal(160);
            });

        });

        context(@"Placing cells in cols", ^{

            it(@"ads the first cell", ^{
                WHISpan span = WHISpanMake(1, 1);
                layout.columnCount = 3;
                WHICoordinate coordinate = [layout coordinatesAfterAddingSpan:span];
                expect(coordinate.col).to.equal(0);
                expect(coordinate.row).to.equal(0);
            });

            it(@"ads a cell", ^{
                WHISpan span = WHISpanMake(1, 1);
                layout.columnCount = 3;
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                WHICoordinate coordinate = [layout coordinatesAfterAddingSpan:span];
                expect(coordinate.col).to.equal(0);
                expect(coordinate.row).to.equal(2);
            });

            it(@"ads 2x2 cells", ^{
                WHISpan span = WHISpanMake(2, 2);
                layout.columnCount = 4;
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                WHICoordinate coordinate = [layout coordinatesAfterAddingSpan:span];
                expect(coordinate.col).to.equal(2);
                expect(coordinate.row).to.equal(6);
            });

            it(@"ads a wide cell", ^{
                WHISpan span = WHISpanMake(3, 1);
                layout.columnCount = 3;
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                WHICoordinate coordinate = [layout coordinatesAfterAddingSpan:span];
                expect(coordinate.col).to.equal(0);
                expect(coordinate.row).to.equal(3);
            });

            it(@"ads a tall cell", ^{
                WHISpan span = WHISpanMake(1, 3);
                layout.columnCount = 3;
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                [layout coordinatesAfterAddingSpan:span];
                WHICoordinate coordinate = [layout coordinatesAfterAddingSpan:span];
                expect(coordinate.col).to.equal(0);
                expect(coordinate.row).to.equal(3);
            });
        });

        context(@"calculating frames", ^{

            beforeEach(^{
                layout.columnCount = 5;
                layout.itemSpacing = 0;
                layout.aspectRatio = 1;
                collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,500,1000) collectionViewLayout:layout];
            });

            it(@"calculates the frame of", ^{
                WHISpan span;
                WHICoordinate coordinate;
                CGRect calculated;
                CGRect expected;
                coordinate = WHICoordinateMake(3, 3);
                span = WHISpanMake(1, 1);
                calculated = [layout frameForCellWithCoordinate:coordinate andSpan:span];
                expected = CGRectMake(300, 300, 100, 100);
                expect(CGRectEqualToRect(calculated, expected)).to.beTruthy;
                coordinate = WHICoordinateMake(3, 2);
                span = WHISpanMake(5, 1);
                calculated = [layout frameForCellWithCoordinate:coordinate andSpan:span];
                expected = CGRectMake(300, 200, 500, 100);
                expect(CGRectEqualToRect(calculated, expected)).to.beTruthy;
                coordinate = WHICoordinateMake(3, 65);
                span = WHISpanMake(2, 3);
                calculated = [layout frameForCellWithCoordinate:coordinate andSpan:span];
                expected = CGRectMake(300, 6500, 200, 300);
                expect(CGRectEqualToRect(calculated, expected)).to.beTruthy;
            });

            it(@"calculates frames with margins", ^{
                WHISpan span;
                WHICoordinate coordinate;
                CGRect calculated;
                CGRect expected;
                layout.itemSpacing = 10;
                coordinate = WHICoordinateMake(3, 3);
                span = WHISpanMake(1, 1);
                calculated = [layout frameForCellWithCoordinate:coordinate andSpan:span];
                expected = CGRectMake(310, 310, 90, 90);
                expect(CGRectEqualToRect(calculated, expected)).to.beTruthy;
                coordinate = WHICoordinateMake(3, 2);
                span = WHISpanMake(5, 1);
                calculated = [layout frameForCellWithCoordinate:coordinate andSpan:span];
                expected = CGRectMake(310, 210, 490, 90);
                expect(CGRectEqualToRect(calculated, expected)).to.beTruthy;
                coordinate = WHICoordinateMake(3, 65);
                span = WHISpanMake(2, 3);
                calculated = [layout frameForCellWithCoordinate:coordinate andSpan:span];
                expected = CGRectMake(310, 6510, 190, 290);
                expect(CGRectEqualToRect(calculated, expected)).to.beTruthy;
            });

        });

    });
});


SpecEnd