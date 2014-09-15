//
//  BLETabBarController.h
//  MerryBLEtool
//
//  Created by merry on 13-12-18.
//  Copyright (c) 2013年 merry. All rights reserved.
//

#import "HRMViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface HRMViewController () <UITableViewDataSource, UITableViewDelegate>
{
    AVAudioPlayer *_audioPlayer;
}
@end

@implementation HRMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Do any additional setup after loading the view, typically from a nib.
	self.polarH7DeviceData = nil;
    self.polarH7HRMPeripheral = nil;
    self.connected = nil;
    
	[self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	[self.heartImage setImage:[UIImage imageNamed:@"HeartImage"]];
	
	// Clear out textView
	[self.deviceInfo setText:@""];
	[self.deviceInfo setTextColor:[UIColor blueColor]];
	[self.deviceInfo setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	[self.deviceInfo setFont:[UIFont fontWithName:@"Futura-CondensedMedium" size:25]];
	[self.deviceInfo setUserInteractionEnabled:NO];
	
	// Create our Heart Rate BPM Label
	self.heartRateBPM = [[UILabel alloc] initWithFrame:CGRectMake(55, 30, 75, 50)];
	[self.heartRateBPM setTextColor:[UIColor whiteColor]];
	[self.heartRateBPM setText:[NSString stringWithFormat:@"%i", 0]];
	[self.heartRateBPM setFont:[UIFont fontWithName:@"Futura-CondensedMedium" size:28]];
	[self.heartImage addSubview:self.heartRateBPM];
    
    self.CountError = 0;
	
	// Scan for all available CoreBluetooth LE devices
	NSArray *services = @[[CBUUID UUIDWithString:POLARH7_HRM_HEART_RATE_SERVICE_UUID], [CBUUID UUIDWithString:POLARH7_HRM_DEVICE_INFO_SERVICE_UUID]];
	CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
	[centralManager scanForPeripheralsWithServices:services options:nil];
	self.centralManager = centralManager;
    
    // Construct URL to sound file
    NSString *path = [NSString stringWithFormat:@"%@/HRAlarm.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrl = [NSURL fileURLWithPath:path];
    
    // Create audio player object and initialize with URL to sound
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    
    [_audioPlayer setVolume:1.0];
    
}

// method called whenever the device state changes.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
	// Determine the state of the peripheral
	if ([central state] == CBCentralManagerStatePoweredOff) {
		NSLog(@"CoreBluetooth BLE hardware is powered off");
	}
	else if ([central state] == CBCentralManagerStatePoweredOn) {
		NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
	}
	else if ([central state] == CBCentralManagerStateUnauthorized) {
		NSLog(@"CoreBluetooth BLE state is unauthorized");
	}
	else if ([central state] == CBCentralManagerStateUnknown) {
		NSLog(@"CoreBluetooth BLE state is unknown");
	}
	else if ([central state] == CBCentralManagerStateUnsupported) {
		NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
	}
}

// method called whenever we have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	[peripheral setDelegate:self];
    [peripheral discoverServices:nil];
	self.connected = [NSString stringWithFormat:@"Connected: %@", peripheral.state == CBPeripheralStateConnected ? @"YES" : @"NO"];
    
    if([self.connected rangeOfString:@"YES"].location != NSNotFound)
    {
        [self.sensorsTable reloadData];
    }
}

// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	for (CBService *service in peripheral.services) {
		[peripheral discoverCharacteristics:nil forService:service];
	}
}

// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
	if (![localName isEqual:@""]) {
        //if ([localName isEqual:@"HR Sensor306125"]) {
        if (([localName isEqual:@"HR Sensor306125"]) || ([localName isEqual:@"CSR HR Sensor"])) {
            // We found the Heart Rate Monitor
            [self.centralManager stopScan];
            if(self.polarH7HRMPeripheral == nil)
                self.polarH7HRMPeripheral = peripheral;
            peripheral.delegate = self;
            [self.centralManager connectPeripheral:peripheral options:nil];
            //[self.sensorsTable reloadData];
        }
	}
    
    //NSLog(@"***Found a device : %@",localName);
}

// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
	if ([service.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_HEART_RATE_SERVICE_UUID]])  {  // 1
		for (CBCharacteristic *aChar in service.characteristics)
		{
			// Request heart rate notifications
			if ([aChar.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_NOTIFICATIONS_SERVICE_UUID]]) { // 2
				[self.polarH7HRMPeripheral setNotifyValue:YES forCharacteristic:aChar];
			}
			// Request body sensor location
			else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_BODY_LOCATION_UUID]]) { // 3
				[self.polarH7HRMPeripheral readValueForCharacteristic:aChar];
			}
//			else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_ENABLE_SERVICE_UUID]]) { // 4
//				// Read the value of the heart rate sensor
//				UInt8 value = 0x01;
//				NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
//				[peripheral writeValue:data forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
//			}
		}
	}
    
    /*
	// Retrieve Device Information Services for the Manufacturer Name
	if ([service.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_DEVICE_INFO_SERVICE_UUID]])  { // 5
        for (CBCharacteristic *aChar in service.characteristics)
        {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_MANUFACTURER_NAME_UUID]]) {
                [self.polarH7HRMPeripheral readValueForCharacteristic:aChar];
                NSLog(@"Found a Device Manufacturer Name Characteristic");
            }
        }
	}
    */
}

// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	// Updated value for heart rate measurement received
	if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_NOTIFICATIONS_SERVICE_UUID]]) { // 1
		// Get the Heart Rate Monitor BPM
		[self getHeartBPMData:characteristic error:error];
	}
	// Retrieve the characteristic value for manufacturer name received
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_MANUFACTURER_NAME_UUID]]) {  // 2
		[self getManufacturerName:characteristic];
    }
	// Retrieve the characteristic value for the body sensor location received
	else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_BODY_LOCATION_UUID]]) {  // 3
		[self getBodyLocation:characteristic];
    }
    
    //Change Manufacturer name
    self.manufacturer = @"Manufacturer : Merry";
	
	// Add our constructed device information to our UITextView
	self.deviceInfo.text = [NSString stringWithFormat:@"%@\n%@\n%@\n", self.connected, self.bodyData, self.manufacturer];  // 4
    
    [self.deviceInfo setHidden:YES];
    
    [self.sensorsTable reloadData];
    
}

// Instance method to get the heart rate BPM information
- (void) getHeartBPMData:(CBCharacteristic *)characteristic error:(NSError *)error
{
	// Get the Heart Rate Monitor BPM
	NSData *data = [characteristic value];      // 1
	const uint8_t *reportData = [data bytes];
	uint16_t bpm = 0;
	
	if ((reportData[0] & 0x01) == 0) {          // 2
		// Retrieve the BPM value for the Heart Rate Monitor
		bpm = reportData[1];
	}
	else {
		bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));  // 3
	}
	// Display the heart rate value to the UI if no error occurred
	if( (characteristic.value)  || !error ) {   // 4
		self.heartRate = bpm;
		//self.heartRateBPM.text = [NSString stringWithFormat:@"%i bpm", bpm];
        self.heartRateBPM.text = [NSString stringWithFormat:@"%i", bpm];
		self.heartRateBPM.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:28];
		[self doHeartBeat];
		self.pulseTimer = [NSTimer scheduledTimerWithTimeInterval:(60. / self.heartRate) target:self selector:@selector(doHeartBeat) userInfo:nil repeats:NO];
	}
    
    //Update HR_bpm data
    self.HR_bpm.text = [NSString stringWithFormat:@"%i bpm", bpm];
    
    if(bpm > ((int)self.maxAlarmStepper.value))
    {
        self.CountError++;
        if(self.CountError >= 3)
        {
            self.CountError = 0;
            [_audioPlayer play];
        }
    }
    else if(bpm < ((int)self.minAlarmStepper.value))
    {
        self.CountError++;
        if(self.CountError >= 3)
        {
            self.CountError++;
            [_audioPlayer play];
        }
    }
    else{
        if(self.CountError < 3 && self.CountError != 0)
            self.CountError = 0;
    }
    
	return;
}

// Instance method to get the manufacturer name of the device
- (void) getManufacturerName:(CBCharacteristic *)characteristic
{
	NSString *manufacturerName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
	self.manufacturer = [NSString stringWithFormat:@"Manufacturer: %@", manufacturerName];
	return;
}

// Instance method to get the body location of the device
- (void) getBodyLocation:(CBCharacteristic *)characteristic
{
	NSData *sensorData = [characteristic value];
	uint8_t *bodyData = (uint8_t *)[sensorData bytes];
	if (bodyData ) {
		uint8_t bodyLocation = bodyData[0];
		self.bodyData = [NSString stringWithFormat:@"Body Location: %@", bodyLocation == 1 ? @"Chest" : @"Undefined"];
	}
	else {
		self.bodyData = [NSString stringWithFormat:@"Body Location: N/A"];
	}
	return;
}

// instance method to stop the device from rotating - only support the Portrait orientation
- (NSUInteger) supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    return UIInterfaceOrientationMaskPortrait;
}

// instance method to simulate our pulsating Heart Beat
- (void) doHeartBeat
{
	CALayer *layer = [self heartImage].layer;
	CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	pulseAnimation.toValue = [NSNumber numberWithFloat:1.1];
	pulseAnimation.fromValue = [NSNumber numberWithFloat:1.0];
	
	pulseAnimation.duration = 60. / self.heartRate / 2.;
	pulseAnimation.repeatCount = 1;
	pulseAnimation.autoreverses = YES;
	pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	[layer addAnimation:pulseAnimation forKey:@"scale"];
	
	self.pulseTimer = [NSTimer scheduledTimerWithTimeInterval:(60. / self.heartRate) target:self selector:@selector(doHeartBeat) userInfo:nil repeats:NO];
}

// handle memory warning errors
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)HR_Test:(id)sender {
    //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning!!" message:@"HeartRate value is too high" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //[alertView show];
    
    //[self.polarH7HRMPeripheral writeValue:<#(NSData *)#> forCharacteristic:<#(CBCharacteristic *)#> type:<#(CBCharacteristicWriteType)#>]
    
    //NSLog(@"Test Audio\n");
    //[_audioPlayer play];
}

