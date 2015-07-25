//
//  NMAYearScrollView.m
//  NostalgiaMusic
//
//  Created by Sara Lieto on 6/29/15.
//  Copyright (c) 2015 Intrepid Pursuits. All rights reserved.
//

#import "NMAYearActivityScrollViewController.h"
#import "NMAContentTableViewController.h"
#import "NMAAppSettings.h"
#import "NMAPlaybackManager.h"
#import "NMARequestManager.h"

typedef NS_ENUM(NSUInteger, NMAScrollViewYearPosition) {
    NMAScrollViewPositionPastYear = 0,
    NMAScrollViewPositionCurrentYear,
    NMAScrollViewPositionNextYear,
};

BOOL isEarliestYearVisble;
BOOL isMostRecentYearVisible;

@interface NMAYearActivityScrollViewController ()

@property (strong, nonatomic) NMAContentTableViewController *leftTableViewController;
@property (strong, nonatomic) NMAContentTableViewController *middleTableViewController;
@property (strong, nonatomic) NMAContentTableViewController *rightTableViewController;
@property (copy, nonatomic) NSString *earliestYear;
@property (copy, nonatomic) NSString *latestYear;
@property (nonatomic) float swipeContentOffset;
@property (strong, nonatomic) CABasicAnimation *rotation;


@end


@implementation NMAYearActivityScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.earliestYear = @"1981";
    [self getLatestYear];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    [self.view addSubview:self.scrollView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidResumeAVPlayer:)
                                                 name:@"resumeAVPlayerNotification"
                                               object:[NMAPlaybackManager sharedPlayer]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidPauseAVPlayer:)
                                                 name:@"pauseAVPlayerNotification"
                                               object:[NMAPlaybackManager sharedPlayer]];
}

#pragma mark - KVO Notification Handling

- (void)userDidResumeAVPlayer:(NSNotification *)notification {
    [self resumeAnimationLayer];
}

- (void)userDidPauseAVPlayer:(NSNotification *)notification {
    [self pauseAnimationLayer];
}

#pragma mark - Scroll View set up

- (void)setUpScrollView:(NSString *)year {
    isEarliestYearVisble = NO;
    isMostRecentYearVisible = NO;
    NSInteger numberOfViews = 3;
    self.year = year;

    if ([self.year isEqualToString:self.earliestYear]) {
        self.year = [self incrementStringValue:self.earliestYear];
        isEarliestYearVisble = YES;
        CGPoint scrollPoint = CGPointMake(0, 0);
        [self.scrollView setContentOffset:scrollPoint animated:NO];
    } else if ([self.year isEqualToString:self.latestYear]) {
        self.year = [self decrementStringValue:self.latestYear];
        isMostRecentYearVisible = YES;
        CGPoint scrollPoint = CGPointMake(self.view.frame.size.width * 2, 0);
        [self.scrollView setContentOffset:scrollPoint animated:NO];
    } else {
        [self setContentOffsetToCenter];
    }

    [self destroyViewController:self.leftTableViewController];
    [self destroyViewController:self.middleTableViewController];
    [self destroyViewController:self.rightTableViewController];

    self.leftTableViewController = [[NMAContentTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self configureNMAContentTableViewController:self.leftTableViewController
                                        withYear:[self decrementStringValue:self.year]
                                      atPosition:NMAScrollViewPositionPastYear];

    self.middleTableViewController = [[NMAContentTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self configureNMAContentTableViewController:self.middleTableViewController
                                        withYear:self.year
                                      atPosition:NMAScrollViewPositionCurrentYear];

    self.rightTableViewController = [[NMAContentTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self configureNMAContentTableViewController:self.rightTableViewController
                                        withYear:[self incrementStringValue:self.year]
                                      atPosition:NMAScrollViewPositionNextYear];

    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width * numberOfViews, self.view.frame.size.height);

    [self setUpPlayerForTableCell];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (!self.leftTableViewController) {
        [self setUpScrollView:self.latestYear];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.swipeContentOffset = self.scrollView.contentOffset.x;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollingDidEnd];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self scrollingDidEnd];
    }
}

