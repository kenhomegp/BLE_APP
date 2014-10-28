//
//  BLETabBarController.h
//  MerryBLEtool
//
//  Created by merry on 13-12-18.
//  Copyright (c) 2013年 merry. All rights reserved.
//

#import "HRMViewController.h"
#import <AVFoundation/AVFoundation.h>

#define APPStateNormal          1
#define APPStateUserConfig      2

#define drawHeartRateCurveTimeInterval  0.01
#define StartAnimationIfConnected

#define AnimationDuration   0.25
#define HeartRatePulseTimer 100

#define DrawRealHeartRateCurve
#define DrawSimulationHRCurvex

static uint16_t currentMaxHR = 0;
static uint16_t currentMinHR = 0;
static double TotalDistance  = 0;
static double TotalTime = 0;
static double TotalCalories = 0;

//@interface HRMViewController () <UITableViewDataSource, UITableViewDelegate>
@interface HRMViewController ()
{
    AVAudioPlayer *_audioPlayer;
    NSTimer *DrawHRCurve;
    AVAudioPlayer *SoftMusic;
    //AVQueuePlayer *_MyAudioPlayer;
    int AlarmMaxHeartRate;
    int AlarmMinHeartRate;
    NSTimer *SportsTimer;    // Store the timer that fires after a certain time
    NSDate *startDate;      // Stores the date of the click on the start button
    UISwipeGestureRecognizer *swipeRight;
    NSTimer *CaloriesBurnedTimer;
    CLLocationManager *locationManager;
    CLLocation *previousLocation;
}
@end

@implementation HRMViewController

- (HeartLive *)refreshMoniterView
{
    if (!_refreshMoniterView) {
        //CGFloat xOffset = 20;
        CGFloat xOffset = 74;
        _refreshMoniterView = [[HeartLive alloc] initWithFrame:CGRectMake(xOffset, 800, CGRectGetWidth(self.view.frame) - 2 * xOffset, 200)];
        //_refreshMoniterView.backgroundColor = [UIColor blackColor];
        _refreshMoniterView.backgroundColor = [UIColor whiteColor];
        
        //NSLog(@"HeartRateCurveView width = %f, heigth = 200",CGRectGetWidth(self.view.frame) - 2 * xOffset);//620(768-74*2=768-148=620) x 200
    }
    return _refreshMoniterView;
}

- (void)viewWillDisappear:(BOOL)animated
{
    if([DrawHRCurve isValid])
    {
        [DrawHRCurve invalidate];
        //NSLog(@"HRCurve timer invalidate");
    }
    
    if([self.pulseTimer isValid])
    {
        [self.pulseTimer invalidate];
        //NSLog(@"pulse timer invalidate");
    }
    
    if(self.polarH7HRMPeripheral == nil)
    {
        [SportsTimer invalidate];
        [CaloriesBurnedTimer invalidate];
    }
    
    //NSLog(@"wiewWillDisappear");
}

