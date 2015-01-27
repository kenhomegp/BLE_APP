//
//  HRMTableSetting.h
//  MyHRM
//
//  Created by merry on 14-11-17.
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
#define SaveDataToFile
#define SaveLocationToFilex
#define NSFileHandleReadWrite
#define GradientPolyline
#define DebugWithoutBLEConnectionx
#define DebugWithoutTrackPathx
#define BLE_Debugx                  //Only for iPad
#define CustomBLEService            //Button , LED
#define FacebookSDK

@protocol passUserSetting1 <NSObject>
-(void)setName : (NSString *)User_Name;
-(void)setAge : (NSString *)User_Age;
-(void)APPSetting : (NSInteger)Configdata;
-(void)passHeartRateData:(NSInteger)MaxHR SetMaxHR:(NSInteger)MaxHeartRate SetMinHR:(NSInteger)MinHeartRate RestHeartRate:(NSInteger)RHR UpperTargetHeartRate:(NSInteger)UpperTHR LowerTargetHeartRate:(NSInteger)LowerTHR;
@end

@interface HRMTableSetting : UITableViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *UserName;
@property (weak, nonatomic) IBOutlet UITextField *UserAge;
@property (weak, nonatomic) IBOutlet UITextField *UserMaxHR;
@property (weak, nonatomic) IBOutlet UITextField *UserRHR;
@property (weak, nonatomic) IBOutlet UITextField *UserTHR1;
@property (weak, nonatomic) IBOutlet UISwitch *AlarmTHR;
@property (weak, nonatomic) IBOutlet UISlider *SetNormalMaxHR;
@property (weak, nonatomic) IBOutlet UILabel *NormalMaxHR;
@property (weak, nonatomic) IBOutlet UISlider *SetNormalMinHR;
@property (weak, nonatomic) IBOutlet UILabel *NormalMinHR;
@property (weak, nonatomic) IBOutlet UISwitch *HRNotify;
@property (weak, nonatomic) IBOutlet UISegmentedControl *APPModeSelect;
@property (weak, nonatomic) IBOutlet UIButton *LoginButton;
- (IBAction)SaveHRData:(id)sender;
- (IBAction)MaxValueChanged:(id)sender;
- (IBAction)MinValueChanged:(id)sender;
- (IBAction)APPModeChange:(id)sender;
- (IBAction)backgroundTap:(id)sender;
@property (strong, nonatomic) NSString *HR_UserName;
@property (strong, nonatomic) NSString *HR_UserAge;
@property (nonatomic) NSInteger APPConfig;
@property (nonatomic) NSInteger MaximumHR;
@property (nonatomic) NSInteger SetMaxHR;
@property (nonatomic) NSInteger SetMinHR;
@property (nonatomic) NSInteger UpperTHR;
@property (nonatomic) NSInteger LowerTHR;
@property (nonatomic) NSInteger SetRHR;
@property (nonatomic) NSInteger UserAgeValue;
@property (nonatomic, assign) id <passUserSetting1> delegate;
@property (weak, nonatomic) IBOutlet UILabel *Version;
@property (nonatomic , strong) NSString *Log;
@property (weak, nonatomic) IBOutlet UITextView *BLE_Log;
@property (weak, nonatomic) IBOutlet UISwitch *Control_LED;
@property (weak, nonatomic) IBOutlet UISwitch *Control_Button;
@end
