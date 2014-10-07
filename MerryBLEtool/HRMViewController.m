//
//  BLETabBarController.h
//  MerryBLEtool
//
//  Created by merry on 13-12-18.
//  Copyright (c) 2013年 merry. All rights reserved.
//

#import "HRMViewController.h"
#import <AVFoundation/AVFoundation.h>

#define drawHeartRateCurveTimeInterval  0.01
#define StartAnimationIfConnected

#define AnimationDuration   0.25
#define HeartRatePulseTimer 100

static uint16_t currentMaxHR = 0;
static uint16_t currentMinHR = 0;
static bool InitialUserData = 0;

@interface HRMViewController () <UITableViewDataSource, UITableViewDelegate>
{
    AVAudioPlayer *_audioPlayer;
    NSTimer *DrawHRCurve;
    //AVQueuePlayer *_MyAudioPlayer;
}
@end

@implementation HRMViewController

- (HeartLive *)refreshMoniterView
{
    if (!_refreshMoniterView) {
        //CGFloat xOffset = 20;
        CGFloat xOffset = 74;
        _refreshMoniterView = [[HeartLive alloc] initWithFrame:CGRectMake(xOffset, 800, CGRectGetWidth(self.view.frame) - 2 * xOffset, 200)];
        _refreshMoniterView.backgroundColor = [UIColor blackColor];
        NSLog(@"HeartRateCurveView width = %f, heigth = 200",CGRectGetWidth(self.view.frame) - 2 * xOffset);//620 x 200
    }
    return _refreshMoniterView;
}