- (void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"viewWillAppear,%@",self.APPState);
    
    if(self.polarH7HRMPeripheral != nil)
    {
        if(!([self.pulseTimer isValid]))
        {
            self.pulseTimer = [NSTimer scheduledTimerWithTimeInterval:(60. / HeartRatePulseTimer) target:self selector:@selector(doHeartBeat) userInfo:nil repeats:NO];
            
            //NSLog(@"Recover pulse Timer if BT link is connected");
        }
        
        #ifdef DrawSimulationHRCurve
        if((!([DrawHRCurve isValid])) && ((self.APPConfig & StartActivity) == StartActivity))
        {
            DrawHRCurve = [NSTimer scheduledTimerWithTimeInterval:drawHeartRateCurveTimeInterval target:self selector:@selector(timerRefresnFun) userInfo:nil repeats:YES];
            
            //NSLog(@"Timer unexpected stop");
        }
        #endif
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //NSLog(@"viewDidLoad");
    
	// Do any additional setup after loading the view, typically from a nib.
    self.DeviceName = nil;
    self.polarH7HRMPeripheral = nil;
    self.connected = nil;
    self.UserName = @"";
    self.UserAge = @"";
    self.RestHeartRate = 0;
    AlarmMaxHeartRate = 70;//Default
    AlarmMinHeartRate = 50;
    
    //Gesture Regognizer
    swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self  action:@selector(swipeRecognized:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];
    
    //Navigation View title
    //[self.navigationController.navigationBar.topItem setTitle:@"HeartRate_Sports"];
    self.title = @"心跳即時資訊";
    
    //[self.navigationController.navigationBar setTintColor:[UIColor redColor]];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Jogging"]];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Jogging"]]];
    
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"nav_bg_ios7"]];
    
    //Custom button
    [self.CustomButton setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    [self.CustomButton setBackgroundImage:[UIImage imageNamed:@"buttonHighlighted.png"] forState:UIControlStateHighlighted];
    
    //Color,Image
	[self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	[self.heartImage setImage:[UIImage imageNamed:@"HeartImage"]];
    //[self.heartImage setImage:[UIImage imageNamed:@"Jogging"]];
    //[self.Image_Connected setImage:[UIImage imageNamed:@"DeviceConnected"]];
    [self.Image_Connected setImage:[UIImage imageNamed:@"Disconnected"]];
    
    if([CLLocationManager locationServicesEnabled])
    {
        [self.Image_GPS setImage:[UIImage imageNamed:@"GPS_On"]];
    }
    else
    {
        [self.Image_GPS setImage:[UIImage imageNamed:@"GPS_Off"]];
    }
    
    [self.Image_Battery setImage:[UIImage imageNamed:@"Battery"]];
    //[self.BackgroundImage setImage:[UIImage imageNamed:@"Jogging"]];
    [self.BackgroundImage setImage:[UIImage imageNamed:@"Jogging1"]];
    [self.BackgroundImage addSubview:self.heartImage];
    [self.BackgroundImage addSubview:self.HR_bpm];
	
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
    
    NSString *path2 = [NSString stringWithFormat:@"%@/SoftMusic.mp3", [[NSBundle mainBundle] resourcePath]];
    
    NSURL *soundUrl2 = [NSURL fileURLWithPath:path2];
    
    // Create audio player object and initialize with URL to sound
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl1 error:nil];
    
    [_audioPlayer setVolume:1.0];
    
    SoftMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl2 error:nil];
    
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
    
    //Load User data(NSUserDefaults)
    if(!([self LoadUserData]))
    {
        [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(GotoUserConfig) userInfo:nil repeats:NO];
    }
    
    //Get GPS Location
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
}

