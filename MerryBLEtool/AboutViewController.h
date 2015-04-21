//
//  AboutViewController.h
//  MyHRM
//
//  Created by 黃銘隆 on 2015/1/20.
//  Copyright (c) 2015年 merry. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HRMTableSetting.h"

#ifdef CustomBLE_iPhoneDemo
#import <CoreLocation/CoreLocation.h>
#endif

@interface AboutViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextField *Alarm_hh;
@property (weak, nonatomic) IBOutlet UITextField *Alarm_mm;
@property (weak, nonatomic) IBOutlet UISwitch *AlarmSwitch;
@property (nonatomic) int alarmClock_hh;
@property (nonatomic) int alarmClock_mm;
@property (nonatomic) bool EnableAlarmClock;
#ifdef CustomBLE_iPhoneDemo
@property (nonatomic) CLLocationDegrees testLatitude;
@property (nonatomic) CLLocationDegrees testLongitude;
#endif
@end