- (void)scrollingDidEnd {
    if (isEarliestYearVisble) {
      self.scrollView.contentOffset.x == CGRectGetWidth(self.view.frame) * 1 ? [self didSwipeToNextYear] : [self didSwipeToPastYear];
    } else if (fabsf(self.swipeContentOffset - self.scrollView.contentOffset.x) == self.middleTableViewController.view.frame.size.width) {
      self.scrollView.contentOffset.x == CGRectGetWidth(self.view.frame) * 2 ? [self didSwipeToNextYear] : [self didSwipeToPastYear];
    }
}

- (void)setContentOffsetToCenter {
    CGPoint scrollPoint = CGPointMake(CGRectGetWidth(self.view.frame), 0);
    [self.scrollView setContentOffset:scrollPoint animated:NO];
}

- (void)didSwipeToPastYear {
    if ([self.leftTableViewController.year isEqualToString:self.earliestYear]) {
        isEarliestYearVisble = YES;
        [self.delegate updateScrollYear:[self decrementStringValue:self.year]];
    } else if ([self.middleTableViewController.year isEqualToString:[self decrementStringValue:self.latestYear]] && isMostRecentYearVisible) {
        isMostRecentYearVisible = NO;
        [self.delegate updateScrollYear:self.year];
    } else {
        [self updatePositioningForScrollPosition:NMAScrollViewPositionPastYear];
    }
    [[self visibleAlbumImageViewLayer] removeAllAnimations];
    [self setUpPlayerForTableCell];

}

- (void)didSwipeToNextYear {
    if ([self.rightTableViewController.year isEqualToString:self.latestYear]) {
        isMostRecentYearVisible = YES;
        [self.delegate updateScrollYear:[self incrementStringValue:self.year]];
    } else if ([self.leftTableViewController.year isEqualToString:self.earliestYear ] && isEarliestYearVisble) {
        isEarliestYearVisble = NO;
        [self.delegate updateScrollYear:self.year];
    } else {
        [self updatePositioningForScrollPosition:NMAScrollViewPositionNextYear];
    }
    [[self visibleAlbumImageViewLayer] removeAllAnimations];
    [self setUpPlayerForTableCell];
}

