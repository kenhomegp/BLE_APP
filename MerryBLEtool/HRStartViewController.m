//
//  HRStartViewController.m
//  MyHRM
//
//  Created by merry on 14-11-9.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import "HRStartViewController.h"
#import "HRMViewController.h"
#import "HRHealthyCare.h"
#import "HRMSetting.h"

#import "HRMSetting.h"
#import "AppDelegateProtocol.h"
#import "HRMDataObject.h"

#import "CustomHeaderCell.h"

#import <sys/types.h>
#import <sys/sysctl.h>

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

#import <AVFoundation/AVFoundation.h>

#define BLEScanTime 16
#define AlertViewTimeout 10.0

@interface HRStartViewController ()
{
    NSTimer *ScanTimer;
    NSTimer *AlertTimer;
    NSInteger Count10sec;
    NSInteger IndexSetAccessoryCheckmark;
    UIAlertView *myAlert;
    UIActivityIndicatorView *spinner;
    NSInteger PlatNumber;
    NSTimer *TestTimer;
#ifdef CustomBLEService
    bool TestSwitch;
    bool LEDSwitch;
    bool BuzzerSwitch;
    CLLocationManager *locationManager;
    CLLocationDegrees Linkloss_latitude;
    CLLocationDegrees Linkloss_longitude;
    AVAudioPlayer *_audioPlayer;
    NSString *DevBattLevel;
#endif
}
@end

@implementation HRStartViewController

#ifdef CustomBLEService
@synthesize myLatitude;
@synthesize myLongitude;
#endif

#ifdef BLE_Debug
#pragma mark - CoreBTDelegate
-(void) logBLEMessage:(NSString *)message
{
    self.Log = [self.Log stringByAppendingFormat:@"%@\n",message];
}
#endif

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)//Button : No
    {
        //NSLog(@"btn index 0");
        IndexSetAccessoryCheckmark = 0;
        [AlertTimer invalidate];
    }
    else{               //Button : Yes
        //NSLog(@"btn index 1");
        [AlertTimer invalidate];
        if([self.CBStatus isEqualToString:@"Scan..."])
        {
            if(IndexSetAccessoryCheckmark != 0)
            {
                #ifdef BLE_Debug
                
                #else
                    [CoreBTObj ConnectHRMDevice:self.LastConnectDevice];
                #endif
            }
            
        }
        else if([self.CBStatus isEqualToString:@"Disconnected"])
        {
            self.CBStatus = @"Scan...";
            self.BLE_device1 = nil;
            self.BLE_device2 = nil;
            self.BLE_device3 = nil;
            IndexSetAccessoryCheckmark = 0;
            [self.tableView reloadData];
            
            #ifdef BLE_Debug
            
            #else
                [CoreBTObj ScanHRMDevice];
            #endif
            
            ScanTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                     target:self selector:@selector(ScanBLEPeripheral)
                                                   userInfo:nil repeats:YES];
            [spinner startAnimating];
            Count10sec = BLEScanTime;
        }
        else if([self.CBStatus rangeOfString:@"Connected"].location != NSNotFound)
        {
            #ifdef BLE_Debug
            
            #else
            [CoreBTObj DisconnectHRM];
            #endif
        }
    }
}

