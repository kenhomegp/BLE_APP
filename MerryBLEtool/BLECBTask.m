//
//  BLECBTask.m
//  MerryBLEtool
//
//  Created by merry on 13-12-19.
//  Copyright (c) 2013年 merry. All rights reserved.
//

#import "BLECBTask.h"

#ifdef DEBUG_BLETask
#define Core_Bluetooth_DEBUG(x) {printf x;}
#define BLE_Service_DEBUG(x) {printf x;}
#define BLE_Characteristic_DEBUG(x) {printf x;}
#else
#define Core_Bluetooth_DEBUG(x)
#define BLE_Service_DEBUG(x)
#define BLE_Characteristic_DEBUG(x)
#endif

@implementation BLECBTask

@synthesize delegate;
@synthesize CM;
@synthesize peripherals;
@synthesize activePeripheral;
@synthesize batteryLevel;
@synthesize key1;
@synthesize key2;
@synthesize x;
@synthesize y;
@synthesize z;
@synthesize TXPwrLevel;
@synthesize TIBLEConnectBtn;
@synthesize m_Device;
@synthesize m_Service;
@synthesize KeyfobFound;

/*!
 *  @method initConnectButtonPointer
 *
 *  @param b Pointer to the button
 *
 *  @discussion Used to change the text of the button label during the connection cycle.
 */
-(void) initConnectButtonPointer:(UIButton *)b {
    TIBLEConnectBtn = b;
}

/*!
 *  @method soundBuzzer:
 *
 *  @param buzVal The data to write
 *  @param p CBPeripheral to write to
 *
 *  @discussion Sound the buzzer on a TI keyfob. This method writes a value to the proximity alert service
 *
 */
-(void) soundBuzzer:(Byte)buzVal p:(CBPeripheral *)p {
    NSData *d = [[NSData alloc] initWithBytes:&buzVal length:TI_KEYFOB_PROXIMITY_ALERT_WRITE_LEN];
    [self writeValue:TI_KEYFOB_PROXIMITY_ALERT_UUID characteristicUUID:TI_KEYFOB_PROXIMITY_ALERT_PROPERTY_UUID p:p data:d];
}

/*!
 *  @method readBattery:
 *
 *  @param p CBPeripheral to read from
 *
 *  @discussion Start a battery level read cycle from the battery level service
 *
 */
-(void) readBattery:(CBPeripheral *)p {
    if(self.activePeripheral)
    {
        [self readValue:TI_KEYFOB_BATT_SERVICE_UUID characteristicUUID:TI_KEYFOB_LEVEL_SERVICE_UUID p:p];
    }
}


//

/*!
 *  @method enableAccelerometer:
 *
 *  @param p CBPeripheral to write to
 *
 *  @discussion Enables the accelerometer and enables notifications on X,Y and Z axis
 *
 */
-(void) enableAccelerometer:(CBPeripheral *)p {
    char data = 0x01;
    NSData *d = [[NSData alloc] initWithBytes:&data length:1];
    
    [self writeValue:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_ENABLER_UUID p:p data:d];
    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_X_UUID p:p on:YES];
    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_Y_UUID p:p on:YES];
    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_Z_UUID p:p on:YES];
    
    //[self notification:0x180d characteristicUUID:0x2a37 p:p on:YES];
    
    //printf("Enabling accelerometer\r\n");
    Core_Bluetooth_DEBUG(("Enabling accelerometer\r\n"));
}

/*!
 *  @method disableAccelerometer:
 *
 *  @param p CBPeripheral to write to
 *
 *  @discussion Disables the accelerometer and disables notifications on X,Y and Z axis
 *
 */
-(void) disableAccelerometer:(CBPeripheral *)p {
    char data = 0x00;
    NSData *d = [[NSData alloc] initWithBytes:&data length:1];
    [self writeValue:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_ENABLER_UUID p:p data:d];
    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_X_UUID p:p on:NO];
    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_Y_UUID p:p on:NO];
    [self notification:TI_KEYFOB_ACCEL_SERVICE_UUID characteristicUUID:TI_KEYFOB_ACCEL_Z_UUID p:p on:NO];
    //printf("Disabling accelerometer\r\n");
    Core_Bluetooth_DEBUG(("Disabling accelerometer\r\n"));
}


/*!
 *  @method enableButtons:
 *
 *  @param p CBPeripheral to write to
 *
 *  @discussion Enables notifications on the simple keypress service
 *
 */
