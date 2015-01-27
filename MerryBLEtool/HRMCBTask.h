//
//  HRMCBTask.h
//  MyHRM
//
//  Created by merry on 14/12/3.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>


#define IMM_ALERT_SERVICE_UUID  @"1802"

#define HRM_DEVICE_INFO_SERVICE_UUID @"180A"       // 180A = Device Information
#define HRM_HEART_RATE_SERVICE_UUID @"180D"        // 180D = Heart Rate Service
#define HRM_ENABLE_SERVICE_UUID @"2A39"
#define HRM_NOTIFICATIONS_SERVICE_UUID @"2A37"
#define HRM_BODY_LOCATION_UUID @"2A38"
#define HRM_MANUFACTURER_NAME_UUID @"2A29"

@protocol BLECBDelegate
//-(void) HRMeasurement:(NSInteger)HeartRate;
-(void) CBStatusUpdate:(NSString *)BLE_Status BLEData:(NSString *)payload;
@end

@protocol HRMeasurement
-(void) HeartRateBPM:(NSInteger)HeartRate;
@end

@interface HRMCBTask : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate> {
}
@property (nonatomic,assign) id <BLECBDelegate> delegate1;
@property (nonatomic,assign) id <HRMeasurement> delegate2;
@property (strong, nonatomic) NSString *activeDevName;
@property (strong, nonatomic) NSString *tmp;
@property (strong, nonatomic) CBCentralManager *CM;
@property (strong, nonatomic) CBPeripheral *activePeripheral;
@property (nonatomic) NSInteger ViewController;
#ifdef DebugMode
@property (nonatomic) int TestStep;
#endif
-(int) controlSetup;
-(void) ScanHRMDevice;
-(void) ConnectHRMDevice:(NSString *)DeviceName;
-(void) DisconnectHRM;
- (void)SetVC:(NSInteger)vc;
- (void)StopScanPeripheral;
- (void)WriteValueForCustomCharacteristic:(BOOL)IOType OnOff:(BOOL)OnOffValue;
- (void)ReadBatterylevelCharacteristic;
@end