- (void)updatePositioningForScrollPosition:(NMAScrollViewYearPosition)position {
    isEarliestYearVisble = NO;
    isMostRecentYearVisible = NO;

    if (position == NMAScrollViewPositionNextYear) {
        [self destroyViewController:self.leftTableViewController];
        self.leftTableViewController = self.middleTableViewController;
        self.middleTableViewController = self.rightTableViewController;
        NMAContentTableViewController *newYear = [[NMAContentTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self configureNMAContentTableViewController:newYear
                                            withYear:[self incrementStringValue:self.middleTableViewController.year]
                                          atPosition:NMAScrollViewPositionNextYear];
        self.rightTableViewController = newYear;
        self.year = self.middleTableViewController.year;
    } else {
        [self destroyViewController:self.rightTableViewController];
        self.rightTableViewController = self.middleTableViewController;
        self.middleTableViewController = self.leftTableViewController;
        NMAContentTableViewController *newYear = [[NMAContentTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self configureNMAContentTableViewController:newYear
                                            withYear:[self decrementStringValue:self.middleTableViewController.year]
                                          atPosition:NMAScrollViewPositionPastYear];
        self.leftTableViewController = newYear;
        self.year = self.middleTableViewController.year;
    }
    [self.delegate updateScrollYear:self.year];
    [self adjustFrameView];
    [self setContentOffsetToCenter];
}

- (void)destroyViewController:(NMAContentTableViewController *)tableView {
    [tableView.view removeFromSuperview];
    [tableView removeFromParentViewController];
}

- (void)adjustFrameView {
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    self.leftTableViewController.view.frame = CGRectMake(0, 0, width, height);
    self.middleTableViewController.view.frame = CGRectMake(width, 0, width, height);
    self.rightTableViewController.view.frame = CGRectMake(width * 2, 0, width, height);
}

- (void)configureNMAContentTableViewController:(NMAContentTableViewController *)viewController
                                      withYear:(NSString *)year
                                    atPosition:(NMAScrollViewYearPosition)position {
    CGFloat origin = position * self.view.frame.size.width;
    viewController.year = year;
    [viewController.view setFrame:CGRectMake(origin, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
    [self.scrollView addSubview:viewController.view];
    [self addChildViewController:viewController];
}

#pragma mark - Year Mutator Methods

- (NSString *)incrementStringValue:(NSString *)value {
    NSInteger nextyear = [value integerValue] + 1;
    return [NSString stringWithFormat:@"%li", (long)nextyear];
}

- (NSString *)decrementStringValue:(NSString *)value {
    NSInteger pastyear = [value integerValue] - 1;
    return [NSString stringWithFormat:@"%li", (long)pastyear];
}

#pragma mark - Year Getter Methods

- (void)getLatestYear {
    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"yyyy"];
    NSString *currentYear = [DateFormatter  stringFromDate:[NSDate date]];
    NSInteger pastyear = [currentYear integerValue] - 1;
    NSString *pastYearString = [NSString stringWithFormat:@"%li", (long)pastyear];
    self.latestYear = pastYearString;
}

- (NSString *)visibleYear {
    if (isMostRecentYearVisible) {
        return self.latestYear;
    } else if (isEarliestYearVisble) {
        return self.earliestYear;
    } else {
        return self.year;
    }
}

- (NMAContentTableViewController *)visibleContentTableVC {
    for (NMAContentTableViewController *tableVC in self.childViewControllers) {
        NSString *visibleYear = [self visibleYear];
        if ([tableVC.year isEqualToString:visibleYear]) {
            return tableVC;
        }
    }
    return nil;
}

- (NMATodaysSongTableViewCell *)visibleSongCell {
    return (NMATodaysSongTableViewCell *)[[self visibleContentTableVC].tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (CALayer *)visibleAlbumImageViewLayer {
    return [self visibleSongCell].albumImageView.layer;
}

- (void)setUpPlayerForTableCell {
    [[NMAPlaybackManager sharedPlayer] pausePlaying];
    [[NMARequestManager sharedManager] getSongFromYear:[self visibleYear]
                                               success:^(NMASong *song) {
                                                   [[self visibleContentTableVC].billboardSongs removeAllObjects];
                                                   [[self visibleContentTableVC].billboardSongs addObject:song];
                                                   [[self visibleContentTableVC].tableView reloadData];
                                                   [[NMAPlaybackManager sharedPlayer] setUpAVPlayerWithURL:[NSURL URLWithString:song.previewURL]];
                                                   [[NSNotificationCenter defaultCenter] addObserver:self
                                                                                            selector:@selector(audioDidFinishPlaying:)
                                                                                                name:AVPlayerItemDidPlayToEndTimeNotification
                                                                                              object:[NMAPlaybackManager sharedPlayer].audioPlayerItem];
                                                   [self makeAnimation];
                                                   [self resumeAnimationLayer];
                                               }
                                               failure:^(NSError *error) {}];
}


#pragma mark - Animation Methods

- (void)pauseAnimationLayer {
    CALayer *layer = [self visibleAlbumImageViewLayer];
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

- (void)resumeAnimationLayer {
    if ([self visibleAlbumImageViewLayer]) {
        if ([[NMAAppSettings sharedSettings] userDidAutoplay])  {
            if (![NMAPlaybackManager sharedPlayer].audioPlayer.rate) {
                [[NMAPlaybackManager sharedPlayer] startPlaying];
                return;
            }
        }
        if (![self visibleAlbumImageViewLayer].animationKeys) {
            if ([NMAPlaybackManager sharedPlayer].audioPlayer.rate) {
                [[self visibleAlbumImageViewLayer] addAnimation:self.rotation forKey:@"rotationAnimation"];
            }
        } else {
            CALayer *layer = [self visibleAlbumImageViewLayer];
            CFTimeInterval startTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
            CFTimeInterval pausedTime = [layer timeOffset];
            layer.speed = 1.0;
            layer.timeOffset = 0.0;
            layer.beginTime = 0.0;
            CFTimeInterval timeSincePause = startTime - pausedTime;
            layer.beginTime = timeSincePause;
        }
    }
}

- (void)makeAnimation {
    self.rotation = [[CABasicAnimation alloc] init];
    self.rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    self.rotation.toValue = [NSNumber numberWithFloat:M_PI*2];
    self.rotation.duration = 10;
    self.rotation.cumulative = YES;
    self.rotation.repeatCount = HUGE_VALF;
    self.rotation.removedOnCompletion = NO;
    self.rotation.fillMode = kCAFillModeForwards;
}

#pragma mark - Song End Notification Handler

- (void)audioDidFinishPlaying:(NSNotification *)notification {
    [[self visibleSongCell] changePlayButtonImageToPlay];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioDidFinishPlaying:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[NMAPlaybackManager sharedPlayer].audioPlayerItem];
}

@end