-(void) enableButtons:(CBPeripheral *)p {
    [self notification:TI_KEYFOB_KEYS_SERVICE_UUID characteristicUUID:TI_KEYFOB_KEYS_NOTIFICATION_UUID p:p on:YES];
}

/*!
 *  @method disableButtons:
 *
 *  @param p CBPeripheral to write to
 *
 *  @discussion Disables notifications on the simple keypress service
 *
 */
-(void) disableButtons:(CBPeripheral *)p {
    [self notification:TI_KEYFOB_KEYS_SERVICE_UUID characteristicUUID:TI_KEYFOB_KEYS_NOTIFICATION_UUID p:p on:NO];
}

/*!
 *  @method enableTXPower:
 *
 *  @param p CBPeripheral to write to
 *
 *  @discussion Enables notifications on the TX Power level service
 *
 */
-(void) enableTXPower:(CBPeripheral *)p {
    [self notification:TI_KEYFOB_PROXIMITY_TX_PWR_SERVICE_UUID characteristicUUID:TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_UUID p:p on:YES];
}

/*!
 *  @method disableTXPower:
 *
 *  @param p CBPeripheral to write to
 *
 *  @discussion Disables notifications on the TX Power level service
 *
 */
-(void) disableTXPower:(CBPeripheral *)p {
    [self notification:TI_KEYFOB_PROXIMITY_TX_PWR_SERVICE_UUID characteristicUUID:TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_UUID p:p on:NO];
}




/*!
 *  @method writeValue:
 *
 *  @param serviceUUID Service UUID to write to (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to write to (e.g. 0x2401)
 *  @param data Data to write to peripheral
 *  @param p CBPeripheral to write to
 *
 *  @discussion Main routine for writeValue request, writes without feedback. It converts integer into
 *  CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service.
 *  If this is found, value is written. If not nothing is done.
 *
 */

-(void) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
        //printf("#Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        Core_Bluetooth_DEBUG(("#Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:p.UUID]));
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        //printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        Core_Bluetooth_DEBUG(("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:p.UUID]));
        return;
    }
    [p writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
}


/*!
 *  @method readValue:
 *
 *  @param serviceUUID Service UUID to read from (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to read from (e.g. 0x2401)
 *  @param p CBPeripheral to read from
 *
 *  @discussion Main routine for read value request. It converts integers into
 *  CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service.
 *  If this is found, the read value is started. When value is read the didUpdateValueForCharacteristic
 *  routine is called.
 *
 *  @see didUpdateValueForCharacteristic
 */

-(void) readValue: (int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
        //printf("*Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        Core_Bluetooth_DEBUG(("*Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:p.UUID]));
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        //printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        Core_Bluetooth_DEBUG(("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:p.UUID]));
        return;
    }
    [p readValueForCharacteristic:characteristic];
}


/*!
 *  @method notification:
 *
 *  @param serviceUUID Service UUID to read from (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to read from (e.g. 0x2401)
 *  @param p CBPeripheral to read from
 *
 *  @discussion Main routine for enabling and disabling notification services. It converts integers
 *  into CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service.
 *  If this is found, the notfication is set.
 *
 */
