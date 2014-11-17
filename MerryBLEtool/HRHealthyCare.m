//
//  HRHealthyCare.m
//  MerryBLEtool
//
//  Created by merry on 14-10-15.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import "HRHealthyCare.h"

#import "AppDelegateProtocol.h"
#import "HRMDataObject.h"

//#import "HRMViewController.h"
#import "HRMSetting.h"

@interface HRHealthyCare ()

@end

@implementation HRHealthyCare

#pragma mark -
#pragma mark instance methods

- (HRMDataObject *) theAppDataObject;
{
    id<AppDelegateProtocol> theDelegate = (id<AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    HRMDataObject *theDataObject;
    theDataObject = (HRMDataObject*) theDelegate.theAppDataObject;
    return theDataObject;
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
    
    //NSLog(@"SeguePassingData = %ld",self.SeguePassingData);
    
    HRMDataObject* theDataObject = [self theAppDataObject];
    self.APPConfig = theDataObject.APPConfig;
    
    switch(self.APPConfig & ApplicationMode)
    {
        case (Normal):
            //self.TitleLabel.text = @"一般模式";
            //self.title = @"心率偵測_一般模式";
            self.TitleLabel.text = NSLocalizedString(@"HCNormalLabel", @"none");
            //self.title = NSLocalizedString(@"MainViewController", @"title");
            self.title = NSLocalizedString(@"HealthyCareVC", @"none");
            [self.BackgroundImage setImage:[UIImage imageNamed:@"HeartRateDemo.jpg"]];
            break;
         case (Sleep):
            //self.TitleLabel.text = @"睡眠模式";
            //self.title = @"心率偵測_睡眠模式";
            self.TitleLabel.text = NSLocalizedString(@"HCSleepLabel", @"none");
            //self.title = NSLocalizedString(@"MainViewController", @"title");
            self.title = NSLocalizedString(@"HealthyCareVC", @"none");
            [self.BackgroundImage setImage:[UIImage imageNamed:@"sleepy.jpg"]];
            break;
        default:
            break;
    }
    
    
    if((self.APPConfig & BLE_Connected) == 0)
    {
        //NSLog(@"BLE disconnected!");
        
        //[[self delegate] passComdFromHRHealthyView:@"BLE_Connect"];
    }
    else{
        //NSLog(@"BLE connected!");
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"SegueToSetting"])
    {
        //NSLog(@"Segue pass data");
        //HRMSetting *User = [segue destinationViewController];
        
        NSString *name,*age;
        NSInteger MaximumHR,SetRHR,UpperTHR,LowerTHR,SetMaxHR,SetMinHR,APPConfig;
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        name = [userDefaults objectForKey:@"myHRMApp_Name"];
        age = [userDefaults objectForKey:@"myHRMApp_Age"];
        MaximumHR = [userDefaults integerForKey:@"myHRMApp_MaxHR"];
        SetRHR = [userDefaults integerForKey:@"myHRMApp_RHR"];
        UpperTHR = [userDefaults integerForKey:@"myHRMApp_UpperTHR"];
        LowerTHR = [userDefaults integerForKey:@"myHRMApp_LowerTHR"];
        SetMaxHR = [userDefaults integerForKey:@"myHRMApp_SetMaxHR"];
        SetMinHR = [userDefaults integerForKey:@"myHRMApp_SetMinHR"];
        APPConfig = [userDefaults integerForKey:@"myHRMApp_APPConfig"];
        
        if(name == nil)
        {
            name = nil;
            age = nil;
            SetRHR = 0;
            SetMaxHR = 70;
            SetMinHR = 50;
        }
        
        HRMSetting *User = [segue destinationViewController];
        User.HR_UserAge = age;
        User.HR_UserName = name;
        User.APPConfig = self.APPConfig;
        User.SetRHR = SetRHR;
        User.SetMaxHR = SetMaxHR;
        User.SetMinHR = SetMinHR;
    }
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

- (IBAction)ChgHRThreshold:(id)sender {
    [self performSegueWithIdentifier:@"SegueToSetting" sender:self];
}
@end