-(void) CBStatusUpdate:(NSString *)BLE_Status BLEData:(NSString *)payload
{
    //NSLog(@"Test protocol 2 :%@",BLE_Device);
    if([BLE_Status isEqualToString:@"Scan"])
    {
        if(self.BLE_device1 == nil)
        {
            self.BLE_device1 = payload;
            [self.tableView reloadData];
        }
        else if((self.BLE_device2 == nil) && (!([payload isEqualToString:self.BLE_device1])))
        {
            self.BLE_device2 = payload;
            [self.tableView reloadData];
        }
        else if(self.BLE_device3 == nil)
        {
            if((!([payload isEqualToString:self.BLE_device1])) && (!([payload isEqualToString:self.BLE_device2])))
            {
                self.BLE_device3 = payload;
                [self.tableView reloadData];
            }
        }
        
        self.CBStatus = @"Scan...";
        //NSLog(@"Update device ,%@",payload);
    }
    else if([BLE_Status isEqualToString:@"Connected"])
    {
        self.CBStatus = [@"Connected : " stringByAppendingString:payload];
        [self.tableView reloadData];
        
        if([payload isEqualToString:@"YES"])
        {
            HRMDataObject* theDataObject = [self theAppDataObject];
            theDataObject.APPConfig |= BLE_Connected;
            if([ScanTimer isValid])
            {
                [ScanTimer invalidate];
                Count10sec = BLEScanTime;
                [spinner stopAnimating];
            }
            
            #ifdef CustomBLEService
            [locationManager startUpdatingLocation];
            //NSLog(@"Start location service!");
            ScanTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                         target:self selector:  @selector(EnableLocationService)
                                                       userInfo:nil repeats:YES];
            #endif
        }
        else if([payload isEqualToString:@"NO"])
        {
            HRMDataObject* theDataObject = [self theAppDataObject];
            theDataObject.APPConfig &= ~(BLE_Connected);
        }
    }
    else if([BLE_Status isEqualToString:@"Disconnected"])
    {
        self.CBStatus = @"Disconnected";
        self.BLE_device1 = nil;
        self.BLE_device2 = nil;
        self.BLE_device3 = nil;
        IndexSetAccessoryCheckmark = 0;
        [self.tableView reloadData];
        
        #ifdef CustomBLEService
        //NSLog(@"Stop location service!");
        [locationManager stopUpdatingLocation];
        if([ScanTimer isValid])
        {
            [ScanTimer invalidate];
        }
        
        [self.tabBarController setSelectedIndex:1];
        
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://kenhomegp@yahoo.com.tw"]];
        #endif
    }
    else if([BLE_Status isEqualToString:@"CustomBLEService"])
    {
        #ifdef CustomBLEService
            //self.CBStatus = @"CustomBLEService";
        
            if(TestSwitch)
            {
                TestSwitch = FALSE;
            }
            else
            {
                TestSwitch = TRUE;
            }
        
            [self.tableView reloadData];
        
            [_audioPlayer play];
        #endif
    }
    else if ([BLE_Status isEqualToString:@"BattUpdateLevel"])
    {
        #ifdef CustomBLEService
        DevBattLevel = payload;
        [self.tableView reloadData];
        #endif
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
#ifdef BLE_Debug
    
#else
    [CoreBTObj setViewController:0];
#endif
}

- (void)viewWillDisappear:(BOOL)animated
{
    [ScanTimer invalidate];
    [AlertTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //NSLog(@"viewDidLoad");
    
    // Assign our own backgroud for the view
    self.parentViewController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"common_bg"]];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    //self.title = @"應用類型";
    //self.title = @"Application Mode";
    
    self.title = NSLocalizedString(@"StartViewController", @"title");
    
    //Initial CoreBluetooth Framework
    self.BLE_device1 = nil;
    self.BLE_device2 = nil;
    self.BLE_device3 = nil;
    self.CBStatus = @"Scan...";
    self.LastConnectDevice = nil;
    
    PlatNumber = 0;
    PlatNumber = [self platformNumber];

    if(((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) && PlatNumber != 0) || ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && PlatNumber > 6))
    {
    #ifdef BLE_Debug
        CoreBTObj = [[BLECBTask alloc] init];
        [CoreBTObj controlSetup:1];
        CoreBTObj.delegate = self;
        CoreBTObj.activePeripheral = nil;
        self.Log = @"";
    #else
        CoreBTObj = [[HRMCBTask alloc] init];
        [CoreBTObj controlSetup];
        [CoreBTObj SetVC:0];
        CoreBTObj.delegate1 = self;
    
        ScanTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                target:self selector:@selector(ScanBLEPeripheral)
                userInfo:nil repeats:YES];
        Count10sec = BLEScanTime;
    
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        self.LastConnectDevice = [userDefaults objectForKey:@"myHRMApp_Device"];
    
        spinner = [[UIActivityIndicatorView alloc]
                                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            spinner.center = CGPointMake(390, 500);
        else
            spinner.center = CGPointMake(160, 240);
    
        spinner.hidesWhenStopped = YES;
        [self.view addSubview:spinner];
        [spinner startAnimating];
        
        #ifdef CustomBLEService
            LEDSwitch = FALSE;
            BuzzerSwitch = FALSE;
            locationManager = [[CLLocationManager alloc]init];
            locationManager.delegate = self;
            myLatitude = 0.0;
            myLongitude = 0.0;
            DevBattLevel = nil;
        
            // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
            if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
            {
                [locationManager requestWhenInUseAuthorization];
            }
        
            NSString *path1 = [NSString stringWithFormat:@"%@/HRAlarm1.mp3", [[NSBundle mainBundle] resourcePath]];
            NSURL *soundUrl1 = [NSURL fileURLWithPath:path1];
            _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl1 error:nil];
            [_audioPlayer setVolume:1.0];
        #endif
    #endif
    }
    else
    {
        //NSLog(@"Not support BLE!!,%ld",(long)PlatNumber);
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            PlatNumber = 0;
        
        //TestTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
        //                                             target:self selector:@selector(TestTest)
          //                                         userInfo:nil repeats:YES];
        
        /*
        [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(APPStateChanged:)
        name:UIApplicationWillResignActiveNotification
        object:nil];*/
    }
    
    if((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && PlatNumber != 0)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(APPStateChanged:)
        name:UIApplicationWillResignActiveNotification object:nil];
    }
}