-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on {
    UInt16 s = [self swap:serviceUUID];
    UInt16 c = [self swap:characteristicUUID];
    NSData *sd = [[NSData alloc] initWithBytes:(char *)&s length:2];
    NSData *cd = [[NSData alloc] initWithBytes:(char *)&c length:2];
    CBUUID *su = [CBUUID UUIDWithData:sd];
    CBUUID *cu = [CBUUID UUIDWithData:cd];
    CBService *service = [self findServiceFromUUID:su p:p];
    if (!service) {
        //printf("!Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        Core_Bluetooth_DEBUG(("!Could not find service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:su],[self UUIDToString:p.UUID]));
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        //printf("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:p.UUID]);
        Core_Bluetooth_DEBUG(("Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:cu],[self CBUUIDToString:su],[self UUIDToString:p.UUID]));
        return;
    }
    [p setNotifyValue:on forCharacteristic:characteristic];
}


/*!
 *  @method swap:
 *
 *  @param s Uint16 value to byteswap
 *
 *  @discussion swap byteswaps a UInt16
 *
 *  @return Byteswapped UInt16
 */

-(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

/*!
 *  @method controlSetup:
 *
 *  @param s Not used
 *
 *  @return Allways 0 (Success)
 *
 *  @discussion controlSetup enables CoreBluetooths Central Manager and sets delegate to TIBLECBKeyfob class
 *
 */
- (int) controlSetup: (int) s{
    self.CM = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    return 0;
}

/*!
 *  @method findBLEPeripherals:
 *
 *  @param timeout timeout in seconds to search for BLE peripherals
 *
 *  @return 0 (Success), -1 (Fault)
 *
 *  @discussion findBLEPeripherals searches for BLE peripherals and sets a timeout when scanning is stopped
 *
 */
- (int) findBLEPeripherals:(int) timeout {
    
    if (self->CM.state  != CBCentralManagerStatePoweredOn) {
        Core_Bluetooth_DEBUG(("CoreBluetooth not correctly initialized !\r\n"));
        Core_Bluetooth_DEBUG(("State = %d (%s)\r\n",self->CM.state,[self centralManagerStateToString:self.CM.state]));
        [[self delegate] logBLEMessage:@"CoreBluetooth not correctly initialized !"];
        return -1;
    }
    
    [NSTimer scheduledTimerWithTimeInterval:(float)timeout target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];
    
    [self.CM scanForPeripheralsWithServices:nil options:0]; // Start scanning
    [TIBLEConnectBtn setTitle:@"Scanning.." forState:UIControlStateNormal];
    [[self delegate] logBLEMessage:@"Scanning.."];
    return 0; // Started scanning OK !
}


/*!
 *  @method connectPeripheral:
 *
 *  @param p Peripheral to connect to
 *
 *  @discussion connectPeripheral connects to a given peripheral and sets the activePeripheral property of TIBLECBKeyfob.
 *
 */
- (void) connectPeripheral:(CBPeripheral *)peripheral {
    Core_Bluetooth_DEBUG(("Connecting to peripheral with UUID : %s\r\n",[self UUIDToString:peripheral.UUID]));
    activePeripheral = peripheral;
    activePeripheral.delegate = self;
    [CM connectPeripheral:activePeripheral options:nil];
    [TIBLEConnectBtn setTitle:@"Connecting.." forState:UIControlStateNormal];
    //[[self delegate] logBLEMessage:@"Connecting..\n"];
}

/*!
 *  @method centralManagerStateToString:
 *
 *  @param state State to print info of
 *
 *  @discussion centralManagerStateToString prints information text about a given CBCentralManager state
 *
 */
- (const char *) centralManagerStateToString: (int)state{
    switch(state) {
        case CBCentralManagerStateUnknown:
            return "State unknown (CBCentralManagerStateUnknown)";
        case CBCentralManagerStateResetting:
            return "State resetting (CBCentralManagerStateUnknown)";
        case CBCentralManagerStateUnsupported:
            return "State BLE unsupported (CBCentralManagerStateResetting)";
        case CBCentralManagerStateUnauthorized:
            return "State unauthorized (CBCentralManagerStateUnauthorized)";
        case CBCentralManagerStatePoweredOff:
            return "State BLE powered off (CBCentralManagerStatePoweredOff)";
        case CBCentralManagerStatePoweredOn:
            return "State powered up and ready (CBCentralManagerStatePoweredOn)";
        default:
            return "State unknown";
    }
    return "Unknown state";
}

/*!
 *  @method scanTimer:
 *
 *  @param timer Backpointer to timer
 *
 *  @discussion scanTimer is called when findBLEPeripherals has timed out, it stops the CentralManager from scanning further and prints out information about known peripherals
 *
 */
- (void) scanTimer:(NSTimer *)timer {
    if(self.activePeripheral){
        [TIBLEConnectBtn setTitle:@"Disconnect" forState:UIControlStateNormal];
        return;
    }
    else
    {
        [self.CM stopScan];
        [TIBLEConnectBtn setTitle:@"Scan and Connect" forState:UIControlStateNormal];
        self.KeyfobFound = NO;
        self.Service1 = 0;
        self.Service2 = 0;
        [[self delegate] keyfobReady: self.KeyfobFound GATT_Service_1:self.Service1 GATT_Service_2:self.Service2];
        Core_Bluetooth_DEBUG(("Stopped Scanning\r\n"));
        Core_Bluetooth_DEBUG(("Known peripherals : %d\r\n",[self->peripherals count]));
        if(self.peripherals.count != 0)
        {
            [self printKnownPeripherals];
        }
    }
}

/*!
 *  @method printKnownPeripherals:
 *
 *  @discussion printKnownPeripherals prints all curenntly known peripherals stored in the peripherals array of TIBLECBKeyfob class
 *
 */
- (void) printKnownPeripherals {
    int i;
    Core_Bluetooth_DEBUG(("List of currently known peripherals : \r\n"));
    for (i=0; i < self->peripherals.count; i++)
    {
        CBPeripheral *p = [self->peripherals objectAtIndex:i];
        CFStringRef s = CFUUIDCreateString(NULL, p.UUID);
        printf("%d  |  %s\r\n",i,CFStringGetCStringPtr(s, 0));
        [self printPeripheralInfo:p];
    }
}

/*
 *  @method printPeripheralInfo:
 *
 *  @param peripheral Peripheral to print info of
 *
 *  @discussion printPeripheralInfo prints detailed info about peripheral
 *
 */
- (void) printPeripheralInfo:(CBPeripheral*)peripheral {
    CFStringRef s = CFUUIDCreateString(NULL, peripheral.UUID);
    Core_Bluetooth_DEBUG(("------------------------------------\r\n"));
    Core_Bluetooth_DEBUG(("Peripheral Info :\r\n"));
    printf("UUID : %s\r\n",CFStringGetCStringPtr(s, 0));
    Core_Bluetooth_DEBUG(("RSSI : %d\r\n",[peripheral.RSSI intValue]));
    NSLog(@"Name : %@\r\n",peripheral.name);
    Core_Bluetooth_DEBUG(("isConnected : %d\r\n",peripheral.isConnected));
    Core_Bluetooth_DEBUG(("-------------------------------------\r\n"));
    
}

/*
 *  @method UUIDSAreEqual:
 *
 *  @param u1 CFUUIDRef 1 to compare
 *  @param u2 CFUUIDRef 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compares two CFUUIDRef's
 *
 */

- (int) UUIDSAreEqual:(CFUUIDRef)u1 u2:(CFUUIDRef)u2 {
    CFUUIDBytes b1 = CFUUIDGetUUIDBytes(u1);
    CFUUIDBytes b2 = CFUUIDGetUUIDBytes(u2);
    if (memcmp(&b1, &b2, 16) == 0) {
        return 1;
    }
    else return 0;
}


/*
 *  @method getAllServicesFromKeyfob
 *
 *  @param p Peripheral to scan
 *
 *
 *  @discussion getAllServicesFromKeyfob starts a service discovery on a peripheral pointed to by p.
 *  When services are found the didDiscoverServices method is called
 *
 */
-(void) getAllServicesFromKeyfob:(CBPeripheral *)p{
    [TIBLEConnectBtn setTitle:@"Discovering services.." forState:UIControlStateNormal];
    [[self delegate] logBLEMessage:@"Discovering services.."];
    [p discoverServices:nil]; // Discover all services without filter
}

/*
 *  @method getAllCharacteristicsFromKeyfob
 *
 *  @param p Peripheral to scan
 *
 *
 *  @discussion getAllCharacteristicsFromKeyfob starts a characteristics discovery on a peripheral
 *  pointed to by p
 *
 */
-(void) getAllCharacteristicsFromKeyfob:(CBPeripheral *)p{
    const char *str;
    self.Service1 = 0;
    self.Service2 = 0;

    [TIBLEConnectBtn setTitle:@"Discovering characteristics.." forState:UIControlStateNormal];
    
    Core_Bluetooth_DEBUG(("GetAllCharacteristics..\r\n"));
    
    [[self delegate] logBLEMessage:@"Get All Service/Characteristics.."];
    
    for (int i=0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        str = [self CBUUIDToString:s.UUID];
                
        //NSString *UUIDString = CFBridgingRelease(CFUUIDCreateString(NULL, CFBridgingRetain(s.UUID)));
        
        if(strcmp(str , "<1802>") == 0)
            self.Service1 += 1;
        if(strcmp(str , "<1803>") == 0)
            self.Service1 += 2;
        if(strcmp(str , "<1804>") == 0)
            self.Service1 += 4;
        if(strcmp(str , "<1805>") == 0)
            self.Service1 += 8;
        if(strcmp(str , "<1806>") == 0)
            self.Service1 += 16;
        if(strcmp(str , "<1807>") == 0)
            self.Service1 += 32;
        if(strcmp(str , "<1808>") == 0)
            self.Service1 += 64;
        if(strcmp(str , "<1809>") == 0)
            self.Service1 += 128;
        if(strcmp(str , "<180a>") == 0)
            self.Service1 += 256;
        if(strcmp(str , "<180d>") == 0)
            self.Service1 += 512;
        
        if(strcmp(str , "<180e>") == 0)
            self.Service2 += 1;
        if(strcmp(str , "<180f>") == 0)
            self.Service2 += 2;
        if(strcmp(str , "<1810>") == 0)
            self.Service2 += 4;
        if(strcmp(str , "<1811>") == 0)
            self.Service2 += 8;
        if(strcmp(str , "<1812>") == 0)
            self.Service2 += 16;
        if(strcmp(str , "<1813>") == 0)
            self.Service2 += 32;
        if(strcmp(str , "<1814>") == 0)
            self.Service2 += 64;
        if(strcmp(str , "<1816>") == 0)
            self.Service2 += 128;
        if(strcmp(str , "<1818>") == 0)
            self.Service2 += 256;
        if(strcmp(str , "<1819>") == 0)
            self.Service2 += 512;

        BLE_Service_DEBUG(("Fetching characteristics for service with UUID : %s\r\n",[self CBUUIDToString:s.UUID]));
        
        //Convert const char* to NSString
        NSString *ss = [NSString stringWithCString:str encoding:NSUTF8StringEncoding];
        [[self delegate] logBLEMessage:ss];
        
        [p discoverCharacteristics:nil forService:s];
    }
}


/*
 *  @method CBUUIDToString
 *
 *  @param UUID UUID to convert to string
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion CBUUIDToString converts the data of a CBUUID class to a character pointer for easy printout using printf()
 *
 */
-(const char *) CBUUIDToString:(CBUUID *) UUID {
    //return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
    
    return[[UUID.data description] cStringUsingEncoding:NSASCIIStringEncoding];
}


/*
 *  @method UUIDToString
 *
 *  @param UUID UUID to convert to string
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion UUIDToString converts the data of a CFUUIDRef class to a character pointer for easy printout using printf()
 *
 */
-(const char *) UUIDToString:(CFUUIDRef)UUID {
    if (!UUID) return "NULL";
    CFStringRef s = CFUUIDCreateString(NULL, UUID);
    return CFStringGetCStringPtr(s, 0);
    
}

/*
 *  @method compareCBUUID
 *
 *  @param UUID1 UUID 1 to compare
 *  @param UUID2 UUID 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compareCBUUID compares two CBUUID's to each other and returns 1 if they are equal and 0 if they are not
 *
 */

-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2 {
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1];
    [UUID2.data getBytes:b2];
    if (memcmp(b1, b2, UUID1.data.length) == 0)return 1;
    else return 0;
}

/*
 *  @method compareCBUUIDToInt
 *
 *  @param UUID1 UUID 1 to compare
 *  @param UUID2 UInt16 UUID 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compareCBUUIDToInt compares a CBUUID to a UInt16 representation of a UUID and returns 1
 *  if they are equal and 0 if they are not
 *
 */
-(int) compareCBUUIDToInt:(CBUUID *)UUID1 UUID2:(UInt16)UUID2 {
    char b1[16];
    [UUID1.data getBytes:b1];
    UInt16 b2 = [self swap:UUID2];
    if (memcmp(b1, (char *)&b2, 2) == 0) return 1;
    else return 0;
}
/*
 *  @method CBUUIDToInt
 *
 *  @param UUID1 UUID 1 to convert
 *
 *  @returns UInt16 representation of the CBUUID
 *
 *  @discussion CBUUIDToInt converts a CBUUID to a Uint16 representation of the UUID
 *
 */
-(UInt16) CBUUIDToInt:(CBUUID *) UUID {
    char b1[16];
    [UUID.data getBytes:b1];
    return ((b1[0] << 8) | b1[1]);
}

/*
 *  @method IntToCBUUID
 *
 *  @param UInt16 representation of a UUID
 *
 *  @return The converted CBUUID
 *
 *  @discussion IntToCBUUID converts a UInt16 UUID to a CBUUID
 *
 */
-(CBUUID *) IntToCBUUID:(UInt16)UUID {
    char t[16];
    t[0] = ((UUID >> 8) & 0xff); t[1] = (UUID & 0xff);
    NSData *data = [[NSData alloc] initWithBytes:t length:16];
    return [CBUUID UUIDWithData:data];
}


/*
 *  @method findServiceFromUUID:
 *
 *  @param UUID CBUUID to find in service list
 *  @param p Peripheral to find service on
 *
 *  @return pointer to CBService if found, nil if not
 *
 *  @discussion findServiceFromUUID searches through the services list of a peripheral to find a
 *  service with a specific UUID
 *
 */
-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p {
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
    }
    return nil; //Service not found on this peripheral
}

/*
 *  @method findCharacteristicFromUUID:
 *
 *  @param UUID CBUUID to find in Characteristic list of service
 *  @param service Pointer to CBService to search for charateristics on
 *
 *  @return pointer to CBCharacteristic if found, nil if not
 *
 *  @discussion findCharacteristicFromUUID searches through the characteristic list of a given service
 *  to find a characteristic with a specific UUID
 *
 */
-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    return nil; //Characteristic not found on this service
}

