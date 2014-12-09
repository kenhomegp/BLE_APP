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

//#import "HRMSetting.h"
#import "HRMTableSetting.h"
#import "HeartLive.h"
#import "HRHealthyCare.h"
#import "HRMapView.h"

#import "HRMCBTask.h"

#define POLARH7_HRM_DEVICE_INFO_SERVICE_UUID @"180A"       // 180A = Device Information
#define POLARH7_HRM_HEART_RATE_SERVICE_UUID @"180D"        // 180D = Heart Rate Service
#define POLARH7_HRM_ENABLE_SERVICE_UUID @"2A39"
#define POLARH7_HRM_NOTIFICATIONS_SERVICE_UUID @"2A37"
#define POLARH7_HRM_BODY_LOCATION_UUID @"2A38"
#define POLARH7_HRM_MANUFACTURER_NAME_UUID @"2A29"

//=====================================================
#define BLE_AutoConnectx
#define CSR8670_BLEx
//=====================================================

#ifdef BLE_AutoConnect
@interface HRMViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate , MFMailComposeViewControllerDelegate ,UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate ,passUserSetting1 , passMapPositionDelegate>
#else
@interface HRMViewController : UIViewController <MFMailComposeViewControllerDelegate ,UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate ,passUserSetting1 , passMapPositionDelegate , HRMeasurement >
#endif
//HeartRate Curve
@property (nonatomic , strong) NSArray *dataSource;
@property (nonatomic , strong) HeartLive *refreshMoniterView;

//Heart Rate APP Config data
@property (strong, nonatomic) NSString *UserName;
@property (strong, nonatomic) NSString *UserAge;
@property (nonatomic) NSInteger APPConfig;
@property (nonatomic) NSInteger RestHeartRate;
@property (nonatomic) NSInteger SeguePassingData;

@property (weak, nonatomic) IBOutlet UIButton *Test_button;

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral     *polarH7HRMPeripheral;

// Properties for our Object controls
@property (nonatomic, strong) IBOutlet UIImageView *heartImage;
@property (nonatomic, strong) IBOutlet UITextView  *deviceInfo;
- (IBAction)HR_Test:(id)sender;

// Properties to hold data characteristics for the peripheral device
@property (weak, nonatomic) IBOutlet UILabel *HR_bpm;
@property (nonatomic, strong) NSString   *connected;
@property (nonatomic, strong) NSString   *bodyData;
@property (nonatomic, strong) NSString   *manufacturer;
@property (nonatomic, strong) NSString   *DeviceName;
@property (assign) uint16_t heartRate;
@property (assign) uint16_t CountError;
@property (nonatomic, strong) NSString *APPState;

// Properties to handle storing the BPM and heart beat
@property (nonatomic, strong) UILabel    *heartRateBPM;
@property (nonatomic, retain) NSTimer    *pulseTimer;
@property (weak, nonatomic) IBOutlet UILabel *minAlarmLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxAlarmLabel;
@property (weak, nonatomic) IBOutlet UITableView *sensorsTable;
@property (weak, nonatomic) IBOutlet UIButton *CustomButton;
- (IBAction)DrawHeartRateCurve:(id)sender;

/*
// Instance method to get the heart rate BPM information
- (void) getHeartBPMData:(CBCharacteristic *)characteristic error:(NSError *)error;

// Instance methods to grab device Manufacturer Name, Body Location
- (void) getManufacturerName:(CBCharacteristic *)characteristic;
- (void) getBodyLocation:(CBCharacteristic *)characteristic;
*/

// Instance method to perform heart beat animations
- (void) doHeartBeat;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *SettingButton;
@property (weak, nonatomic) IBOutlet UIButton *Test1Button;
@property (weak, nonatomic) IBOutlet UIImageView *Image_Connected;
@property (weak, nonatomic) IBOutlet UIImageView *Image_GPS;
@property (weak, nonatomic) IBOutlet UIImageView *Image_Battery;
@property (weak, nonatomic) IBOutlet UIImageView *BackgroundImage;
@property (weak, nonatomic) IBOutlet UIButton *HealthyCareViewButton;
@property (weak, nonatomic) IBOutlet UILabel *SportsTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *BurnCalorieLabel;
@property (weak, nonatomic) IBOutlet UILabel *MileageLabel;
@property (weak, nonatomic) IBOutlet UILabel *RunSpeedLabel;
@property (weak, nonatomic) IBOutlet UIWebView *HRGif;
@property (weak, nonatomic) IBOutlet UIImageView *Image_Running;
@property (weak, nonatomic) IBOutlet UIImageView *Image_Time;
@property (weak, nonatomic) IBOutlet UIImageView *Image_Speed;
@property (weak, nonatomic) IBOutlet UIImageView *Image_Calories;
@property (weak, nonatomic) IBOutlet UIButton *Map_Button;
@end