- (void)DismissAlertView
{
    [myAlert dismissWithClickedButtonIndex:0 animated:YES];
}

- (NSInteger)CountBLEDevice
{
    NSInteger cc = 0;
    if(self.BLE_device1 != nil)
        cc++;
    if(self.BLE_device2 != nil)
        cc++;
    if(self.BLE_device3 != nil)
        cc++;
    
    //if(cc == 1)
    //    IndexSetAccessoryCheckmark = 0;
    
    return cc;
}

- (void)APPStateChanged:(NSNotification *)notification
{
    if([self.CBStatus isEqualToString:@"Connected : YES"])
    {
        CTCallCenter *callCenter = [[CTCallCenter alloc] init];
        for (CTCall *call in callCenter.currentCalls)  {
            //if (call.callState == CTCallStateConnected) {
            if(call.callState ==  CTCallStateIncoming){
                //NSLog(@"### Incoming call..,Count 10 seconds");
                [self performSelector:@selector(PerformSelectorMethod) withObject:nil afterDelay:5.0f];
            }
        }
    }
}

- (void) PerformSelectorMethod
{
    CTCallCenter *callCenter = [[CTCallCenter alloc] init];
    for (CTCall *call in callCenter.currentCalls)
    {
        if(call.callState ==  CTCallStateIncoming)
        {
            //NSLog(@"Incoming call,Timeout!");
            [CoreBTObj WriteValueForCustomCharacteristic:FALSE OnOff:TRUE];
            [self performSelector:@selector(PerformSelectorMethod) withObject:nil afterDelay:3.0f];
        }
    }
}

- (void) TestTest
{
    UIApplicationState st = [[UIApplication sharedApplication] applicationState];
    NSLog(@"AppState = %ld",(long)st);
}

#ifdef CustomBLEService
- (void)EnableLocationService
{
    [locationManager startUpdatingLocation];
}
#endif