//----------------------------------------------------------------------------------------------------
//
//
//
//
//CBCentralManagerDelegate protocol methods beneeth here
// Documented in CoreBluetooth documentation
//
//
//
//
//----------------------------------------------------------------------------------------------------




- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    Core_Bluetooth_DEBUG(("Status of CoreBluetooth central manager changed %d (%s)\r\n",central.state,[self centralManagerStateToString:central.state]));
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    /*    if (!self.peripherals) self.peripherals = [[NSMutableArray alloc] initWithObjects:peripheral,nil];
     else {
     for(int i = 0; i < self.peripherals.count; i++) {
     CBPeripheral *p = [self.peripherals objectAtIndex:i];
     if ([self UUIDSAreEqual:p.UUID u2:peripheral.UUID]) {
     [self.peripherals replaceObjectAtIndex:i withObject:peripheral];
     printf("Duplicate UUID found updating ...\r\n");
     return;
     }
     }
     [self->peripherals addObject:peripheral];
     printf("New UUID, adding\r\n");
     }
     */
    if ([peripheral.name rangeOfString:@"Keyfob"].location != NSNotFound) {
        self.KeyfobFound = TI_keyfob;
        [self connectPeripheral:peripheral];
        self.m_Device.text = peripheral.name;
        Core_Bluetooth_DEBUG(("Found a TI_keyfob, connecting..\n"));
    }
    else if ([peripheral.name rangeOfString:@"CSR Security Tag"].location != NSNotFound) {
        self.KeyfobFound = CSR_security_tag;
        [self connectPeripheral:peripheral];
        self.m_Device.text = peripheral.name;
        Core_Bluetooth_DEBUG(("Found a CSR Security Tag, connecting..\n"));
    }
    else
    {
        //Core_Bluetooth_DEBUG(("Peripheral not a keyfob or callback was not because of a ScanResponse\n"));
        self.KeyfobFound = Unknown_Device;
        [self connectPeripheral:peripheral];
        self.m_Device.text = peripheral.name;
        Core_Bluetooth_DEBUG(("Found a device??, connecting..\n"));
    }
    
    //printf("didDiscoverPeripheral\r\n");
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    Core_Bluetooth_DEBUG(("Connection to peripheral with UUID : %s successfull\r\n",[self UUIDToString:peripheral.UUID]));
    
    self.activePeripheral = peripheral;
    [self.activePeripheral discoverServices:nil];
    [central stopScan];
}