- (void)viewWillDisappear:(BOOL)animated
{
    if([DrawHRCurve isValid])
        [DrawHRCurve invalidate];
    
    if([self.pulseTimer isValid])
        [self.pulseTimer invalidate];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //NSLog(@"viewDidLoad");
    
	// Do any additional setup after loading the view, typically from a nib.
	self.polarH7DeviceData = nil;
    self.polarH7HRMPeripheral = nil;
    self.connected = nil;
    
    //Navigation View title
    [self.navigationController.navigationBar.topItem setTitle:@"HeartRate_Sports"];
    
    //Custom button
    [self.CustomButton setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    [self.CustomButton setBackgroundImage:[UIImage imageNamed:@"buttonHighlighted.png"] forState:UIControlStateHighlighted];
    
    //Color,Image
	[self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	[self.heartImage setImage:[UIImage imageNamed:@"HeartImage"]];
	
	// Clear out textView
	[self.deviceInfo setText:@""];
	[self.deviceInfo setTextColor:[UIColor blueColor]];
	[self.deviceInfo setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	[self.deviceInfo setFont:[UIFont fontWithName:@"Futura-CondensedMedium" size:25]];
	[self.deviceInfo setUserInteractionEnabled:NO];
	
    #ifndef StartAnimationIfConnected
	// Create our Heart Rate BPM Label
	self.heartRateBPM = [[UILabel alloc] initWithFrame:CGRectMake(55, 30, 75, 50)];
	[self.heartRateBPM setTextColor:[UIColor whiteColor]];
	[self.heartRateBPM setText:[NSString stringWithFormat:@"%i", 0]];
	[self.heartRateBPM setFont:[UIFont fontWithName:@"Futura-CondensedMedium" size:28]];
	[self.heartImage addSubview:self.heartRateBPM];
    #endif
    
    self.CountError = 0;
	
	// Scan for all available CoreBluetooth LE devices
	NSArray *services = @[[CBUUID UUIDWithString:POLARH7_HRM_HEART_RATE_SERVICE_UUID], [CBUUID UUIDWithString:POLARH7_HRM_DEVICE_INFO_SERVICE_UUID]];
	CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
	[centralManager scanForPeripheralsWithServices:services options:nil];
	self.centralManager = centralManager;
    
    // Construct URL to sound file
    //NSString *path = [NSString stringWithFormat:@"%@/HRAlarm.mp3", [[NSBundle mainBundle] resourcePath]];
    NSString *path1 = [NSString stringWithFormat:@"%@/HRAlarm1.mp3", [[NSBundle mainBundle] resourcePath]];
    
    NSURL *soundUrl1 = [NSURL fileURLWithPath:path1];
    
    //NSString *path2 = [NSString stringWithFormat:@"%@/HRAlarm2.mp3", [[NSBundle mainBundle] resourcePath]];
    
    //NSURL *soundUrl2 = [NSURL fileURLWithPath:path2];
    
    // Create audio player object and initialize with URL to sound
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl1 error:nil];
    
    [_audioPlayer setVolume:1.0];
    
    //AVPlayerItem *item1 = [AVPlayerItem playerItemWithURL:soundUrl1];
    //AVPlayerItem *item2 = [AVPlayerItem playerItemWithURL:soundUrl2];
    //_MyAudioPlayer = [[AVQueuePlayer alloc] initWithItems:@[item1 , item2]];
    
    //HeartRate Curve
    [self.view addSubview:self.refreshMoniterView];
    
    //Read HeartRate data from data.txt
    void (^createData)(void) = ^{
        NSString *tempString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
        
        NSMutableArray *tempData = [[tempString componentsSeparatedByString:@","] mutableCopy];
        [tempData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSNumber *tempDataa = @(-[obj integerValue] + 2048);
            [tempData replaceObjectAtIndex:idx withObject:tempDataa];
        }];
        self.dataSource = tempData;
    };
    createData();
}

- (void)timerRefresnFun
{
    [[PointContainer sharedContainer] addPointAsRefreshChangeform:[self bubbleRefreshPoint]];
    
    [self.refreshMoniterView fireDrawingWithPoints:[PointContainer sharedContainer].refreshPointContainer pointsCount:[PointContainer sharedContainer].numberOfRefreshElements];
}

#pragma mark - bubble datasource

- (CGPoint)bubbleRefreshPoint
{
    static NSInteger dataSourceCounterIndex = -1;
    dataSourceCounterIndex ++;
    dataSourceCounterIndex %= [self.dataSource count];
    
    
    //NSInteger pixelPerPoint = 1;
    NSInteger pixelPerPoint = 2;

    static NSInteger xCoordinateInMoniter = 0;
    
    CGPoint targetPointToAdd = (CGPoint){xCoordinateInMoniter,[self.dataSource[dataSourceCounterIndex] integerValue] * 0.5 + 120};
    
    xCoordinateInMoniter += pixelPerPoint;
    xCoordinateInMoniter %= (int)(CGRectGetWidth(self.refreshMoniterView.frame));
    
    //NSLog(@"Simulation data : %@",NSStringFromCGPoint(targetPointToAdd));
    
    return targetPointToAdd;
}

/*
- (CGPoint)bubbleTranslationPoint
{
    static NSInteger dataSourceCounterIndex = -1;
    dataSourceCounterIndex ++;
    dataSourceCounterIndex %= [self.dataSource count];
    
    
    NSInteger pixelPerPoint = 1;
    static NSInteger xCoordinateInMoniter = 0;
    
    CGPoint targetPointToAdd = (CGPoint){xCoordinateInMoniter,[self.dataSource[dataSourceCounterIndex] integerValue] * 0.5 + 120};
    xCoordinateInMoniter += pixelPerPoint;
    //xCoordinateInMoniter %= (int)(CGRectGetWidth(self.translationMoniterView.frame));
    
    //    NSLog(@"吐出来的点:%@",NSStringFromCGPoint(targetPointToAdd));
    return targetPointToAdd;
}
*/

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    //HRMSetting *User = [segue destinationViewController];
    //_UserAge = User.HR_UserAge;
    //_UserName = User.HR_UserName;
    //NSLog(@"Segue : passing data");
    
    if([[segue identifier] isEqualToString:@"SegueForSetting"])
    {
        HRMSetting *User = [segue destinationViewController];
        [User setDelegate:self];
        
        if(InitialUserData == 0)
        {
            InitialUserData = 1;
            User.HR_UserName = @"";
            User.HR_UserAge = @"";
            User.APPConfig = Sports + TargetZoneAlarm + HRNotification;
            NSLog(@"Initial User data");
        }
        else
        {
            User.APPConfig = self.APPConfig;
        }
    }
}

