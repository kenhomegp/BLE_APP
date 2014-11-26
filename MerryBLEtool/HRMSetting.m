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
    int tempMaxHR,tempRHR,tempUpperTHR,tempLowerTHR,tempHRReserve = 0;
    int i,j;
    
    if([UserName.text isEqualToString:@""])
        return;
    if([UserAge.text isEqualToString:@""])
        return;
    if(([self.UserRHR.text intValue]) == 0)
        return;
    
    [self CalculateHRData];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
#if 1
    [userDefaults setObject:UserName.text forKey:@"myHRMApp_Name"];
    [userDefaults setObject:UserAge.text forKey:@"myHRMApp_Age"];
    tempMaxHR = 220 - ([self.HR_UserAge intValue]);
    [userDefaults setInteger:tempMaxHR forKey:@"myHRMApp_MaxHR"];
    tempRHR = [self.UserRHR.text intValue];
    [userDefaults setInteger:tempRHR forKey:@"myHRMApp_RHR"];
    tempHRReserve = tempMaxHR - tempRHR;
    tempUpperTHR = (tempHRReserve * 0.8) + tempRHR;
    tempLowerTHR = (tempHRReserve * 0.6) + tempRHR;
    [userDefaults setInteger:tempUpperTHR forKey:@"myHRMApp_UpperTHR"];
    [userDefaults setInteger:tempLowerTHR forKey:@"myHRMApp_LowerTHR"];
    i = [self.NormalMaxHR.text intValue];
    j = [self.NormalMinHR.text intValue];
    [userDefaults setInteger:i forKey:@"myHRMApp_SetMaxHR"];
    [userDefaults setInteger:j forKey:@"myHRMApp_SetMinHR"];
    
    if(self.AlarmTHR.isOn)
        self.APPConfig |= TargetZoneAlarm;
    else
        self.APPConfig &= ~(TargetZoneAlarm);
    
    if(self.HRNotifiction.isOn)
        self.APPConfig |= HRNotification;
    else
        self.APPConfig &= ~(HRNotification);
    
    [userDefaults setInteger:self.APPConfig forKey:@"myHRMApp_APPConfig"];
#else
    [userDefaults setObject:@"peter" forKey:@"myHRMApp_Name"];
    [userDefaults setObject:@"34" forKey:@"myHRMApp_Age"];
    self.MaximumHR = 220-34;
    self.SetRHR = 62;
    [userDefaults setInteger:self.MaximumHR forKey:@"myHRMApp_MaxHR"];
    [userDefaults setInteger:self.SetRHR forKey:@"myHRMApp_RHR"];
    self.UpperTHR = 170;self.LowerTHR = 140;self.SetMaxHR = 90;self.SetMinHR = 40;self.APPConfig = 45;
    [userDefaults setInteger:self.UpperTHR forKey:@"myHRMApp_UpperTHR"];
    [userDefaults setInteger:self.LowerTHR forKey:@"myHRMApp_LowerTHR"];
    [userDefaults setInteger:self.SetMaxHR forKey:@"myHRMApp_SetMaxHR"];
    [userDefaults setInteger:self.SetMinHR forKey:@"myHRMApp_SetMinHR"];
    [userDefaults setInteger:self.APPConfig forKey:@"myHRMApp_APPConfig"];
#endif
    
    [userDefaults synchronize];
/*
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    NSLog(@"APP version = %@,%@",version,build);
*/
}

/*
- (void)LoadUserData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.HR_UserName = [userDefaults objectForKey:@"myHRMApp_Name"];
    self.HR_UserAge = [userDefaults objectForKey:@"myHRMApp_Age"];
    NSLog(@"%@",self.HR_UserName);
    NSLog(@"%@",self.HR_UserAge);
    self.MaximumHR = [userDefaults integerForKey:@"myHRMApp_MaxHR"];
    self.SetRHR = [userDefaults integerForKey:@"myHRMApp_RHR"];
    //NSLog(@"%d",[userDefaults integerForKey:@"myHRMApp_MaxHR"]);
    //NSLog(@"%d",[userDefaults integerForKey:@"myHRMApp_RHR"]);
    NSLog(@"%d",self.MaximumHR);
    NSLog(@"%d",self.SetRHR);
    self.UpperTHR = [userDefaults integerForKey:@"myHRMApp_UpperTHR"];
    self.LowerTHR = [userDefaults integerForKey:@"myHRMApp_LowerTHR"];
    self.SetMaxHR = [userDefaults integerForKey:@"myHRMApp_SetMaxHR"];
    self.SetMinHR = [userDefaults integerForKey:@"myHRMApp_SetMinHR"];
    self.APPConfig = [userDefaults integerForKey:@"myHRMApp_APPConfig"];
    NSLog(@"%d,%d,%d,%d,%d",self.UpperTHR,self.LowerTHR,self.SetMaxHR,self.SetMinHR,self.APPConfig);
    
    NSLog(@"LoadUserData");
}
*/

