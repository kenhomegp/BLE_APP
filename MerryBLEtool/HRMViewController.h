//
//  BLETabBarController.h
//  MerryBLEtool
//
//  Created by merry on 13-12-18.
//  Copyright (c) 2013年 merry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>
#import <CoreLocation/CoreLocation.h>

#import "HRMSetting.h"
#import "HeartLive.h"

#define POLARH7_HRM_DEVICE_INFO_SERVICE_UUID @"180A"       // 180A = Device Information
#define POLARH7_HRM_HEART_RATE_SERVICE_UUID @"180D"        // 180D = Heart Rate Service
#define POLARH7_HRM_ENABLE_SERVICE_UUID @"2A39"
#define POLARH7_HRM_NOTIFICATIONS_SERVICE_UUID @"2A37"
#define POLARH7_HRM_BODY_LOCATION_UUID @"2A38"
#define POLARH7_HRM_MANUFACTURER_NAME_UUID @"2A29"


@interface HRMViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate , MFMailComposeViewControllerDelegate , passUserSetting>

//HeartRate Curve
@property (nonatomic , strong) NSArray *dataSource;
@property (nonatomic , strong) HeartLive *refreshMoniterView;

//Heart Rate APP Config data
@property (strong, nonatomic) NSString *UserName;
@property (strong, nonatomic) NSString *UserAge;
@property (nonatomic) unsigned int APPConfig;
@property (nonatomic) unsigned int RestHeartRate;

@property (weak, nonatomic) IBOutlet UIButton *Test_button;

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral     *polarH7HRMPeripheral;

// Properties for our Object controls
@property (nonatomic, strong) IBOutlet UIImageView *heartImage;
@property (nonatomic, strong) IBOutlet UITextView  *deviceInfo;
- (IBAction)HR_Test:(id)sender;
//- (IBAction)HeartRateMinChanged:(id)sender;
//- (IBAction)HeartRateMaxChanged:(id)sender;

// Properties to hold data characteristics for the peripheral device
@property (weak, nonatomic) IBOutlet UILabel *HR_bpm;
@property (nonatomic, strong) NSString   *connected;
@property (nonatomic, strong) NSString   *bodyData;
@property (nonatomic, strong) NSString   *manufacturer;
@property (nonatomic, strong) NSString   *polarH7DeviceData;
@property (assign) uint16_t heartRate;
@property (assign) uint16_t CountError;

// Properties to handle storing the BPM and heart beat
@property (nonatomic, strong) UILabel    *heartRateBPM;
@property (nonatomic, retain) NSTimer    *pulseTimer;
//@property (weak, nonatomic) IBOutlet UIStepper *minAlarmStepper;
//@property (weak, nonatomic) IBOutlet UIStepper *maxAlarmStepper;
@property (weak, nonatomic) IBOutlet UILabel *minAlarmLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxAlarmLabel;
@property (weak, nonatomic) IBOutlet UITableView *sensorsTable;
@property (weak, nonatomic) IBOutlet UIButton *CustomButton;
- (IBAction)DrawHeartRateCurve:(id)sender;

// Instance method to get the heart rate BPM information
- (void) getHeartBPMData:(CBCharacteristic *)characteristic error:(NSError *)error;

// Instance methods to grab device Manufacturer Name, Body Location
- (void) getManufacturerName:(CBCharacteristic *)characteristic;
- (void) getBodyLocation:(CBCharacteristic *)characteristic;

// Instance method to perform heart beat animations
- (void) doHeartBeat;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *SettingButton;
@property (weak, nonatomic) IBOutlet UIButton *Test1Button;
@property (weak, nonatomic) IBOutlet UIImageView *Image_Connected;
@property (weak, nonatomic) IBOutlet UIImageView *Image_GPS;
@property (weak, nonatomic) IBOutlet UIImageView *Image_Battery;
@property (weak, nonatomic) IBOutlet UIImageView *BackgroundImage;
@property (weak, nonatomic) IBOutlet UIButton *HealthyCareViewButton;

@end