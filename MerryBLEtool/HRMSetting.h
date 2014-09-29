//
//  HRMSetting.h
//  MerryBLEtool
//
//  Created by merry on 14-9-24.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol passUserSetting <NSObject>
-(void)setName : (NSString *)User_Name;
-(void)setAge : (NSString *)User_Age;
-(void)APPSetting : (int)Configdata;
@end

@interface HRMSetting : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *UserName;
@property (weak, nonatomic) IBOutlet UITextField *UserAge;
- (IBAction)backgroundTap:(id)sender;
@property (strong, nonatomic) NSString *HR_UserName;
@property (strong, nonatomic) NSString *HR_UserAge;
@property (nonatomic) unsigned int APPConfig;
@property (nonatomic, assign) id <passUserSetting> delegate;
- (IBAction)SaveData:(id)sender;
@end