- (void)swipeRecognized:(UISwipeGestureRecognizer *)swipe
{
    if(swipe.direction == UISwipeGestureRecognizerDirectionRight)
    {
        //NSLog(@"Swipe Right Recognized");
        
        //[self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"GoogleMap"] animated:YES];
        
        HRMapView *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GoogleMap"];
        [vc setDelegate:self];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)timerRefresnFun
{
    [[PointContainer sharedContainer] addPointAsRefreshChangeform:[self bubbleRefreshPoint]];
    
    [self.refreshMoniterView fireDrawingWithPoints:[PointContainer sharedContainer].refreshPointContainer pointsCount:[PointContainer sharedContainer].numberOfRefreshElements];
    
    //NSLog(@"pointsCount = %d",[PointContainer sharedContainer].numberOfRefreshElements);
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
    
#ifdef DrawRealHeartRateCurve
    CGPoint targetPointToAdd;
    if([self.DeviceName isEqualToString:@"HR Sensor306125"])
    {
        targetPointToAdd = (CGPoint){xCoordinateInMoniter,(130-self.heartRate)*3}; //CSR1010 EVB
    }
    else
    {
        //For demo(Max HeartRate : 100 bpm)
        if((self.heartRate < 100) && (self.heartRate > 30))
        {
            targetPointToAdd = (CGPoint){xCoordinateInMoniter,(100-self.heartRate)*3}; //i-gotU HRM-10(藍牙心率監測器)
        }
        else{
            targetPointToAdd = (CGPoint){xCoordinateInMoniter,(100-60)*3};
        }
    }
#else
    CGPoint targetPointToAdd = (CGPoint){xCoordinateInMoniter,[self.dataSource[dataSourceCounterIndex] integerValue] * 0.5 + 120};
    //First point(-2071+2048)*0.5+120 = -23*0.5+120 = -11.5+120= 108.5
#endif
    
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

- (void) GotoUserConfig
{
    [self.Test1Button sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    //HRMSetting *vc;
    //vc = [self.storyboard instantiateViewControllerWithIdentifier:@"HRSetting"];
    //[self presentModalViewController:vc animated:YES];
}

- (bool) LoadUserData
{
    NSString *name,*age;
    int MaximumHR,SetRHR,UpperTHR,LowerTHR,SetMaxHR,SetMinHR,APPConfig;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    name = [userDefaults objectForKey:@"myHRMApp_Name"];
    age = [userDefaults objectForKey:@"myHRMApp_Age"];
    //NSLog(@"%@",name);
    //NSLog(@"%@",age);
    MaximumHR = [userDefaults integerForKey:@"myHRMApp_MaxHR"];
    SetRHR = [userDefaults integerForKey:@"myHRMApp_RHR"];
    //NSLog(@"%d",MaximumHR);
    //NSLog(@"%d",SetRHR);
    UpperTHR = [userDefaults integerForKey:@"myHRMApp_UpperTHR"];
    LowerTHR = [userDefaults integerForKey:@"myHRMApp_LowerTHR"];
    SetMaxHR = [userDefaults integerForKey:@"myHRMApp_SetMaxHR"];
    SetMinHR = [userDefaults integerForKey:@"myHRMApp_SetMinHR"];
    APPConfig = [userDefaults integerForKey:@"myHRMApp_APPConfig"];
    //NSLog(@"%d,%d,%d,%d,%d",UpperTHR,LowerTHR,SetMaxHR,SetMinHR,APPConfig);
    
    if(name == nil)
    {
        self.UserName = nil;
        self.UserAge = nil;
        self.RestHeartRate = 0;
        self.APPConfig = Sports + TargetZoneAlarm + HRNotification;
        self.APPConfig &= ~(BLE_Connected);
        self.APPConfig &= ~(StartActivity);
        AlarmMaxHeartRate = 70;
        AlarmMinHeartRate = 50;
        
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"HeartRate Monitor" message:@"User data not found!" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
        //[alert show];
        
        //[self.Test1Button sendActionsForControlEvents:UIControlEventTouchUpInside];
        
        return FALSE;
    }
    else
    {
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"HeartRate Monitor" message:name delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
        //[alert show];
        self.APPConfig = APPConfig;
        self.UserName = name;
        self.UserAge = age;
        self.RestHeartRate = SetRHR;
        AlarmMaxHeartRate = SetMaxHR;
        AlarmMinHeartRate = SetMinHR;
        return TRUE;
    }

}

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
        
        User.HR_UserAge = self.UserAge;
        User.HR_UserName = self.UserName;
        User.APPConfig = self.APPConfig;
        User.SetRHR = self.RestHeartRate;
        if(AlarmMaxHeartRate != 70)
            User.SetMaxHR = AlarmMaxHeartRate;
        if(AlarmMinHeartRate != 50)
            User.SetMinHR = AlarmMinHeartRate;
    }
    else if([[segue identifier] isEqualToString:@"SegueForHealthyCare"])
    {
        HRHealthyCare *vc = [segue destinationViewController];
        vc.APPConfig = self.APPConfig;
        //NSLog(@"Segue To HealthyCare View");
    }
    
    if([[segue identifier] isEqualToString:@"SegueForGoogleMap"])
    {
        HRMapView *vc = [segue destinationViewController];
        [vc setDelegate:self];
        vc.APPConfig = self.APPConfig;
        //NSLog(@"Segue To GoogleMap View");
    }
}

- (void)updateTimer
{
    // Create date from the elapsed time
    NSDate *currentDate = [NSDate date];
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:startDate];
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    // Create a date formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@"HH:mm:ss.SSS"];
    [dateFormatter setDateFormat:@"時間 : HH時:mm分:ss秒"];
    //[dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    // Format the elapsed time and set it to the label
    NSString *timeString = [dateFormatter stringFromDate:timerDate];
    //self.stopwatchLabel.text = timeString;
    //NSLog(@"%@",timeString);
    self.SportsTimeLabel.text = timeString;
    
    TotalTime = timeInterval;
    //NSLog(@"TT = %f",timeInterval);
}

- (void)CaloriesBurned
{
    double calories;
    calories = (((-55.0969+(0.6309*self.heartRate)+(0.1988*70)+(0.2017*35))/4.184)*60*5)/3600;
    
    if(calories > 0)
    {
        //NSLog(@"Calorie = %f,%d",calories,self.heartRate);
        TotalCalories += calories;
    }
    
    self.MileageLabel.text = [NSString stringWithFormat:@"里程數 : %2.2f公里",(TotalDistance/1000)];
    
    self.BurnCalorieLabel.text = [NSString stringWithFormat:@"燃燒卡路里 : %5.1f",TotalCalories];
    
}

