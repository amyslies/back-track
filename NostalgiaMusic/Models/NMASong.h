//
//  NMABillBoardSong.h
//  NostalgiaMusic
//
//  Created by Amy Ly on 7/1/15.
//  Copyright (c) 2015 Intrepid Pursuits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NMASong : NSObject

@property (strong, nonatomic) NSString *yearPeaked;
@property (strong, nonatomic) NSString *yearlyRank;
@property (strong, nonatomic) NSString *artistAsAppearsOnLabel;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray *albumImageUrlsArray;
@property (strong, nonatomic) NSString *previewURL;

@end