//
//  AppDelegate.h
//  MerryBLEtool
//
//  Created by merry on 13-12-18.
//  Copyright (c) 2013年 merry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HRMViewController.h"
#import "HRMTableSetting.h"
#import "HRStartViewController.h"
#import "AppDelegateProtocol.h"

@class HRMDataObject;

@interface AppDelegate : UIResponder <UIApplicationDelegate , AppDelegateProtocol>
{
    HRMDataObject *theAppDataObject;
}
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic , strong) NSString *APPState;
@property (nonatomic , retain) HRMDataObject *theAppDataObject;
@end