- (IBAction)DrawHeartRateCurve:(id)sender {
    
    //if([[self.CustomButton currentTitle] isEqualToString:@"Start"])
    if([[self.CustomButton currentTitle] isEqualToString:@"開始跑步"])
    {
        if(self.polarH7HRMPeripheral == nil)
        {
            //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"HeartRate Monitor" message:@"Heart Rate Sensor not found!" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
            
            //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"心跳偵測" message:@"無法找到裝置!" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil, nil];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HRM", @"AlertViewTitle") message:NSLocalizedString(@"Device", @"AlertMessage") delegate:self cancelButtonTitle:NSLocalizedString(@"End", @"Test") otherButtonTitles:nil, nil];
            
            [alert show];
            
            //NSLog(@"%@",self.APPState);
        }
        else
        {
            #ifdef DrawSimulationHRCurve
            [DrawHRCurve invalidate];
        
            DrawHRCurve = [NSTimer scheduledTimerWithTimeInterval:drawHeartRateCurveTimeInterval target:self selector:@selector(timerRefresnFun) userInfo:nil repeats:YES];
            #endif
            
            startDate = [NSDate date];
            SportsTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/2.0
                                             target:self
                                           selector:@selector(updateTimer)
                                           userInfo:nil
                                            repeats:YES];
            
            [CaloriesBurnedTimer invalidate];
            CaloriesBurnedTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                                   target:self
                                                                 selector:@selector         (CaloriesBurned)
                                                                 userInfo:nil
                                                                  repeats:YES];
        
            //[self.CustomButton setTitle:@"Stop" forState:UIControlStateNormal];
            [self.CustomButton setTitle:@"運動結束" forState:UIControlStateNormal];
            
            self.APPConfig |= StartActivity;
            
            [locationManager startUpdatingLocation];
        }
    }
    //else if([[self.CustomButton currentTitle] isEqualToString:@"Stop"])
    else if([[self.CustomButton currentTitle] isEqualToString:@"運動結束"])
    {
        #ifdef DrawSimulationHRCurve
            if([DrawHRCurve isValid])
                [DrawHRCurve invalidate];
        #endif
        
        if([SportsTimer isValid])
        {
            [SportsTimer invalidate];
            SportsTimer = nil;
            self.SportsTimeLabel.text = @"時間 : 00時:00分:00秒";
        }
        
        if([CaloriesBurnedTimer isValid])
        {
            [CaloriesBurnedTimer invalidate];
            TotalDistance = 0;
            TotalTime = 0;
            TotalCalories = 0;
            self.MileageLabel.text = @"里程數 : 00公里";
            self.BurnCalorieLabel.text = @"燃燒卡路里 : 00000卡";
        }
        
        self.APPConfig &= ~(StartActivity);
        
        //[self.CustomButton setTitle:@"Start" forState:UIControlStateNormal];
        [self.CustomButton setTitle:@"開始跑步" forState:UIControlStateNormal];
        
        // Stop Location Manager
        [locationManager stopUpdatingLocation];

    }
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
        
        [self.Image_Connected setImage:[UIImage imageNamed:@"DeviceConnected"]];
        
        self.APPConfig |= BLE_Connected;

    }
    
    #ifdef StartAnimationIfConnected
    [self doHeartBeat];
    self.pulseTimer = [NSTimer scheduledTimerWithTimeInterval:(60. / HeartRatePulseTimer) target:self selector:@selector(doHeartBeat) userInfo:nil repeats:NO];
    #endif
    
    //[self.Image_Connected setImage:[UIImage imageNamed:@"DeviceConnected"]];
}

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error
{
    if(!(error))
    {
        
    }
    else{
        //NSLog(@"Peripherl state = %d",peripheral.state);
        #ifdef StartAnimationIfConnected
        if([self.pulseTimer isValid])
        {
            [self.pulseTimer invalidate];
            
            if(peripheral.state == 0)//Disconnected
            {
                self.polarH7HRMPeripheral = nil;
                
                self.APPConfig &= ~(BLE_Connected);
                
                [self.Image_Connected setImage:[UIImage imageNamed:@"Disconnected"]];

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
            
            self.DeviceName = localName;
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
    

#ifdef DrawRealHeartRateCurve
    
    [[PointContainer sharedContainer] addPointAsRefreshChangeform:[self bubbleRefreshPoint]];
    
    [self.refreshMoniterView fireDrawingWithPoints:[PointContainer sharedContainer].refreshPointContainer pointsCount:[PointContainer sharedContainer].numberOfRefreshElements];

#endif
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
    
    
    //if(bpm > ((int)self.maxAlarmStepper.value))
    //if(bpm > 90)//Debug
    if(bpm > AlarmMaxHeartRate)
    {
        self.CountError++;
        if(self.CountError >= 3)
        {
            self.CountError = 0;
            
            if((self.APPConfig & ApplicationMode) == Normal)
            {
                [_audioPlayer play];
            }
            else if((self.APPConfig & ApplicationMode) == Sleep)
            {
                if(SoftMusic.playing == NO)
                    [SoftMusic play];
            }
            
            //NSLog(@"Play audio 1,%d",_MyAudioPlayer.status);
        }
    }
    //else if(bpm < ((int)self.minAlarmStepper.value))
    //else if(bpm < 80)
    else if(bpm < AlarmMinHeartRate)
    {
        self.CountError++;
        if(self.CountError >= 3)
        {
            self.CountError = 0;
            
            if((self.APPConfig & ApplicationMode) == Normal)
            {
                [_audioPlayer play];
            }
            else if((self.APPConfig & ApplicationMode) == Sleep)
            {
                if(SoftMusic.playing == NO)
                    [SoftMusic play];
            }
            
            //NSLog(@"Play audio 2");
        }
    }
    else
    {
        if(_audioPlayer.playing)
            [_audioPlayer stop];
        
        if(SoftMusic.playing)
            [SoftMusic stop];
        
        if(self.CountError < 3 && self.CountError != 0)
        {
            self.CountError = 0;
        }
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

/*
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
*/

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
    //NSLog(@"Email ok");
}


#pragma mark - passMapPositionDelegate methods
-(void) passDistance : (double)Map_distance
{
    //NSLog(@"pass Map distance");
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
    
    HRHealthyCare *vc;
    
    switch(self.APPConfig & ApplicationMode)
    {
        case (Normal):
            //[self.HealthyCareViewButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            if(SoftMusic.playing == YES)
                [SoftMusic stop];
            
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"HealthyCare"];
            vc.APPConfig = self.APPConfig;
            
            [self.navigationController pushViewController:vc animated:YES];
            break;
        case (Sports):
            if(_audioPlayer.playing == YES)
                [_audioPlayer stop];
            if(SoftMusic.playing == YES)
                [SoftMusic stop];
            break;
        case (Sleep):
            //[self.HealthyCareViewButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            if(_audioPlayer.playing == YES)
                [_audioPlayer stop];
            
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"HealthyCare"];
            vc.APPConfig = self.APPConfig;
            
            [self.navigationController pushViewController:vc animated:YES];
            break;
        default:
            break;
    }
    
    //NSLog(@"APP Config changed!");
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
    
    AlarmMaxHeartRate = MaxHeartRate;
    AlarmMinHeartRate = MinHeartRate;
    
    //NSLog(@"HeartRate data changed!");
}

#pragma mark - CLLocationManager delegate and related methods
/*
double getDistanceMetresBetweenLocationCoordinates(
                                                   CLLocationCoordinate2D coord1,
                                                   CLLocationCoordinate2D coord2)
{
    CLLocation* location1 =
    [[CLLocation alloc]
     initWithLatitude: coord1.latitude
     longitude: coord1.longitude];
    CLLocation* location2 =
    [[CLLocation alloc]
     initWithLatitude: coord2.latitude
     longitude: coord2.longitude];
    
    return [location1 distanceFromLocation: location2];
}
*/

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    //NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    double distance;
    
    if (currentLocation != nil) {
        //longitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        //latitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        
        //NSString *longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        //NSString *latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        
        //distance = [newLocation distanceFromLocation:oldLocation];
        distance = [newLocation distanceFromLocation:previousLocation];
        
        //NSLog(@"Map : %@,%@,%f",latitude,longitude,distance);
        
        if(distance != 0)
        {
            previousLocation = currentLocation;
            TotalDistance += distance;
        }
    }
    
    // Stop Location Manager
    //[locationManager stopUpdatingLocation];
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
    /*
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
    */
    
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
    
    /*
    if((self.APPConfig & ApplicationMode) == Sleep)
    {
        if(SoftMusic.playing == NO)
            [SoftMusic play];
        else
            [SoftMusic stop];
    }
    else if((self.APPConfig & ApplicationMode) == Normal)
    {
        if(_audioPlayer.playing == NO)
            [_audioPlayer play];
        else
            [_audioPlayer stop];
    }
     */
    
    //[self.CustomButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    //[self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"HealthyCare"] animated:YES];

}
@end