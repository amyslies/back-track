//
//  NMAYearScrollView.h
//  NostalgiaMusic
//
//  Created by Sara Lieto on 6/29/15.
//  Copyright (c) 2015 Intrepid Pursuits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMAYearActivityScrollDelegate.h"
@class NMAContentTableViewController;

@interface NMAYearActivityScrollViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) CABasicAnimation *rotation;
@property (copy, nonatomic) NSString *year;
@property (weak, nonatomic) id <NMAYearActivityScrollDelegate> delegate;

- (void)setUpScrollView:(NSString *)year;
//- (void)setUpPlayerForTableCell;
- (void)setUpPlayerForTableCellForYear:(NSString *)year;
- (void)startSpinning;
- (void)pauseSpinning;

@end
