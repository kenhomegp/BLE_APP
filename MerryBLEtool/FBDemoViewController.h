//
//  FBDemoViewController.h
//  MyHRM
//
//  Created by 黃銘隆 on 2015/1/27.
//  Copyright (c) 2015年 merry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FBDemoViewController : UIViewController <FBLoginViewDelegate , UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblLoginStatus;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *lblUsername;
@property (weak, nonatomic) IBOutlet UILabel *lblEmail;
@property (weak, nonatomic) IBOutlet FBLoginView *loginButton;
-(void)toggleHiddenState:(BOOL)shouldHide;
@end
