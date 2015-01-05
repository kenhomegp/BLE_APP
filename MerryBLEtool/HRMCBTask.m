//
//  HRMCBTask.m
//  MyHRM
//
//  Created by merry on 14/12/3.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import "HRMCBTask.h"

#define DebugMode

//Test mode
#define SetHeartRateNotifyDisabled  30
#define SetHeartRateNotifyEnabled   31

@implementation HRMCBTask

- (void)SetVC:(NSInteger)vc
{
    self.ViewController = vc;
}

- (int) controlSetup{
    self.CM = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.tmp = nil;
    self.activeDevName = nil;
    
    //self.peripherals = [[NSMutableArray alloc] initWithCapacity:3];
    //NSLog(@"Control setup");
    
    return 0;
}

- (void)StopScanPeripheral
{
    if(self.CM != nil)
    {
        [self.CM stopScan];
    }
}

- (void)ScanHRMDevice
{
    //NSArray *services = @[[CBUUID UUIDWithString:HRM_HEART_RATE_SERVICE_UUID], [CBUUID UUIDWithString:HRM_DEVICE_INFO_SERVICE_UUID]];
    
    NSArray *services = @[[CBUUID UUIDWithString:HRM_HEART_RATE_SERVICE_UUID], [CBUUID UUIDWithString:HRM_DEVICE_INFO_SERVICE_UUID], [CBUUID UUIDWithString:IMM_ALERT_SERVICE_UUID]];

    if(self.CM != nil)
    {
        [self.CM scanForPeripheralsWithServices:services options:nil];
        //NSLog(@"Scan BLE_HeartRate device");
    }
    else
    {
        //NSLog(@"Failed to scan BLE device");
    }
}

-(void)ConnectHRMDevice:(NSString *)DeviceName
{
    if([DeviceName isEqualToString:self.activeDevName])
    {
        self.activePeripheral.delegate = self;
        
        [self.CM stopScan];
        
        [self.CM connectPeripheral:self.activePeripheral options:nil];
        
        //NSLog(@"Connect to HRM_device,%@",self.activeDevName);
    }
    else
    {
        [self.CM stopScan];
        self.tmp = DeviceName;
        [self ScanHRMDevice];
    }
}

-(void) DisconnectHRM
{
    [self.CM cancelPeripheralConnection:self.activePeripheral];
}

// method called whenever the device state changes.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // Determine the state of the peripheral
    if ([central state] == CBCentralManagerStatePoweredOff) {
        //NSLog(@"CoreBluetooth BLE hardware is powered off");
    }
    else if ([central state] == CBCentralManagerStatePoweredOn) {
        //NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
        [self ScanHRMDevice];
    }
    else if ([central state] == CBCentralManagerStateUnauthorized) {
        //NSLog(@"CoreBluetooth BLE state is unauthorized");
    }
    else if ([central state] == CBCentralManagerStateUnknown) {
        //NSLog(@"CoreBluetooth BLE state is unknown");
    }
    else if ([central state] == CBCentralManagerStateUnsupported) {
        //NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
    }
}

// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];

    if (![localName isEqual:@""])
    {
        /*
        //Scan device and Auto-reconnect
        if (([localName isEqual:@"HR Sensor306125"]) || ([localName isEqual:@"HRM"]) || ([localName isEqual:@"HR Sensor306041"]))
        {
                // We found the Heart Rate Monitor
                [self.CM stopScan];
            
                self.activePeripheral = peripheral;
            
                peripheral.delegate = self;
            
                [self.CM connectPeripheral:peripheral options:nil];
        }
        */
        
        if([localName isEqualToString:self.tmp])
        {
            [self.CM stopScan];
            self.activePeripheral = peripheral;
            self.activeDevName = localName;
            self.activePeripheral.delegate = self;
            [self.CM connectPeripheral:peripheral options:nil];
            return;
        }
        
        //NSLog(@"***Found a device : %@",localName);
        self.activePeripheral = peripheral;
        self.activeDevName = localName;
        [[self delegate1] CBStatusUpdate:@"Scan" BLEData:localName];
    }
}

// method called whenever we have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    
    //NSLog(@"Connected : YES");
    
    [[self delegate1] CBStatusUpdate:@"Connected" BLEData:@"YES"];
    
}

- (void)centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    //NSLog(@"Connected : NO");
    [[self delegate1] CBStatusUpdate:@"Connected" BLEData:@"NO"];
    
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    if(!(error))
    {
        //NSLog(@"didDisconnectPeripheral error");
        self.activePeripheral = nil;
        [[self delegate1] CBStatusUpdate:@"Disconnected" BLEData:@"YES"];
    }
    else
    {
        if(peripheral.state == 0)//Disconnected
        {
            self.activePeripheral = nil;
            [[self delegate1] CBStatusUpdate:@"Disconnected" BLEData:@"YES"];
            //NSLog(@"Peripheral disconnected!");
        }
    }
    
}

// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:HRM_HEART_RATE_SERVICE_UUID]])  {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            // Request heart rate notifications
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:HRM_NOTIFICATIONS_SERVICE_UUID]]) {
                
                [self.activePeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            // Request body sensor location
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:HRM_BODY_LOCATION_UUID]]) { 
                [self.activePeripheral readValueForCharacteristic:aChar];
            }
        }
    }
}

// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // Updated value for heart rate measurement received
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HRM_NOTIFICATIONS_SERVICE_UUID]]) { // 1
        // Get the Heart Rate Monitor BPM
        [self getHeartBPMData:characteristic error:error];
    }
    // Retrieve the characteristic value for manufacturer name received
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HRM_MANUFACTURER_NAME_UUID]]) {  // 2
        [self getManufacturerName:characteristic];
    }
    // Retrieve the characteristic value for the body sensor location received
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HRM_BODY_LOCATION_UUID]]) {  // 3
        [self getBodyLocation:characteristic];
    }
        
}

// Instance method to get the manufacturer name of the device
- (void) getManufacturerName:(CBCharacteristic *)characteristic
{
    //NSString *manufacturerName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    //NSLog(@"Manufacturer = %@",manufacturerName);
}

// Instance method to get the body location of the device
- (void) getBodyLocation:(CBCharacteristic *)characteristic
{
    NSData *sensorData = [characteristic value];
    uint8_t *bodyData = (uint8_t *)[sensorData bytes];
    if (bodyData ) {
        //uint8_t bodyLocation = bodyData[0];
        //NSString *str = [NSString stringWithFormat:@"Body Location: %@", bodyLocation == 1 ? @"Chest" : @"Undefined"];
        //NSLog(@"%@",str);
    }
    else {
        //NSLog(@"Body location:N/A");
    }
}

// Instance method to get the heart rate BPM information
- (void) getHeartBPMData:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // Get the Heart Rate Monitor BPM
    NSData *data = [characteristic value];
    const uint8_t *reportData = [data bytes];
    uint16_t bpm = 0;
    
    if ((reportData[0] & 0x01) == 0) {
        // Retrieve the BPM value for the Heart Rate Monitor
        bpm = reportData[1];
    }
    else {
        bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));
    }
    
    if( (characteristic.value)  || !error ) {
        //NSLog(@"HR value = %d",bpm);
        if(self.ViewController == 1)
            [[self delegate2] HeartRateBPM:bpm];
    }
}

@end