- (void)ScanBLEPeripheral
{
    if(Count10sec != 0)
    {
        Count10sec--;
        
        if(Count10sec == 9)
        {
            if(([self CountBLEDevice]) > 1)
            {
            if([self.BLE_device1 isEqualToString:self.LastConnectDevice])
            {
                IndexSetAccessoryCheckmark = 5;
                
                myAlert = [[UIAlertView alloc] initWithTitle:self.BLE_device1 message:@"Reconnect Last_connected device" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                
                [myAlert show];
                
                AlertTimer = [NSTimer scheduledTimerWithTimeInterval:AlertViewTimeout target:self selector:@selector(DismissAlertView) userInfo:nil repeats:NO];
            }
            if([self.BLE_device2 isEqualToString:self.LastConnectDevice])
            {
                IndexSetAccessoryCheckmark = 6;
                
                myAlert = [[UIAlertView alloc] initWithTitle:self.BLE_device2 message:@"Reconnect Last_connected device" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                
                [myAlert show];
                
                AlertTimer = [NSTimer scheduledTimerWithTimeInterval:AlertViewTimeout target:self selector:@selector(DismissAlertView) userInfo:nil repeats:NO];
            }
            if([self.BLE_device3 isEqualToString:self.LastConnectDevice])
            {
                IndexSetAccessoryCheckmark = 7;
                
                myAlert = [[UIAlertView alloc] initWithTitle:self.BLE_device3 message:@"Reconnect Last_connected device" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                
                [myAlert show];
                
                AlertTimer = [NSTimer scheduledTimerWithTimeInterval:AlertViewTimeout target:self selector:@selector(DismissAlertView) userInfo:nil repeats:NO];
            }
            }
        }
    }
    else{
        [ScanTimer invalidate];
        Count10sec = BLEScanTime;
        
        #ifdef BLE_Debug
        
        #else
            [CoreBTObj StopScanPeripheral];
        #endif
        
        [spinner stopAnimating];
        if([self.CBStatus isEqualToString:@"Scan..."])
        {
            self.CBStatus = @"Disconnected";
            self.BLE_device1 = nil;
            self.BLE_device2 = nil;
            self.BLE_device3 = nil;
            IndexSetAccessoryCheckmark = 0;
            [self.tableView reloadData];
            //NSLog(@"Scan time-out");
            //[spinner stopAnimating];
            
            //Sending a mail from iOS App
            //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto://kenhomegp@yahoo.com.tw"]];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    
    //HRMDataObject* theDataObject = [self theAppDataObject];
    HRMDataObject* theDataObject = [self theAppDataObject];
    theDataObject.APPConfig &= ~(ApplicationMode);
    
    if ([segue.identifier isEqualToString:@"SegueForHRM"]) {
        //NSIndexPath *indexPath = nil;
        //indexPath = [self.tableView indexPathForSelectedRow];
        //NSLog(@"HRM %ld",(long)indexPath.row);
        
        HRMViewController *vc = [segue destinationViewController];
        vc.APPConfig &= ~(ApplicationMode);
        vc.APPConfig |= Sports;
        vc.APPConfig |= BLE_Connected;
        
        #ifdef BLE_Debug
        
        #else
            vc.polarH7HRMPeripheral = CoreBTObj.activePeripheral;
        #endif
        
        theDataObject.APPConfig |= Sports;
        
        #ifdef BLE_Debug
        
        #else
            CoreBTObj.delegate2 = vc;
            [CoreBTObj SetVC:1];
        #endif
    }
    else if([segue.identifier isEqualToString:@"SegueForTest"])
    {
        indexPath = [self.tableView indexPathForSelectedRow];
        //NSLog(@"TEST %ld",(long)indexPath.row);
        
        HRHealthyCare *vc = [segue destinationViewController];
        vc.SeguePassingData = indexPath.row;
        
        vc.APPConfig &= ~(ApplicationMode);
        if(indexPath.row == 1)
        {
            vc.APPConfig |= Normal;
            theDataObject.APPConfig |= Normal;
        }
        else if(indexPath.row == 2)
        {
            vc.APPConfig |= Sleep;
            theDataObject.APPConfig |= Sleep;
        }
    }
    else if([[segue identifier] isEqualToString:@"SegueLogMessage"])
    {
        #ifdef BLE_Debug
        HRMTableSetting *User = [segue destinationViewController];
        User.Log = self.Log;
        #endif
    }

}

#pragma mark -
#pragma mark instance methods

- (HRMDataObject *) theAppDataObject;
{
    id<AppDelegateProtocol> theDelegate = (id<AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    HRMDataObject *theDataObject;
    theDataObject = (HRMDataObject*) theDelegate.theAppDataObject;
    return theDataObject;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return 13;
    else
        return 11;
}

- (UIImage *)cellBackgroundForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowCount = [self tableView:[self tableView] numberOfRowsInSection:0];
    NSInteger rowIndex = indexPath.row;
    UIImage *background = nil;
    
    if (rowIndex == 0) {
        background = [UIImage imageNamed:@"cell_top.png"];
    } else if (rowIndex == rowCount - 1) {
        background = [UIImage imageNamed:@"cell_bottom.png"];
    } else {
        background = [UIImage imageNamed:@"cell_middle.png"];
    }
    
    return background;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return 55;
    else
        return 23.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                return 70;
            }
            else if(indexPath.row == 1)
                return 70;
            else if (indexPath.row == 2)
                return 70;
            else if (indexPath.row == 3)
                return 70;
            else
                return 40;
        }
        else
            return 0;
    }
    else
    {
        #ifdef CustomBLEService
            return 70;
        #else
            return 100;
        #endif
    }
}


-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // 1. Dequeue the custom header cell
    CustomHeaderCell* headerCell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    
    // 2. Set the various properties
    headerCell.APP_Mode.text = @"Custom header from cell";
    [headerCell.APP_Mode sizeToFit];
    
    headerCell.Run_Frequency.text = @"The subtitle";
    [headerCell.Run_Frequency sizeToFit];
    
    headerCell.image.image = [UIImage imageNamed:@"TableTitle"];
    
    // 3. And return
    return headerCell;
}


/*
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 150;
        }
        else if(indexPath.row == 1)
            return 80;
        else if (indexPath.row == 2)
            return 80;
        else
            return 70;
    }
    return 44;
}*/


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UIImageView *APPImage = (UIImageView *)[cell viewWithTag:100];
    UILabel *APPTitle = (UILabel *)[cell viewWithTag:101];
    UILabel *APPDetail = (UILabel *)[cell viewWithTag:102];
    UILabel *APPUseFreq = (UILabel *)[cell viewWithTag:103];
    
    if(indexPath.row == 0)
    {
        APPImage.image = [UIImage imageNamed:@"Distance.png"];
        APPTitle.text = NSLocalizedString(@"TableViewCell1Title", @"");
        APPDetail.text = NSLocalizedString(@"TableViewCell1Detail", @"");
        APPUseFreq.text = @"60%";
    }
    else if(indexPath.row == 1)
    {
        APPImage.image = [UIImage imageNamed:@"AppHealthy.png"];
        APPTitle.text = NSLocalizedString(@"TableViewCell2Title", @"");
        APPDetail.text = NSLocalizedString(@"TableViewCell2Detail", @"");
        APPUseFreq.text = @"20%";
        
    }
    else if(indexPath.row == 2)
    {
        APPImage.image = [UIImage imageNamed:@"AppSleep.png"];
        APPTitle.text = NSLocalizedString(@"TableViewCell3Title", @"");
        APPDetail.text = NSLocalizedString(@"TableViewCell3Detail", @"");
        APPUseFreq.text = @"10%";
    }
    else if(indexPath.row == 3)
    {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            APPImage.image = [UIImage imageNamed:@"history2.png"];
            APPTitle.text = NSLocalizedString(@"TableViewCell4Title", @"");
            APPDetail.text = NSLocalizedString(@"TableViewCell4Detail", @"");
            APPUseFreq.text = @"10%";
        }
        else
        {
            #ifdef BLE_Debug
                APPTitle.text = @"BLE debug mode";
                APPDetail.text = nil;
                APPUseFreq.text = nil;
                [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            #else
                APPTitle.text = nil;
                APPDetail.text = nil;
                APPUseFreq.text = nil;
            #endif
        }
    }
    else if(indexPath.row == 4)
    {
        if(PlatNumber != 0)
        {
            #ifdef BLE_Debug
            //APPTitle.text = nil;
            APPTitle.text = @"LED On/Off";
            #else
            APPTitle.text = self.CBStatus;
            #endif
            APPDetail.text = nil;
            APPUseFreq.text = nil;
        }
        else
        {
            APPTitle.text = nil;
            APPDetail.text = nil;
            APPUseFreq.text = nil;
        }
    }
    else if(indexPath.row == 5)//Update three BLE devices here.
    {
        #ifdef BLE_Debug
        APPTitle.text = @"Buzzer";
        #else
        if(self.BLE_device1 != nil)
        {
            [APPTitle setTextColor:[UIColor blueColor]];
            APPTitle.text = self.BLE_device1;
        }
        else
        {
            APPTitle.text = nil;
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        if(cell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
            if([self.CBStatus isEqualToString:@"Connected : YES"])
            {
                if(self.LastConnectDevice == nil)
                {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:self.BLE_device1 forKey:@"myHRMApp_Device"];
                    [userDefaults synchronize];
                    self.LastConnectDevice = self.BLE_device1;
                }
                else
                {
                    if(!([self.LastConnectDevice isEqualToString:self.BLE_device1]))
                    {
                        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                        [userDefaults setObject:self.BLE_device1 forKey:@"myHRMApp_Device"];
                        [userDefaults synchronize];
                        self.LastConnectDevice = self.BLE_device1;
                    }
                }
            }
        }
        else
        {
            if([self.CBStatus isEqualToString:@"Connected : YES"])
            {
                if((cell.accessoryType == UITableViewCellAccessoryNone) && (IndexSetAccessoryCheckmark == indexPath.row) )
                {
                    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                    IndexSetAccessoryCheckmark = 0;
                    
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:self.BLE_device1 forKey:@"myHRMApp_Device"];
                    [userDefaults synchronize];
                    self.LastConnectDevice = self.BLE_device1;
                }
            }
        }
        #endif
        
        APPDetail.text = nil;
        APPUseFreq.text = nil;
        
    }
    else if(indexPath.row == 6)
    {
        #ifdef BLE_Debug
        APPTitle.text = @"Button";
        #else
        if(self.BLE_device2 != nil)
        {
            [APPTitle setTextColor:[UIColor blueColor]];
            APPTitle.text = self.BLE_device2;
        }
        else
        {
            APPTitle.text = nil;
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        if(cell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
            if([self.CBStatus isEqualToString:@"Connected : YES"])
            {
                if(self.LastConnectDevice == nil)
                {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:self.BLE_device2 forKey:@"myHRMApp_Device"];
                    [userDefaults synchronize];
                    self.LastConnectDevice = self.BLE_device2;
                }
                else
                {
                    if(!([self.LastConnectDevice isEqualToString:self.BLE_device2]))
                    {
                        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                        [userDefaults setObject:self.BLE_device2 forKey:@"myHRMApp_Device"];
                        [userDefaults synchronize];
                        self.LastConnectDevice = self.BLE_device2;
                    }
                }
            }
        }
        else
        {
            if([self.CBStatus isEqualToString:@"Connected : YES"])
            {
                if((cell.accessoryType == UITableViewCellAccessoryNone) && (IndexSetAccessoryCheckmark == indexPath.row) )
                {
                    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                    IndexSetAccessoryCheckmark = 0;
                    
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:self.BLE_device2 forKey:@"myHRMApp_Device"];
                    [userDefaults synchronize];
                    self.LastConnectDevice = self.BLE_device2;
                }
            }
        }
        #endif
        
        APPDetail.text = nil;
        APPUseFreq.text = nil;
    }
    else if(indexPath.row == 7)
    {
        if(self.BLE_device3 != nil)
        {
            [APPTitle setTextColor:[UIColor blueColor]];
            APPTitle.text = self.BLE_device3;
        }
        else
        {
            APPTitle.text = nil;
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        if(cell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
            if([self.CBStatus isEqualToString:@"Connected : YES"])
            {
                if(self.LastConnectDevice == nil)
                {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:self.BLE_device3 forKey:@"myHRMApp_Device"];
                    [userDefaults synchronize];
                    self.LastConnectDevice = self.BLE_device3;
                }
                else
                {
                    if(!([self.LastConnectDevice isEqualToString:self.BLE_device3]))
                    {
                        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                        [userDefaults setObject:self.BLE_device3 forKey:@"myHRMApp_Device"];
                        [userDefaults synchronize];
                        self.LastConnectDevice = self.BLE_device3;
                    }
                }
             }
        }
        else
        {
            if([self.CBStatus isEqualToString:@"Connected : YES"])
            {
                if((cell.accessoryType == UITableViewCellAccessoryNone) && (IndexSetAccessoryCheckmark == indexPath.row) )
                {
                    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                    IndexSetAccessoryCheckmark = 0;
                    
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    [userDefaults setObject:self.BLE_device3 forKey:@"myHRMApp_Device"];
                    [userDefaults synchronize];
                    self.LastConnectDevice = self.BLE_device3;
                }
            }
        }
        
        APPDetail.text = nil;
        APPUseFreq.text = nil;
    }
    #ifdef  CustomBLEService
    else if(indexPath.row == 8)
    {
        APPTitle.text = @"LED On/Off";
        APPDetail.text = nil;
        APPUseFreq.text = nil;
        UISwitch *theLEDSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        if(LEDSwitch)
            [theLEDSwitch setOn:YES];
        else
            [theLEDSwitch setOn:NO];
        [theLEDSwitch addTarget:self action:@selector(CustomBLEServiceLEDChange) forControlEvents:UIControlEventValueChanged];
        [cell addSubview:theLEDSwitch];
        cell.accessoryView = theLEDSwitch;
    }
    else if(indexPath.row == 9)
    {
        APPTitle.text = @"Buzzer";
        APPDetail.text = nil;
        APPUseFreq.text = nil;
        UISwitch *theBuzzerSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        if(BuzzerSwitch)
            [theBuzzerSwitch setOn:YES];
        else
            [theBuzzerSwitch setOn:NO];
        [theBuzzerSwitch addTarget:self action:@selector(CustomBLEServiceBuzzerOnOff) forControlEvents:UIControlEventValueChanged];
        [cell addSubview:theBuzzerSwitch];
        cell.accessoryView = theBuzzerSwitch;
    }
    else if(indexPath.row == 10)
    {
        APPTitle.text = @"Button";
        APPDetail.text = nil;
        APPUseFreq.text = nil;
        UISwitch *theSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        if(TestSwitch)
            [theSwitch setOn:YES];
        else
            [theSwitch setOn:NO];
        [theSwitch setUserInteractionEnabled:NO];
        [cell addSubview:theSwitch];
        cell.accessoryView = theSwitch;
    }
    else if(indexPath.row == 11)
    {
        if(DevBattLevel != nil)
            APPTitle.text = [@"Battery level :" stringByAppendingString:DevBattLevel];
        else
            APPTitle.text = @"Battery level ";
        
        APPDetail.text = nil;
        APPUseFreq.text = nil;
    }
    #endif
    else
    {
        APPTitle.text = nil;
        APPDetail.text = nil;
        APPUseFreq.text = nil;
    }
    
    /*
    // Assign our own background image for the cell
    UIImage *background = [self cellBackgroundForRowAtIndexPath:indexPath];
    
    UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:background];
    cellBackgroundView.image = background;
    cell.backgroundView = cellBackgroundView;
    */
    
    return cell;
}

