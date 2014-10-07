//
//  HRMSetting.m
//  MerryBLEtool
//
//  Created by merry on 14-9-24.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import "HRMSetting.h"
#import "HRMViewController.h"

@interface HRMSetting ()

@end

@implementation HRMSetting

@synthesize UserName;
@synthesize UserAge;
@synthesize APPConfig;

- (void)SaveUserData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.HR_UserName forKey:@"myHRMApp_Name"];
    [userDefaults setObject:self.HR_UserAge forKey:@"myHRMApp_Age"];
    //[userDefaults setInteger:[self.HR_UserAge intValue] forKey:@"myHRMApp_Age"];
    [userDefaults setInteger:self.MaximumHR forKey:@"myHRMApp_MaxHR"];
    [userDefaults setInteger:self.SetRHR forKey:@"myHRMApp_RHR"];
    [userDefaults setInteger:self.UpperTHR forKey:@"myHRMApp_UpperTHR"];
    [userDefaults setInteger:self.LowerTHR forKey:@"myHRMApp_LowerTHR"];
    [userDefaults setInteger:self.SetMaxHR forKey:@"myHRMApp_SetMaxHR"];
    [userDefaults setInteger:self.SetMinHR forKey:@"myHRMApp_SetMinHR"];
    [userDefaults setInteger:self.APPConfig forKey:@"myHRMApp_APPConfig"];
    
    [userDefaults synchronize];
    
    NSLog(@"SaveUserData");
}

- (void)LoadUserData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.HR_UserName = [userDefaults objectForKey:@"myHRMApp_Name"];
    self.HR_UserAge = [userDefaults objectForKey:@"myHRMApp_Age"];
    //int i = [userDefaults integerForKey:@"myHRMApp_Age"];
    //self.HR_UserAge = [NSString stringWithFormat:@"%d",i];
    self.MaximumHR = [userDefaults integerForKey:@"myHRMApp_MaxHR"];
    self.SetRHR = [userDefaults integerForKey:@"myHRMApp_RHR"];
    self.UpperTHR = [userDefaults integerForKey:@"myHRMApp_UpperTHR"];
    self.LowerTHR = [userDefaults integerForKey:@"myHRMApp_LowerTHR"];
    self.SetMaxHR = [userDefaults integerForKey:@"myHRMApp_SetMaxHR"];
    self.SetMinHR = [userDefaults integerForKey:@"myHRMApp_SetMinHR"];
    self.APPConfig = [userDefaults integerForKey:@"myHRMApp_APPConfig"];
    
    self.UserRHR.text = [NSString stringWithFormat:@"%d",self.SetRHR];
    [self CalculateHRData];
    
    //NSLog(@"LoadUserData , i = %d",[self.HR_UserAge intValue]);
    
    UserName.text = self.HR_UserName;
    
    UserAge.text = self.HR_UserAge;
    
    NSLog(@"LoadUserData");
}

- (void) CalculateHRData
{
    _HR_UserAge = UserAge.text;
    
    if(!([self.HR_UserAge isEqualToString:@""]))
    {
        int tempMaxHR,tempRHR,tempUpperTHR,tempLowerTHR,tempHRReserve = 0;
        
        tempMaxHR = 220 - ([self.HR_UserAge intValue]);
        self.MaximumHR = tempMaxHR;
        
        self.MaxHR.text = [NSString stringWithFormat:@"Maximum Heart Rate = %d",tempMaxHR];
        
        if(!([self.UserRHR.text isEqualToString:@""]))
        {
            tempRHR = [self.UserRHR.text intValue];
            
            if((tempRHR > 0) && (tempRHR < 90))
            {
                self.SetRHR = tempRHR;
                tempHRReserve = tempMaxHR - tempRHR;
                tempUpperTHR = (tempHRReserve * 0.8) + tempRHR;
                tempLowerTHR = (tempHRReserve * 0.6) + tempRHR;
                self.UpperTHR = tempUpperTHR;
                self.LowerTHR = tempLowerTHR;
                self.UserTHR.text = [NSString stringWithFormat:@"Target Heart Rate : %d ~ %d",tempLowerTHR , tempUpperTHR];
                
            }
        }
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(!([self.HR_UserName isEqualToString:@""]))
        UserName.text = self.HR_UserName;
    
    if(!([self.HR_UserAge isEqualToString:@""]))
        UserAge.text = self.HR_UserAge;
    
    if((self.APPConfig & TargetZoneAlarm))
        [self.AlarmTHR setOn:YES];
    else
        [self.AlarmTHR setOn:NO];
    
    if((self.APPConfig & HRNotification))
        [self.HRNotifiction setOn:YES];
    else
        [self.HRNotifiction setOn:NO];
    
    //NSLog(@"APP Config = %d",self.APPConfig);
    
    switch(self.APPConfig & ApplicationMode)
    {
        case (Normal):
            self.APPModeSelect.selectedSegmentIndex = 0;
            break;
        case (Sports):
            self.APPModeSelect.selectedSegmentIndex = 1;
            break;
        case (Sleep):
            self.APPModeSelect.selectedSegmentIndex = 2;
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backgroundTap:(id)sender
{
    [self.view endEditing:YES];
    
    [self CalculateHRData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)SaveData:(id)sender {
    
    _HR_UserName = UserName.text;
    [[self delegate] setName:_HR_UserName];
    
    _HR_UserAge = UserAge.text;
    [[self delegate] setAge:_HR_UserAge];
    
    if(self.AlarmTHR.isOn)
        self.APPConfig |= TargetZoneAlarm;
    else
        self.APPConfig &= ~(TargetZoneAlarm);
    
    if(self.HRNotifiction.isOn)
        self.APPConfig |= HRNotification;
    else
        self.APPConfig &= ~(HRNotification);
    
    [[self delegate] APPSetting:self.APPConfig];
    
    [self CalculateHRData];
    [[self delegate] passHeartRateData:self.MaximumHR SetMaxHR:self.SetMaxHR SetMinHR:self.SetMinHR RestHeartRate:self.SetRHR UpperTargetHeartRate:self.UpperTHR LowerTargetHeartRate:self.LowerTHR];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)APPModeChange:(id)sender {
    switch([sender selectedSegmentIndex])
    {
        case 0:
            //NSLog(@"Normal mode");
            self.APPConfig &= ~(ApplicationMode);
            self.APPConfig |= Normal;
            break;
        case 1:
            //NSLog(@"Sports mode");
            self.APPConfig &= ~(ApplicationMode);
            self.APPConfig |= Sports;
            break;
        case 2:
            //NSLog(@"Sleep mode");
            self.APPConfig &= ~(ApplicationMode);
            self.APPConfig |= Sleep;
            break;
        default:
            break;
    }
}

- (IBAction)SaveHRData:(id)sender {
    //[self SaveUserData];
}

- (IBAction)LoadHRData:(id)sender {
    //[self LoadUserData];
}
@end