- (void) CalculateHRData
{
    _HR_UserAge = UserAge.text;
    
    NSInteger tmpAge = [_HR_UserAge intValue];
    if(tmpAge != self.UserAgeValue)
        self.UserAgeValue = tmpAge;
    
    //NSLog(@"Age : %@",_HR_UserAge);
    
    //if(!([self.HR_UserAge isEqualToString:@""]))
    if(tmpAge != 0)
    {
        NSInteger tempMaxHR,tempRHR,tempUpperTHR,tempLowerTHR,tempHRReserve = 0;
        
        tempMaxHR = 220 - ([self.HR_UserAge intValue]);
        self.MaximumHR = tempMaxHR;
        
        //self.MaxHR.text = [NSString stringWithFormat:@"Maximum Heart Rate = %ld",(long)tempMaxHR];
        
        self.UserMaxHR.text = [NSString stringWithFormat:@"%ld",(long)tempMaxHR];
        
        tempRHR = [self.UserRHR.text intValue];
        
        //NSLog(@"RHR : %@,%d",self.UserRHR.text,tempRHR);
        
        //if(!([self.UserRHR.text isEqualToString:@""]))
        if(tempRHR != 0)
        {
            if(self.SetRHR != tempRHR)
                self.SetRHR = tempRHR;
            
            //tempRHR = [self.UserRHR.text intValue];
            
            //if((tempRHR > 0) && (tempRHR < 90))
            if(self.SetRHR != 0)
            {
                //self.SetRHR = tempRHR;
                
                tempRHR = self.SetRHR;
                //NSLog(@"RestHR = %d",self.SetRHR);
                tempHRReserve = tempMaxHR - tempRHR;
                //NSLog(@"HR reserve = %d",tempHRReserve);
                tempUpperTHR = (tempHRReserve * 0.8) + tempRHR;
                tempLowerTHR = (tempHRReserve * 0.6) + tempRHR;
                self.UpperTHR = tempUpperTHR;
                self.LowerTHR = tempLowerTHR;
                //self.UserTHR.text = [NSString stringWithFormat:@"Target Heart Rate : %ld ~ %ld",(long)tempLowerTHR , (long)tempUpperTHR];
                self.UserTHR1.text = [NSString stringWithFormat:@"%ld ~ %ld",(long)tempLowerTHR , (long)tempUpperTHR];
                
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
    
    //self.title = @"Setting";
    //self.title = @"功能設定";
    //self.title = NSLocalizedString(@"SettingVC", @"");

    //Custom button
    [self.LoginButton setBackgroundImage:[UIImage imageNamed:@"Button1.png"] forState:UIControlStateNormal];
    [self.LoginButton setBackgroundImage:[UIImage imageNamed:@"Button1Pressed.png"] forState:UIControlStateHighlighted];
    
    if(!([self.HR_UserName isEqualToString:@""]))
        UserName.text = self.HR_UserName;
    
    if(!([self.HR_UserAge isEqualToString:@""]))
    {
        UserAge.text = self.HR_UserAge;
        self.UserAgeValue = [UserAge.text intValue];
    }
    
    self.UserRHR.text = [NSString stringWithFormat:@"%ld",(long)self.SetRHR];
    
    if((self.APPConfig & TargetZoneAlarm))
        [self.AlarmTHR setOn:YES];
    else
        [self.AlarmTHR setOn:NO];
    
    if((self.APPConfig & HRNotification))
        [self.HRNotifiction setOn:YES];
    else
        [self.HRNotifiction setOn:NO];
    
    if(self.SetMaxHR != 0)
    {
        self.SetNormalMaxHR.value = self.SetMaxHR;
        self.NormalMaxHR.text = [NSString stringWithFormat:@"%d",(int)self.SetNormalMaxHR.value];
    }
    
    if(self.SetMinHR != 0)
    {
        self.SetNormalMinHR.value = self.SetMinHR;
        self.NormalMinHR.text = [NSString stringWithFormat:@"%d",(int)self.SetNormalMinHR.value];
    }
    
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
    
    if(!([self.HR_UserAge isEqualToString:@""]) && self.SetRHR != 0)
        [self CalculateHRData];
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
/*
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
*/

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
    
    //[[self delegate] APPSetting:self.APPConfig];
}

- (IBAction)SaveHRData:(id)sender {
    [self SaveUserData];
    [[self delegate] APPSetting:self.APPConfig];
    [[self delegate] passHeartRateData:self.MaximumHR SetMaxHR:self.SetMaxHR SetMinHR:self.SetMinHR RestHeartRate:self.SetRHR UpperTargetHeartRate:self.UpperTHR LowerTargetHeartRate:self.LowerTHR];
    [self dismissViewControllerAnimated:YES completion:nil];
    //NSLog(@"Login...");
}

- (IBAction)LoadHRData:(id)sender {
    //[self LoadUserData];
}
- (IBAction)MaxValueChanged:(id)sender {
    float i = self.SetNormalMaxHR.value;
    self.NormalMaxHR.text = [NSString stringWithFormat:@"%d",(int)i];
    self.SetMaxHR = (int)i;
}

- (IBAction)MinValueChanged:(id)sender {
    float i = self.SetNormalMinHR.value;
    self.NormalMinHR.text = [NSString stringWithFormat:@"%d",(int)i];
    self.SetMinHR = (int)i;
}
@end