/*
- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        
    }
    else if(indexPath.row == 1)
    {
        
    }
    else if(indexPath.row == 2)
    {
        
    }
}
*/

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //UILabel *BLEState = (UILabel *)[cell viewWithTag:101];
    
    if(indexPath.row == 0)
    {
#ifdef DebugWithoutBLEConnection
        [self performSegueWithIdentifier:@"SegueForHRM" sender:[tableView cellForRowAtIndexPath:indexPath]];
#else
        #ifndef CustomBLEService
        if([self.CBStatus rangeOfString:@"Connected"].location !=
           NSNotFound)
        {
            [self performSegueWithIdentifier:@"SegueForHRM" sender:[tableView cellForRowAtIndexPath:indexPath]];
        }
        #endif
#endif
    }
    else if(indexPath.row == 1)
    {
        //[self performSegueWithIdentifier:@"SegueForTest" sender:[tableView cellForRowAtIndexPath:indexPath]];
    }
    else if(indexPath.row == 2)
    {
        //[self performSegueWithIdentifier:@"SegueForTest" sender:[tableView cellForRowAtIndexPath:indexPath]];
        
#ifdef FacebookSDK
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [self performSegueWithIdentifier:@"SegueForFBDemo" sender:[tableView cellForRowAtIndexPath:indexPath]];
        }