- (IBAction)DrawHeartRateCurve:(id)sender {
    if([[self.CustomButton currentTitle] isEqualToString:@"Start"])
    {
        if(self.polarH7HRMPeripheral == nil)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"HeartRate Monitor" message:@"Heart Rate Sensor not found!" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
            [alert show];
        }
        else
        {
            [DrawHRCurve invalidate];
        
            DrawHRCurve = [NSTimer scheduledTimerWithTimeInterval:drawHeartRateCurveTimeInterval target:self selector:@selector(timerRefresnFun) userInfo:nil repeats:YES];
        
            [self.CustomButton setTitle:@"Stop" forState:UIControlStateNormal];
        }
    }
    else if([[self.CustomButton currentTitle] isEqualToString:@"Stop"])
    {
        if([DrawHRCurve isValid])
            [DrawHRCurve invalidate];
        
        [self.CustomButton setTitle:@"Start" forState:UIControlStateNormal];
    }
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
    
    //NSLog(@"Connected : YES");
    
    if([self.connected rangeOfString:@"YES"].location != NSNotFound)
    {
        [self.sensorsTable reloadData];
    }
    
    #ifdef StartAnimationIfConnected
    [self doHeartBeat];
    self.pulseTimer = [NSTimer scheduledTimerWithTimeInterval:(60. / HeartRatePulseTimer) target:self selector:@selector(doHeartBeat) userInfo:nil repeats:NO];
    #endif
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    if(!(error))
    {
        //NSLog(@"ooxx  Error 1");
    }
    else{
        NSLog(@"Peripherl state = %d",peripheral.state);
        #ifdef StartAnimationIfConnected
        if([self.pulseTimer isValid])
        {
            [self.pulseTimer invalidate];
            NSLog(@"ooxx  Error ");
            
            if(peripheral.state == 0)//Disconnected
            {
                self.polarH7HRMPeripheral = nil;
            }
        }
        #endif
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
        //if (([localName isEqual:@"HR Sensor306125"]) || ([localName isEqual:@"CSR HR Sensor"])) {
        if (([localName isEqual:@"HR Sensor306125"]) || ([localName isEqual:@"CSR HR Sensor"]) || ([localName isEqual:@"HRM"])) {
            // We found the Heart Rate Monitor
            [self.centralManager stopScan];
            if(self.polarH7HRMPeripheral == nil)
                self.polarH7HRMPeripheral = peripheral;
            peripheral.delegate = self;
            [self.centralManager connectPeripheral:peripheral options:nil];
            //[self.sensorsTable reloadData];
            
            //NSLog(@"Find HRM-10");
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
        
        #ifndef StartAnimationIfConnected
            self.heartRateBPM.text = [NSString stringWithFormat:@"%i", bpm];
            self.heartRateBPM.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:28];
       
            [self doHeartBeat];
            self.pulseTimer = [NSTimer scheduledTimerWithTimeInterval:(60. / self.heartRate) target:self selector:@selector(doHeartBeat) userInfo:nil repeats:NO];
        #endif
	}
    
    //Update HR_bpm data
    self.HR_bpm.text = [NSString stringWithFormat:@"%i bpm", bpm];
    
    if(bpm > ((int)self.maxAlarmStepper.value))
    //if(bpm > 90)//Debug
    {
        self.CountError++;
        if(self.CountError >= 3)
        {
            self.CountError = 0;
            [_audioPlayer play];
            
            //NSLog(@"Play audio 1,%d",_MyAudioPlayer.status);
        }
    }
    else if(bpm < ((int)self.minAlarmStepper.value))
    //else if(bpm < 80)
    {
        self.CountError++;
        if(self.CountError >= 3)
        {
            self.CountError++;
            [_audioPlayer play];
            
            //NSLog(@"Play audio 2");
        }
    }
    else{
        if(self.CountError < 3 && self.CountError != 0)
            self.CountError = 0;
    }
    
    //Update Max & Min Heart Rate value
    if(currentMaxHR == 0 && currentMinHR == 0)
    {
        currentMinHR = currentMaxHR = [self.HR_bpm.text intValue];
    }
    else
    {
        if(currentMaxHR == currentMinHR)
        {
            int temp = currentMinHR;
            int currentHR = [self.HR_bpm.text intValue];
            
            if(currentHR == temp)
                return;
            
            if(currentHR > temp)
            {
                currentMaxHR = currentHR;
                currentMinHR = temp;
            }
            else
            {
                currentMinHR = currentHR;
                currentMaxHR = temp;
            }
            
            self.minAlarmLabel.text = [NSString stringWithFormat:@"Min %d",currentMinHR];
            self.maxAlarmLabel.text = [NSString stringWithFormat:@"Max %d",currentMaxHR];
        }
        else
        {
            int currentHR = [self.HR_bpm.text intValue];
            
            if(currentHR >= currentMaxHR)
            {
                currentMaxHR = currentHR;
                self.maxAlarmLabel.text = [NSString stringWithFormat:@"Max %d",currentMaxHR];
            }
            else
            {
                if(currentHR < currentMinHR)
                {
                    currentMinHR = currentHR;
                    self.minAlarmLabel.text = [NSString stringWithFormat:@"Min %d",currentMinHR];
                }
            }
        }
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
    if(self.polarH7HRMPeripheral == nil)
        return;
    
	CALayer *layer = [self heartImage].layer;
	CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
	pulseAnimation.toValue = [NSNumber numberWithFloat:1.1];
	pulseAnimation.fromValue = [NSNumber numberWithFloat:1.0];
	
    #ifdef StartAnimationIfConnected
        pulseAnimation.duration = AnimationDuration;
    #else
        pulseAnimation.duration = 60. / self.heartRate / 2.;
    #endif
    
    pulseAnimation.repeatCount = 1;
	pulseAnimation.autoreverses = YES;
	pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
	[layer addAnimation:pulseAnimation forKey:@"scale"];
	
    #ifdef StartAnimationIfConnected
        self.pulseTimer = [NSTimer scheduledTimerWithTimeInterval:(60. / HeartRatePulseTimer) target:self selector:@selector(doHeartBeat) userInfo:nil repeats:NO];
            //NSLog(@"%d,%f",self.heartRate,pulseAnimation.duration);
    #else
        self.pulseTimer = [NSTimer scheduledTimerWithTimeInterval:(60. / self.heartRate) target:self selector:@selector(doHeartBeat) userInfo:nil repeats:NO];
    #endif
    
    //NSLog(@"%d,%f",self.heartRate,pulseAnimation.duration);
}

