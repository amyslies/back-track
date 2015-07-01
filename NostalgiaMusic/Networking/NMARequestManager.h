//
//  NMARequestManager.h
//  NostalgiaMusic
//
//  Created by Amy Ly on 7/1/15.
//  Copyright (c) 2015 Intrepid Pursuits. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NMABillBoardSong.h"

@interface NMARequestManager : NSObject

+ (instancetype)sharedManager;

- (void)getBillBoardSongFromYear:(NSString *)year
                         success:(void (^)(NMABillBoardSong *song))success
                         failure:(void (^)(NSError *error))failure;

@end