#endif

    }
    else if(indexPath.row == 3)
    {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
#ifdef DebugWithoutTrackPath
            [self performSegueWithIdentifier:@"HRHistory" sender:[tableView cellForRowAtIndexPath:indexPath]];
#else
            NSString *path;
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            //path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"./HRMdata.txt"];
            path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"HRMdata.txt"];
            [[NSFileManager defaultManager] changeCurrentDirectoryPath:path];
        
            if ([[NSFileManager defaultManager] fileExistsAtPath:path])
            {
                //Get File Size
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
                int fileSize = (int)[fileHandle seekToEndOfFile];
                [fileHandle closeFile];
                //NSLog(@"File size = %i",fileSize);
            
                if(fileSize != 0)
                {
                    [self performSegueWithIdentifier:@"HRHistory" sender:[tableView cellForRowAtIndexPath:indexPath]];
                }
                else{
                    UIAlertView *alert6 = [[UIAlertView alloc] initWithTitle:@"History" message:@"No history data!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                
                    [alert6 show];
                }
            }
            else{
                UIAlertView *alert6 = [[UIAlertView alloc] initWithTitle:@"History" message:@"No history data!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
                [alert6 show];
            
            }
#endif
        }
        else
        {
#ifdef BLE_Debug
            [self performSegueWithIdentifier:@"SegueLogMessage" sender:[tableView cellForRowAtIndexPath:indexPath]];
#endif
        }
     }
    else if(indexPath.row == 4)//BLE State (Scan , Connect , Disconnect)
    {
        UILabel *BLEState = (UILabel *)[cell viewWithTag:101];
        //NSLog(@"%@",BLEState.text);
        
        if([BLEState.text isEqualToString:@"Scan..."])
        {
            if([ScanTimer isValid])
            {
                [ScanTimer invalidate];
                Count10sec = BLEScanTime;
            }
            
            #ifdef BLE_Debug
            
            #else
                [CoreBTObj StopScanPeripheral];
            #endif
            
            [spinner stopAnimating];
            self.CBStatus = @"Disconnected";
            self.BLE_device1 = nil;
            self.BLE_device2 = nil;
            self.BLE_device3 = nil;
            [self.tableView reloadData];
        }
        else if([BLEState.text rangeOfString:@"Connected"].location != NSNotFound)
        {
            myAlert = [[UIAlertView alloc] initWithTitle:@"Disconnect" message:@"CancelPeripheralConnection" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            
            [myAlert show];
            
            AlertTimer = [NSTimer scheduledTimerWithTimeInterval:AlertViewTimeout target:self selector:@selector(DismissAlertView) userInfo:nil repeats:NO];
        }
        else if([BLEState.text isEqualToString:@"Disconnected"])
        {
            myAlert = [[UIAlertView alloc] initWithTitle:@"Scan PeripheralWithHRService" message:@"Scans HRM device for 15 seconds" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [myAlert show];
            
            AlertTimer = [NSTimer scheduledTimerWithTimeInterval:AlertViewTimeout target:self selector:@selector(DismissAlertView) userInfo:nil repeats:NO];
        }
    }
    else if(indexPath.row == 5)
    {
        #ifdef BLE_Debug

        #else
        if([self.CBStatus isEqualToString:@"Scan..."])
        {
            UILabel *Device1 = (UILabel *)[cell viewWithTag:101];
            if(Device1.text != nil)
            {
                [CoreBTObj ConnectHRMDevice:Device1.text];
                
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            }
        }
        #endif
    }
    else if(indexPath.row == 6)
    {
        #ifdef BLE_Debug
        
        #else
        if([self.CBStatus isEqualToString:@"Scan..."])
        {
            UILabel *Device2 = (UILabel *)[cell viewWithTag:101];
            if(Device2.text != nil)
            {
                [CoreBTObj ConnectHRMDevice:Device2.text];
                
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            }
        }
        #endif
    }
    else if(indexPath.row == 7)
    {
        #ifdef BLE_Debug

        #else
        if([self.CBStatus isEqualToString:@"Scan..."])
        {
            UILabel *Device3 = (UILabel *)[cell viewWithTag:101];
            if(Device3.text != nil)
            {
                [CoreBTObj ConnectHRMDevice:Device3.text];
                
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            }
        }
        #endif
    }
    #ifdef CustomBLEService
    else if(indexPath.row == 11)
    {
        if([self.CBStatus isEqualToString:@"Connected : YES"])
        {
            [CoreBTObj ReadBatterylevelCharacteristic];
        }
    }
    #endif
}

#ifdef CustomBLEService
#pragma mark - CLLocationManager delegate

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
    
    //double lat = currentLocation.coordinate.latitude;
    //double lng = currentLocation.coordinate.longitude;

    Linkloss_latitude = currentLocation.coordinate.latitude;
    Linkloss_longitude = currentLocation.coordinate.longitude;
    
    myLatitude = currentLocation.coordinate.latitude;
    myLongitude = currentLocation.coordinate.longitude;
    
    NSLog(@"didUpdateToLocation");
    [locationManager stopUpdatingLocation];
}

