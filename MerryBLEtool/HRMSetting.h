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

#define BLE_Connected       0x10
#define StartActivity       0x20

#define UseNSUserDefaults

#define DebugMode

@protocol passUserSetting <NSObject>
-(void)setName : (NSString *)User_Name;
-(void)setAge : (NSString *)User_Age;
-(void)APPSetting : (NSInteger)Configdata;
-(void)passHeartRateData:(NSInteger)MaxHR SetMaxHR:(NSInteger)MaxHeartRate SetMinHR:(NSInteger)MinHeartRate RestHeartRate:(NSInteger)RHR UpperTargetHeartRate:(NSInteger)UpperTHR LowerTargetHeartRate:(NSInteger)LowerTHR;
@end

@interface HRMSetting : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *UserTHR1;
@property (weak, nonatomic) IBOutlet UITextField *UserMaxHR;
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
@property (nonatomic) NSInteger APPConfig;
//@property (nonatomic) unsigned int RestHR;
@property (nonatomic, assign) id <passUserSetting> delegate;
- (IBAction)APPModeChange:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *MaxHR;
- (IBAction)SaveData:(id)sender;
@property (nonatomic) NSInteger MaximumHR;
@property (nonatomic) NSInteger SetMaxHR;
@property (nonatomic) NSInteger SetMinHR;
@property (nonatomic) NSInteger UpperTHR;
@property (nonatomic) NSInteger LowerTHR;
@property (nonatomic) NSInteger SetRHR;
@property (nonatomic) NSInteger UserAgeValue;
- (IBAction)SaveHRData:(id)sender;
- (IBAction)LoadHRData:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *NormalMaxHR;
@property (weak, nonatomic) IBOutlet UILabel *NormalMinHR;
- (IBAction)MaxValueChanged:(id)sender;
- (IBAction)MinValueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISlider *SetNormalMaxHR;
@property (weak, nonatomic) IBOutlet UISlider *SetNormalMinHR;
@end
