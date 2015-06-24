//
//  NMALoginViewController.h
//  NostalgiaMusic
//
//  Created by Amy Ly on 6/23/15.
//  Copyright (c) 2015 Intrepid Pursuits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMAFacebookManager.h"

@interface NMALoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet FBSDKLoginButton *loginButtonView;
@property (weak, nonatomic) IBOutlet UIButton *skipFacebookLoginButton;

@end