#endif

#pragma mark - Get system information
- (NSString *) platform{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return platform;
}

- (NSInteger) platformNumber
{
    NSString *platform = [self platform];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if ([platform isEqualToString:@"iPad3,1"])      return 1;
        if ([platform isEqualToString:@"iPad3,2"])      return 2;
        if ([platform isEqualToString:@"iPad3,3"])      return 3;
        if ([platform isEqualToString:@"iPad3,4"])      return 4;
        if ([platform isEqualToString:@"iPad3,5"])      return 5;
        if ([platform isEqualToString:@"iPad3,6"])      return 6;
        if ([platform isEqualToString:@"iPad4,1"])      return 7;
        if ([platform isEqualToString:@"iPad4,2"])      return 8;
        if ([platform isEqualToString:@"iPad4,4"])      return 9;
        if ([platform isEqualToString:@"iPad4,5"])      return 10;
        
        return 0;
    }
    else{
        if ([platform isEqualToString:@"iPhone1,1"])    return 1;
        if ([platform isEqualToString:@"iPhone1,2"])    return 2;
        if ([platform isEqualToString:@"iPhone2,1"])    return 3;
        if ([platform isEqualToString:@"iPhone3,1"])    return 4;
        if ([platform isEqualToString:@"iPhone3,2"])    return 5;
        if ([platform isEqualToString:@"iPhone3,3"])    return 6;
        if ([platform isEqualToString:@"iPhone4,1"])    return 7;
        if ([platform isEqualToString:@"iPhone5,1"])    return 8;
        if ([platform isEqualToString:@"iPhone5,2"])    return 9;
        if ([platform isEqualToString:@"iPhone5,3"])    return 10;
        if ([platform isEqualToString:@"iPhone5,4"])    return 11;
        if ([platform isEqualToString:@"iPhone6,1"])    return 12;
        if ([platform isEqualToString:@"iPhone6,2"])    return 13;
        if ([platform isEqualToString:@"iPhone7,1"])    return 14;
        if ([platform isEqualToString:@"iPhone7,2"])    return 15;
        return 0;
    }
}

#ifdef CustomBLEService
- (void)CustomBLEServiceLEDChange
{
    //NSLog(@"###LED Change...");
    
    if(LEDSwitch)
        LEDSwitch = FALSE;
    else
        LEDSwitch = TRUE;
    
    [CoreBTObj WriteValueForCustomCharacteristic:TRUE OnOff:LEDSwitch];
}

-(void)CustomBLEServiceBuzzerOnOff
{
    //NSLog(@"$$$Buzzer On...");
    
    if(BuzzerSwitch)
        BuzzerSwitch = FALSE;
    else
        BuzzerSwitch = TRUE;
    
    [CoreBTObj WriteValueForCustomCharacteristic:FALSE OnOff:BuzzerSwitch];
}
#endif
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