- (IBAction)HeartRateMinChanged:(id)sender {
    //NSLog(@"Min changed..\n");
    //NSLog(@"%d\n",(int)self.minAlarmStepper.value);
    
    [self.minAlarmLabel setText:[NSString stringWithFormat:@"MIN %d",(int)self.minAlarmStepper.value]];
}

- (IBAction)HeartRateMaxChanged:(id)sender {
    //NSLog(@"Max changed..\n");
    //NSLog(@"%d\n",(int)self.maxAlarmStepper.value);
    
    [self.maxAlarmLabel setText:[NSString stringWithFormat:@"MAX %d",(int)self.maxAlarmStepper.value]];
}

#pragma mark -
#pragma mark TableView Delegates
/****************************************************************************/
/*							TableView Delegates								*/
/****************************************************************************/
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell	*cell;
	CBPeripheral	*peripheral;
	//NSArray			*devices;
	//NSInteger		row	= [indexPath row];
    static NSString *cellID = @"Cell";
    
	cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
	if (!cell)
    {
        //cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    
	if ([indexPath section] == 0)
    {
		//devices = [[LeDiscovery sharedInstance] connectedServices];
        //peripheral = [(LeTemperatureAlarmService*)[devices objectAtIndex:row] peripheral];
        //peripheral = self.polarH7HRMPeripheral;
        
        //BLE_connected = [NSString stringWithFormat:@"Connected: %@", peripheral != nil ? @"YES" : @"NO"];
        //NSLog(BLE_connected);
	}
    else
    {
		//devices = [[LeDiscovery sharedInstance] foundPeripherals];
        //peripheral = (CBPeripheral*)[devices objectAtIndex:row];
	}
    
    if([self.connected rangeOfString:@"YES"].location != NSNotFound)
    {
        peripheral = self.polarH7HRMPeripheral;
        
        if([indexPath section] == 0)
        {
            [[cell textLabel] setTextColor:[UIColor redColor]];
            
            if([indexPath row] == 0)
            {
                if ([[peripheral name] length])
                    [[cell textLabel] setText:[peripheral name]];
            }
            else if([indexPath row] == 1)
            {
                [[cell textLabel] setText:self.connected];
            }
            else if([indexPath row] == 2)
            {
                [[cell textLabel] setText:self.bodyData];
            }
            else if([indexPath row] == 3)
            {
                [[cell textLabel] setText:self.manufacturer];
            }
            
        }
    }
    
    /*
    if ([[peripheral name] length])
        [[cell textLabel] setText:[peripheral name]];
    else
        [[cell textLabel] setText:@"Peripheral"];
    */
    
    //[[cell detailTextLabel] setText: [peripheral isConnected] ? @"Connected" : @"Not connected"];
    
	return cell;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger	res = 0;
    
	//if (section == 0)
	//	res = [[[LeDiscovery sharedInstance] connectedServices] count];
	//else
	//	res = [[[LeDiscovery sharedInstance] foundPeripherals] count];
    
    if(section == 0)
        res = 4;
    
	return res;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	CBPeripheral	*peripheral;
	NSArray			*devices;
	NSInteger		row	= [indexPath row];
	
	if ([indexPath section] == 0) {
//		devices = [[LeDiscovery sharedInstance] connectedServices];
//        peripheral = [(LeTemperatureAlarmService*)[devices objectAtIndex:row] peripheral];
	} else {
//		devices = [[LeDiscovery sharedInstance] foundPeripherals];
//    	peripheral = (CBPeripheral*)[devices objectAtIndex:row];
	}
    
    peripheral = self.polarH7HRMPeripheral;
    
	if (![peripheral isConnected]) {
		//[[LeDiscovery sharedInstance] connectPeripheral:peripheral];
        //[currentlyConnectedSensor setText:[peripheral name]];
        
        //[currentlyConnectedSensor setEnabled:NO];
        //[currentTemperatureLabel setEnabled:NO];
        //[maxAlarmLabel setEnabled:NO];
        //[minAlarmLabel setEnabled:NO];
    }
    
	else {
        
        //if ( currentlyDisplayingService != nil ) {
        //    [currentlyDisplayingService release];
        //    currentlyDisplayingService = nil;
        //}
        
        /*
        currentlyDisplayingService = [self serviceForPeripheral:peripheral];
        [currentlyDisplayingService retain];
        
        [currentlyConnectedSensor setText:[peripheral name]];
        
        [currentTemperatureLabel setText:[NSString stringWithFormat:@"%dº", (int)[currentlyDisplayingService temperature]]];
        [maxAlarmLabel setText:[NSString stringWithFormat:@"MAX %dº", (int)[currentlyDisplayingService maximumTemperature]]];
        [minAlarmLabel setText:[NSString stringWithFormat:@"MIN %dº", (int)[currentlyDisplayingService minimumTemperature]]];
        
        [currentlyConnectedSensor setEnabled:YES];
        [currentTemperatureLabel setEnabled:YES];
        [maxAlarmLabel setEnabled:YES];
        [minAlarmLabel setEnabled:YES];
         */
    }
}
@end