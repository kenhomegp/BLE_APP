//
//  HRMSetting.h
//  MerryBLEtool
//
//  Created by merry on 14-9-24.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TargetZoneAlarm     0x01
#define HRNotification      0x02
#define ApplicationMode     0x0C

#define Normal              0x04
#define Sports              0x08
#define Sleep               0x0C

#define UseNSUserDefaults

@protocol passUserSetting <NSObject>
-(void)setName : (NSString *)User_Name;
-(void)setAge : (NSString *)User_Age;
-(void)APPSetting : (int)Configdata;
-(void)passHeartRateData:(int)MaxHR SetMaxHR:(int)MaxHeartRate SetMinHR:(int)MinHeartRate RestHeartRate:(int)RHR UpperTargetHeartRate:(int)UpperTHR LowerTargetHeartRate:(int)LowerTHR;
@end

@interface HRMSetting : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *UserName;
@property (weak, nonatomic) IBOutlet UITextField *UserAge;
- (IBAction)backgroundTap:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *UserRHR;
@property (weak, nonatomic) IBOutlet UILabel *UserTHR;
@property (weak, nonatomic) IBOutlet UISwitch *AlarmTHR;
@property (weak, nonatomic) IBOutlet UISegmentedControl *APPModeSelect;
@property (weak, nonatomic) IBOutlet UISwitch *HRNotifiction;
@property (strong, nonatomic) NSString *HR_UserName;
@property (strong, nonatomic) NSString *HR_UserAge;
@property (nonatomic) unsigned int APPConfig;
@property (nonatomic, assign) id <passUserSetting> delegate;
- (IBAction)APPModeChange:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *MaxHR;
- (IBAction)SaveData:(id)sender;
@property (assign) int MaximumHR;
@property (assign) int SetMaxHR;
@property (assign) int SetMinHR;
@property (assign) int UpperTHR;
@property (assign) int LowerTHR;
@property (assign) int SetRHR;
- (IBAction)SaveHRData:(id)sender;
- (IBAction)LoadHRData:(id)sender;
@end
