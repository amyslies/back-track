//
//  NMAYearCollectionViewController.m
//  NostalgiaMusic
//
//  Created by Sara Lieto on 6/25/15.
//  Copyright (c) 2015 Intrepid Pursuits. All rights reserved.
//

#import "NMAYearCollectionViewController.h"
#import "NMAYearCollectionViewCell.h"
#import "NMASelectedYearCollectionViewCell.h"
#import <QuartzCore/CALayer.h>

static NSInteger const earliestYear = 1981;
static NSString * const kNMAYearCollectionCellIdentifier = @"NMAYearCollectionCell";
static NSInteger const kNumberOfSectionsInYearCollection = 1;
static NSString * const kNMASelectedYearcollectionViewCellIdentifier = @"NMASelectedYearCollectionViewCell";

@interface NMAYearCollectionViewController ()

@property (strong, nonatomic) NSMutableArray *years;
@property (nonatomic) NSInteger latestYear;

@end

@implementation NMAYearCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollBarCollectionView.delegate = self;
    self.scrollBarCollectionView.dataSource = self;
    self.scrollBarCollectionView.clipsToBounds = YES;
    [self.scrollBarCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([NMAYearCollectionViewCell class]) bundle:nil]
forCellWithReuseIdentifier:kNMAYearCollectionCellIdentifier];
    [self.scrollBarCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([NMASelectedYearCollectionViewCell class]) bundle:nil]
          forCellWithReuseIdentifier:kNMASelectedYearcollectionViewCellIdentifier];
    self.view.backgroundColor = [UIColor colorWithRed:133/255 green:222/255 blue:218/255 alpha:1];
    [self getLatestYear];
    [self setUpCollectionViewWithLayout];
    [self setUpYears];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSInteger test = [self.year integerValue];
    NSInteger yearIndexPath = test - earliestYear;
    if (self.year) {
        NSIndexPath *defaultYear = [NSIndexPath indexPathForItem:yearIndexPath inSection:0];
        [self.scrollBarCollectionView scrollToItemAtIndexPath:defaultYear atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    } else {
        [self.scrollBarCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.years.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
}

- (void)setUpCollectionViewWithLayout {
    self.flowLayout = [[UICollectionViewFlowLayout alloc]init];
    [self.flowLayout setSectionInset:UIEdgeInsetsMake(0, self.scrollBarCollectionView.frame.size.width / 2, 0, self.scrollBarCollectionView.frame.size.width/ 2)];
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.scrollBarCollectionView.backgroundColor = [UIColor whiteColor];
    [self.scrollBarCollectionView setCollectionViewLayout:self.flowLayout];
}

- (void)setUpYears {
    self.years = [[NSMutableArray alloc] init];
    for ( int i = 0; i < (self.latestYear - earliestYear + 1); i++ ){
        NSString *yearForCell = [NSString stringWithFormat:@"%li", (long)(earliestYear + i)];
        [self.years addObject:yearForCell];
    }
}

#pragma mark UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return kNumberOfSectionsInYearCollection;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.years.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(111, 42);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *year = self.years[indexPath.row];
    if ([year isEqualToString:self.year] || ([year isEqualToString:[NSString stringWithFormat:@"%i", self.latestYear]] && self.year == nil)) {
        NMASelectedYearCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kNMASelectedYearcollectionViewCellIdentifier forIndexPath:indexPath];
        cell.yearLabel.text = year;
        [cell.yearLabel.layer masksToBounds];
        cell.yearLabel.layer.cornerRadius = 20;
        cell.yearLabel.clipsToBounds = YES;
        cell.dateLabel.text = [self getDate];
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    } else {
        NMAYearCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kNMAYearCollectionCellIdentifier forIndexPath:indexPath];
        cell.backgroundColor = [UIColor whiteColor];
        cell.year.text = year;
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *currentYear = [self.years objectAtIndex:indexPath.row];
    self.year = currentYear;
    [self.delegate didSelectYear:currentYear];
}

- (void)moveToYear:(NSString *)year {
    if ([year integerValue] < 2015 && [year integerValue] > 1980) {
    self.year = year;
    NSInteger indexYear = [self.years indexOfObject:year];
    NSIndexPath *defaultYear = [NSIndexPath indexPathForItem:indexYear inSection:0];
    [self.scrollBarCollectionView scrollToItemAtIndexPath:defaultYear atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}

- (void)positionYear {
    NSInteger test = [self.year integerValue];
    NSInteger yearIndexPath = test - earliestYear;
    if (self.year) {
        NSIndexPath *defaultYear = [NSIndexPath indexPathForItem:yearIndexPath inSection:0];
        [self.scrollBarCollectionView scrollToItemAtIndexPath:defaultYear atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    } else {
        [self.scrollBarCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.years.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}

#pragma mark - Getters and Setters

- (void) getLatestYear {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *currentYear = [dateFormatter stringFromDate:[NSDate date]];
    NSInteger pastyear = [currentYear integerValue] - 1;
    self.latestYear = pastyear;
}

- (NSString *)getDate {
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"MMdd"];
    NSString *currentDate = [DateFormatter  stringFromDate:[NSDate date]];
    return currentDate;
}

- (void)setYear:(NSString *)year {
    _year = year;
    [self.scrollBarCollectionView reloadData];
    [self positionYear];
}
@end