// handle memory warning errors
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            //UIFont *myFont = [ UIFont fontWithName: @"Arial" size: 18.0 ];
            UIFont *myFont = [ UIFont fontWithName: @"ArialRoundedMTBold" size: 18.0 ];
            
            if([indexPath row] == 0)
            {
                if ([[peripheral name] length])
                {
                    cell.textLabel.font = myFont;
                    [[cell textLabel] setText:[peripheral name]];
                }
                
                //cell.imageView.image = [UIImage imageNamed:@"heart_monitor.png"];
                
                [[cell imageView] setImage:[UIImage imageNamed:@"heart_monitor.png"]];
            }
            else if([indexPath row] == 1)
            {
                cell.textLabel.font = myFont;
                [[cell textLabel] setText:self.connected];
                
                //cell.imageView.image = [UIImage imageNamed:@"bluetooth.png"];
                
                [[cell imageView] setImage:[UIImage imageNamed:@"bluetooth.png"]];
            }
            else if([indexPath row] == 2)
            {
                cell.textLabel.font = myFont;
                [[cell textLabel] setText:self.bodyData];
                
                cell.imageView.image = [UIImage imageNamed:@"running.png"];
            }
            else if([indexPath row] == 3)
            {
                cell.textLabel.font = myFont;
                [[cell textLabel] setText:self.manufacturer];
                
                cell.imageView.image = [UIImage imageNamed:@"factory.png"];
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

#pragma mark -
#pragma mark MailComposeController delegates
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
    NSLog(@"Email ok");
}

