//
//  AboutViewController.m
//  MyHRM
//
//  Created by 黃銘隆 on 2015/1/20.
//  Copyright (c) 2015年 merry. All rights reserved.
//

#import "AboutViewController.h"

//#import "HRMTableSetting.h"

#import "HRStartViewController.h"

@interface AboutViewController ()
{
   
}
@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Load an external page into our UIWebView
    //NSURL *myNSURL = [[NSURL alloc] initWithString:@"http://www.merry.com.tw"];

//#ifdef CustomBLEService
    NSURL *myNSURL;
#if (defined(CustomBLEService) || defined(CustomBLE_iPhoneDemo))
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UINavigationController *NavVC = (UINavigationController *)[self.tabBarController.viewControllers objectAtIndex:0];
        HRStartViewController *myVC = (HRStartViewController *)NavVC.topViewController;
        NSString *GPS = [NSString stringWithFormat:@"%f,%f",myVC.myLatitude,myVC.myLongitude];
    
        //NSURL *myNSURL;
        if(myVC.myLatitude == 0.0 && myVC.myLongitude == 0.0)
        {
            myNSURL = [[NSURL alloc] initWithString:@"http://www.merry.com.tw"];
        }
        else
        {
            myNSURL = [[NSURL alloc] initWithString:[@"http://maps.google.com/?q=" stringByAppendingString:GPS]];
        }
    }
    else
    {
    #ifdef CustomBLE_iPhoneDemo
        NSString *GPS1 = [NSString stringWithFormat:@"%f,%f",self.testLatitude,self.testLongitude];
        
        if(self.testLatitude == 0.0 && self.testLongitude == 0.0)
        {
            myNSURL = [[NSURL alloc] initWithString:@"http://www.merry.com.tw"];
        }
        else
        {
            myNSURL = [[NSURL alloc] initWithString:[@"http://maps.google.com/?q=" stringByAppendingString:GPS1]];
        }
    #endif
    }
#else
    NSURL *myNSURL = [[NSURL alloc] initWithString:@"http://maps.google.com/?q=24.161838,120.604486"];  //Merry Electronics Co.,Ltd
#endif
            
    NSURLRequest *myNSURLRequest = [[NSURLRequest alloc] initWithURL:myNSURL];
    
    [self.webView loadRequest:myNSURLRequest];
    
    self.AlarmSwitch.on = NO;
    self.alarmClock_hh = 0;
    self.alarmClock_mm = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:NO];
    
    //NSLog(@"viewdisappear");
    if(self.Alarm_hh.text != nil)
        self.alarmClock_hh = [self.Alarm_hh.text intValue];
    else
        self.alarmClock_hh = 0;
    
    if(self.Alarm_mm.text != nil)
        self.alarmClock_mm = [self.Alarm_mm.text intValue];
    else
        self.alarmClock_mm = 0;
    
    if(self.AlarmSwitch.on)
        self.EnableAlarmClock = TRUE;
    else
        self.EnableAlarmClock = FALSE;
}

- (IBAction)doEditFieldDone:(id)sender
{
    //NSLog(@"doEditFieldDone");
    if(self.Alarm_hh.text != nil)
        self.alarmClock_hh = [self.Alarm_hh.text intValue];
    else
        self.alarmClock_hh = 0;
    
    if(self.Alarm_mm.text != nil)
        self.alarmClock_mm = [self.Alarm_mm.text intValue];
    
    [sender resignFirstResponder];
    
    /*
    if(self.Alarm_hh.text != nil)
    {
        NSLog(@"%@",self.Alarm_hh.text);
    }
    if(self.Alarm_mm.text != nil)
    {
        NSLog(@"%@",self.Alarm_mm.text);
    }
    */
}

- (IBAction)UpdateAlarmClockState:(id)sender {
    
    //NSLog(@"SwitchValueChange");
    
    if(self.AlarmSwitch.on)
        self.EnableAlarmClock = TRUE;
    else
        self.EnableAlarmClock = FALSE;
    
    if(self.Alarm_hh.text != nil)
        self.alarmClock_hh = [self.Alarm_hh.text intValue];
    else
        self.alarmClock_hh = 0;
    
    if(self.Alarm_mm.text != nil)
        self.alarmClock_mm = [self.Alarm_mm.text intValue];
    else
        self.alarmClock_mm = 0;

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
