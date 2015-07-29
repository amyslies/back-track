//
//  NMANewsStoryTableViewCell.m
//  NostalgiaMusic
//
//  Created by Sara Lieto on 7/6/15.
//  Copyright (c) 2015 Intrepid Pursuits. All rights reserved.
//

#import "NMANewsStoryTableViewCell.h"
#import "NMANewsStory.h"
#import "UIColor+NMAColors.h"
#import "UIFont+NMAFonts.h"

@implementation NMANewsStoryTableViewCell

static CGFloat const kShadowRadius = 4;
static CGFloat const kShadowOpacity = 0.7f;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.headlineLabel.font = [UIFont NMA_proximaNovaSemiBoldWithSize:20];
    self.bylineLabel.font = [UIFont NMA_proximaNovaRegularWithSize:13];
    self.bylineLabel.textColor = [UIColor NMA_warmGray];
    self.summaryTextLabel.font = [UIFont NMA_proximaNovaRegularWithSize:16];
    self.continueReadingButton.titleLabel.font = [UIFont NMA_proximaNovaRegularWithSize:13];
    self.continueReadingButton.titleLabel.textColor = [UIColor NMA_warmGray];
    self.dateLabel.font = [UIFont NMA_proximaNovaRegularWithSize:12];
}

- (void)configureCellForStory:(NMANewsStory *)story {
    self.story = story;
    if (story.headline) {
        self.headlineLabel.text = [story.headline capitalizedString];
    }
    if (story.byline) {
        self.bylineLabel.text = [story.byline uppercaseString];
    }
    if (story.snippet) {
        self.summaryTextLabel.text = story.snippet;
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.minimumLineHeight = 20.0f;
        style.maximumLineHeight = 20.0f;
        NSDictionary *attributtes = @{NSParagraphStyleAttributeName : style,};
        self.summaryTextLabel.attributedText = [[NSAttributedString alloc] initWithString:story.snippet
                                                                 attributes:attributtes];
        [self.summaryTextLabel sizeToFit];
        self.summaryTextLabel.font = [UIFont NMA_proximaNovaRegularWithSize:16];
    }
    [self configureDateLabel:story];
    self.continueReadingButton.titleLabel.text = @"Continue Reading in The New York Times";
    [self.continueReadingButton setShowsTouchWhenHighlighted:NO];
    
    if (shadow) {
        //Add a shadow to the bottom of the message view
        self.containerView.layer.masksToBounds = NO;
        self.containerView.layer.shadowColor = [UIColor NMA_darkGray].CGColor;
        self.containerView.layer.shadowRadius = kShadowRadius;
        self.containerView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        self.containerView.layer.shadowOpacity = kShadowOpacity;
    }
}

- (void)configureDateLabel:(NMANewsStory *)story {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMdd"];
    NSDate *storyDate = [dateFormatter dateFromString:story.date];
    [dateFormatter setDateFormat:@"LLLL dd"];
    NSString *displayDate = [dateFormatter  stringFromDate:storyDate];
    self.dateLabel.text = [displayDate uppercaseString];
}

- (IBAction)goToNewYorkTimes {
    NSString *url = [NSString stringWithFormat:@"%@", self.story.articleURL];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

- (IBAction)share:(UIButton *)sender {
    NSMutableArray *sharingItems = [NSMutableArray new];
    
    if (self.story.articleURL) {
        [sharingItems addObject:self.story.articleURL];
    }
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [self.delegate presentViewController:activityController animated:YES completion:nil];
}
@end
