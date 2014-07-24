//
//  GenericViewController.h
//  MerryBLEtool
//
//  Created by merry on 13-12-18.
//  Copyright (c) 2013年 merry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLECBTask.h"
#import "BLETabBarController.h"
#import "BLEDebug.h"

@interface GenericViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    BLECBTask *t;
}

// UI elements actions
- (IBAction)TIBLEUIScanForPeripheralsButton:(id)sender;

- (IBAction)TIBLEUISoundBuzzerButton:(id)sender;

- (IBAction)BLE_Scene_Connect:(id)sender;

// UI elements outlets
@property (weak, nonatomic) IBOutlet UISwitch *TIBLEUILeftButton;

@property (weak, nonatomic) IBOutlet UISwitch *TIBLEUIRightButton;

@property (weak, nonatomic) IBOutlet UIProgressView *TIBLEUIBatteryBar;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *TIBLEUISpinner;

@property (weak, nonatomic) IBOutlet UIButton *TIBLEUIConnBtn;

@property (weak, nonatomic) IBOutlet UIButton *TIBLEUIBuzzer;

@property (weak, nonatomic) IBOutlet UILabel *TIBLEUIBatteryBarLabel;

@property (weak, nonatomic) IBOutlet UITextField *BLE_Device;

@property (weak, nonatomic) IBOutlet UITextView *BLE_Service;

@property (weak, nonatomic) IBOutlet UITextView *BLE_Log;

@property (weak, nonatomic) IBOutlet UITextView *BLE_Characteristics;

@property (weak, nonatomic) IBOutlet UILabel *BLE_RSSI;

//Timer methods
- (void) batteryIndicatorTimer:(NSTimer *)timer;
- (void) connectionTimer:(NSTimer *)timer;
- (void) UpdateRSSITimer:(NSTimer *)timer;

- (void) logMessage:(NSString *)message;
@end
