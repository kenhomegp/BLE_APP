//
//  BLECBTask.h
//  MerryBLEtool
//
//  Created by merry on 13-12-19.
//  Copyright (c) 2013年 merry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>
#import "BLEDefines.h"
#import "BLEDebug.h" 

@protocol CoreBTDelagate
-(void) logBLEMessage:(NSString *)message;
@end

/*
@protocol BLECBDelegate
@optional
-(void) keyfobReady:(char)DeviceFound GATT_Service_1:(int)Service_1 GATT_Service_2:(int)Service_2;
-(void) logBLEMessage:(NSString *)message;
-(void) UpdateCharacteristic:(NSString *)ble_char;
@required
-(void) accelerometerValuesUpdated:(char)x y:(char)y z:(char)z;
-(void) keyValuesUpdated:(char)sw;
-(void) TXPwrLevelUpdated:(char)TXPwr;
@end
 */

@interface BLECBTask : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate> {    
}

@property (nonatomic)   char KeyfobFound;
@property (nonatomic)   float batteryLevel;
@property (nonatomic)   BOOL key1;
@property (nonatomic)   BOOL key2;
@property (nonatomic)   char x;
@property (nonatomic)   char y;
@property (nonatomic)   char z;
@property (nonatomic)   char TXPwrLevel;
@property (nonatomic)   NSString *DevRSSI;

@property (nonatomic,assign) id <CoreBTDelagate> delegate;
@property (strong, nonatomic)  NSMutableArray *peripherals;
@property (strong, nonatomic) CBCentralManager *CM;
@property (strong, nonatomic) CBPeripheral *activePeripheral;

//***
@property (strong, nonatomic) UIButton *TIBLEConnectBtn;
@property (strong, nonatomic) UITextField *m_Device;
@property (strong, nonatomic) UITextView *m_Service;

@property (nonatomic) int Service1;
@property (nonatomic) int Service2;
@property (nonatomic) int TestStep;

-(void) initConnectButtonPointer:(UIButton *)b;
-(void) soundBuzzer:(Byte)buzVal p:(CBPeripheral *)p;
-(void) readBattery:(CBPeripheral *)p;
-(void) enableAccelerometer:(CBPeripheral *)p;
-(void) disableAccelerometer:(CBPeripheral *)p;
-(void) enableButtons:(CBPeripheral *)p;
-(void) disableButtons:(CBPeripheral *)p;
-(void) enableTXPower:(CBPeripheral *)p;
-(void) disableTXPower:(CBPeripheral *)p;

-(void) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID  p:(CBPeripheral *)p data:(NSData *)data;
-(void) readValue: (int)serviceUUID characteristicUUID:(int)characteristicUUID  p:(CBPeripheral *)p;
-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID  p:(CBPeripheral *)p on:(BOOL)on;

-(UInt16) swap:(UInt16) s;
-(int) controlSetup:(int) s;
-(int) findBLEPeripherals:(int) timeout;
-(const char *) centralManagerStateToString:(int)state;
-(void) scanTimer:(NSTimer *)timer;
-(void) printKnownPeripherals;
-(void) printPeripheralInfo:(CBPeripheral*)peripheral;
-(void) connectPeripheral:(CBPeripheral *)peripheral;
-(void) DisconnectHRM;

-(void) getAllServicesFromKeyfob:(CBPeripheral *)p;
-(void) getAllCharacteristicsFromKeyfob:(CBPeripheral *)p;
-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p;
-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service;
-(const char *) UUIDToString:(CFUUIDRef) UUID;
-(const char *) CBUUIDToString:(CBUUID *) UUID;
-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2;
-(int) compareCBUUIDToInt:(CBUUID *) UUID1 UUID2:(UInt16)UUID2;
-(UInt16) CBUUIDToInt:(CBUUID *) UUID;
-(int) UUIDSAreEqual:(CFUUIDRef)u1 u2:(CFUUIDRef)u2;
- (void)WriteValueForCustomCharacteristic:(BOOL)IOType OnOff:(BOOL)OnOffValue;
- (void)ReadBatterylevelCharacteristic;
@end