//----------------------------------------------------------------------------------------------------
//
//
//
//
//
//CBPeripheralDelegate protocol methods beneeth here
//
//
//
//
//
//----------------------------------------------------------------------------------------------------

/*
 *  @method didDiscoverCharacteristicsForService
 *
 *  @param peripheral Pheripheral that got updated
 *  @param service Service that characteristics where found on
 *  @error error Error message if something went wrong
 *
 *  @discussion didDiscoverCharacteristicsForService is called when CoreBluetooth has discovered
 *  characteristics on a service, on a peripheral after the discoverCharacteristics routine has been called on the service
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!error) {
        Core_Bluetooth_DEBUG(("Characteristics of service with UUID : %s found,NumOfCharacterisitc : %d\r\n",[self CBUUIDToString:service.UUID],service.characteristics.count));
        
        NSString *ss1 = [NSString stringWithCString:[self CBUUIDToString:service.UUID] encoding:NSUTF8StringEncoding];
        NSString *ss2 = [@"Characteristics of service with UUID : " stringByAppendingString:ss1];
        [[self delegate] logBLEMessage:ss2];
        
        for(int i=0; i < service.characteristics.count; i++) {
            CBCharacteristic *c = [service.characteristics objectAtIndex:i];
            BLE_Characteristic_DEBUG(("Found characteristic %s, ",[ self CBUUIDToString:c.UUID]));
            NSString *ss3 = [@"Found characteristic : " stringByAppendingString:[NSString stringWithCString:[self CBUUIDToString:c.UUID] encoding:NSUTF8StringEncoding]];
            [[self delegate] logBLEMessage:ss3];
            [[self delegate] UpdateCharacteristic:[NSString stringWithCString:[self CBUUIDToString:c.UUID] encoding:NSUTF8StringEncoding]];
#if 1       
            //Get the properties of the characteristic
            CBCharacteristicProperties k = c.properties;
            for(int j = 0 ; j < 10; j++)
            {
                if(k & (1 << j))
                {
                    if(j == 1)
                    {
                        BLE_Characteristic_DEBUG(("Read "));//Read
                        [[self delegate] logBLEMessage:@"Read"];
                    }
                    if(j == 2)
                    {
                        BLE_Characteristic_DEBUG(("WriteWithoutResponse "));//WriteWithoutResponse
                        [[self delegate] logBLEMessage:@"WriteWithoutResponse"];
                    }
                    if(j == 3)
                    {
                        BLE_Characteristic_DEBUG(("Write "));//Write
                        [[self delegate] logBLEMessage:@"Write"];
                    }
                    if(j == 4)
                    {
                        BLE_Characteristic_DEBUG(("Notify "));//Notify
                        [[self delegate] logBLEMessage:@"Notify"];
                    }
                }
            }
            BLE_Characteristic_DEBUG(("\r\n"));
#endif
            
            CBService *s = [peripheral.services objectAtIndex:(peripheral.services.count - 1)];
            if([self compareCBUUID:service.UUID UUID2:s.UUID]) {
                BLE_Characteristic_DEBUG(("Finished discovering characteristics\r\n"));
                [[self delegate] keyfobReady: self.KeyfobFound GATT_Service_1:self.Service1 GATT_Service_2:self.Service2];
            }
        }
    }
    else {
        Core_Bluetooth_DEBUG(("Characteristic discorvery unsuccessfull !\r\n"));
        [[self delegate] logBLEMessage:@"Characteristic discovery unsuccessfull!"];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
}

/*
 *  @method didDiscoverServices
 *
 *  @param peripheral Pheripheral that got updated
 *  @error error Error message if something went wrong
 *
 *  @discussion didDiscoverServices is called when CoreBluetooth has discovered services on a
 *  peripheral after the discoverServices routine has been called on the peripheral
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!error) {
        BLE_Service_DEBUG(("Services of peripheral with UUID : %s found\r\n",[self UUIDToString:peripheral.UUID]));
        [self getAllCharacteristicsFromKeyfob:peripheral];
    }
    else {
        BLE_Service_DEBUG(("Service discovery was unsuccessfull !\r\n"));
        [[self delegate] logBLEMessage:@"Service discovery was unsuccessfull !"];
    }
}

/*
 *  @method didUpdateNotificationStateForCharacteristic
 *
 *  @param peripheral Pheripheral that got updated
 *  @param characteristic Characteristic that got updated
 *  @error error Error message if something went wrong
 *
 *  @discussion didUpdateNotificationStateForCharacteristic is called when CoreBluetooth has updated a
 *  notification state for a characteristic
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        BLE_Characteristic_DEBUG(("Updated notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[self UUIDToString:peripheral.UUID]));
#if 1
        NSString *ss1 = [@"Update notification state for characteristic with UUID " stringByAppendingString:[NSString stringWithCString:[self CBUUIDToString:characteristic.UUID] encoding:NSUTF8StringEncoding]];
        NSString *ss2 = [@" on service with UUID " stringByAppendingString:[NSString stringWithCString:[self CBUUIDToString:characteristic.service.UUID] encoding:NSUTF8StringEncoding]];
        ss1 = [ss1 stringByAppendingString:ss2];
        [[self delegate] logBLEMessage:ss1];
    
        //Get the properties of the characteristic
        /*
        CBCharacteristicProperties k = characteristic.properties;
        for(int j = 0 ; j < 10; j++)
        {
            if(k & (1 << j))
            {
                if(j == 1)
                {
                    [[self delegate] logBLEMessage:@"Read"];//Read
                }
                if(j == 2)
                {
                    [[self delegate] logBLEMessage:@"WriteWithoutResponse"];//
                }
                if(j == 3)
                {
                    [[self delegate] logBLEMessage:@"Write"];
                }
                if(j == 4)
                {
                    [[self delegate] logBLEMessage:@"Notify"];
                }
            }
        }
        */