#pragma mark - passUserSetting protocol methods
/****************************************************************************/
/*			     passUserSetting protocol methods						    */
/****************************************************************************/
-(void)setName : (NSString *)User_Name
{
    _UserName = User_Name;
}

-(void)setAge : (NSString *)User_Age;
{
    _UserAge = User_Age;
}

-(void)APPSetting : (int)Configdata;
{
    _APPConfig = Configdata;
    
    switch(self.APPConfig & ApplicationMode)
    {
        case (Normal):
            [self.navigationController.navigationBar.topItem setTitle:@"HeartRate_Normal"];
            break;
        case (Sports):
            [self.navigationController.navigationBar.topItem setTitle:@"HeartRate_Sports"];
            break;
        case (Sleep):
            [self.navigationController.navigationBar.topItem setTitle:@"HeartRate_Sleep"];
            break;
        default:
            break;
    }
}

-(void)passHeartRateData:(int)MaxHR SetMaxHR:(int)MaxHeartRate SetMinHR:(int)MinHeartRate RestHeartRate:(int)RHR UpperTargetHeartRate:(int)UpperTHR LowerTargetHeartRate:(int)LowerTHR
{
    /*int i = MaxHR;
    int j = MaxHeartRate;
    int k = MinHeartRate;
    int a = RHR;
    int b = UpperTHR;
    int c = LowerTHR;
    NSLog(@"%d,%d,%d,%d,%d,%d",i,j,k,a,b,c);*/
    
}
#pragma mark - My Test Code
/****************************************************************************/
/*							My Test Code								    */
/****************************************************************************/
- (IBAction)HR_Test:(id)sender {
    //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning!!" message:@"HeartRate value is too high" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //[alertView show];
    
    //[self.polarH7HRMPeripheral writeValue:<#(NSData *)#> forCharacteristic:<#(CBCharacteristic *)#> type:<#(CBCharacteristicWriteType)#>]
    
    //NSLog(@"Test Audio\n");
    //[_audioPlayer play];
    
    //Get Current time
    NSDate* now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:now];
    NSInteger hour = [dateComponents hour];
    NSString *am_OR_pm=@"AM";
    
    if (hour>12)
    {
        hour=hour%12;
        
        am_OR_pm = @"PM";
    }
    
    NSInteger minute = [dateComponents minute];
    NSInteger second = [dateComponents second];
    
    //[gregorian release];
    
    NSLog(@"Current Time  %@",[NSString stringWithFormat:@"%02d:%02d:%02d %@", hour, minute, second,am_OR_pm]);
    
    NSDate *today = [NSDate date];
    NSLog(@"Today ==> %@\n",today);
    
    //Send E-mail
    /*
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    
    NSArray *emailAddress = [[NSArray alloc] initWithObjects:@"minglung.huang@merry.com.tw", nil];
    
    [mailComposer setToRecipients:emailAddress];
    [mailComposer setSubject:@"Test mail"];
    [mailComposer setMessageBody:@"Hello world!!\n Send from my APP\n" isHTML:NO];
    //[self presentModalViewController:mailComposer animated:YES];
    [self presentModalViewController:mailComposer animated:NO];
     */
    //End of Send E-mail
    
    //NSLog(@"%@",_UserName);
    //NSLog(@"%@",_UserAge);
    
    //CGPoint position = self.Test_button.frame.origin;
    //NSLog(@"Button.x = %f",position.x);
    //NSLog(@"Button.y = %f",position.y);
    
    //NSLog(@"APP Config = %d",self.APPConfig);

}
@end