#endif
    }
    else {
        BLE_Characteristic_DEBUG(("Error in setting notification state for characteristic with UUID %s on service with  UUID %s on peripheral with UUID %s\r\n",[self CBUUIDToString:characteristic.UUID],[self CBUUIDToString:characteristic.service.UUID],[self UUIDToString:peripheral.UUID]));
        BLE_Characteristic_DEBUG(("Error code was %s\r\n",[[error description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy]));
        [[self delegate] logBLEMessage:@"Error in setting notification state for characteristic"];
    }
    
}

/*
 *  @method didUpdateValueForCharacteristic
 *
 *  @param peripheral Pheripheral that got updated
 *  @param characteristic Characteristic that got updated
 *  @error error Error message if something went wrong
 *
 *  @discussion didUpdateValueForCharacteristic is called when CoreBluetooth has updated a
 *  characteristic for a peripheral. All reads and notifications come here to be processed.
 *
 */

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    UInt16 characteristicUUID = [self CBUUIDToInt:characteristic.UUID];
    if (!error) {
        switch(characteristicUUID){
            case TI_KEYFOB_LEVEL_SERVICE_UUID:
            {
                char batlevel;
                [characteristic.value getBytes:&batlevel length:TI_KEYFOB_LEVEL_SERVICE_READ_LEN];
                self.batteryLevel = (float)batlevel;
                break;
            }
            case TI_KEYFOB_KEYS_NOTIFICATION_UUID:
            {
                char keys;
                [characteristic.value getBytes:&keys length:TI_KEYFOB_KEYS_NOTIFICATION_READ_LEN];
                if (keys & 0x01) self.key1 = YES;
                else self.key1 = NO;
                if (keys & 0x02) self.key2 = YES;
                else self.key2 = NO;
                [[self delegate] keyValuesUpdated: keys];
                break;
            }
            case TI_KEYFOB_ACCEL_X_UUID:
            {
                char xval;
                [characteristic.value getBytes:&xval length:TI_KEYFOB_ACCEL_READ_LEN];
                self.x = xval;
                [[self delegate] accelerometerValuesUpdated:self.x y:self.y z:self.z];
                break;
            }
            case TI_KEYFOB_ACCEL_Y_UUID:
            {
                char yval;
                [characteristic.value getBytes:&yval length:TI_KEYFOB_ACCEL_READ_LEN];
                self.y = yval;
                [[self delegate] accelerometerValuesUpdated:self.x y:self.y z:self.z];
                break;
            }
            case TI_KEYFOB_ACCEL_Z_UUID:
            {
                char zval;
                [characteristic.value getBytes:&zval length:TI_KEYFOB_ACCEL_READ_LEN];
                self.z = zval;
                [[self delegate] accelerometerValuesUpdated:self.x y:self.y z:self.z];
                break;
            }
            case TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_UUID:
            {
                char TXLevel;
                [characteristic.value getBytes:&TXLevel length:TI_KEYFOB_PROXIMITY_TX_PWR_NOTIFICATION_READ_LEN];
                self.TXPwrLevel = TXLevel;
                [[self delegate] TXPwrLevelUpdated:TXLevel];
                break;
            }
            /*Heart Rate profile*/
            case 0x2A37://Heart Rate Measurement
            {
                //CSR1010 EVB HeartRate Monitor
                //Data format : https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.heart_rate_measurement.xml
                char HRMeasure[4];
                
                [characteristic.value getBytes:HRMeasure length:4];
                //BLE_Characteristic_DEBUG(("HR data:%x,%x,%x,%x\n",HRMeasure[0],HRMeasure[1],HRMeasure[2],HRMeasure[3]));
                BLE_Characteristic_DEBUG(("HR data:%d\n",HRMeasure[1]));
                self.x = HRMeasure[1];
                [[self delegate] accelerometerValuesUpdated:self.x y:self.y z:self.z];
                break;
            }
            case 0x2A38://Body Sensor Location
            {
                char BSLdata = 0;
                [characteristic.value getBytes:&BSLdata];
                //BSLdata = 0;Other
                //BSLdata = 1;Chest
                //          2;Wrist
                //          3;Finger
                //          4;Hand
                //          5;Ear Lobe
                //          6;Foot
                //          7~ 255;Reserved for future use
                BLE_Characteristic_DEBUG(("Sensor Location:%d\n",BSLdata));
                break;
            }
            /*End of Heart Rate profile*/
            default:
                BLE_Characteristic_DEBUG(("Unknown characteristic = %X\n",characteristicUUID));
                break;
        }
    }
    else {
        BLE_Characteristic_DEBUG(("updateValueForCharacteristic failed !"));
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if(error)
        BLE_Characteristic_DEBUG(("Error writing characteristic value\r\n"));
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {
    
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    if(!error)
    {
        //NSLog(@"RSSI : %@\n", peripheral.RSSI);
        self.DevRSSI = [peripheral.RSSI stringValue];
    }
}


@end
