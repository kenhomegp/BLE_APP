//
//  HRMapView.m
//  MerryBLEtool
//
//  Created by merry on 14-10-17.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import "HRMapView.h"
#import <GoogleMaps/GoogleMaps.h>

#import "AppDelegateProtocol.h"
#import "HRMDataObject.h"

#define DebugMessagex

@interface HRMapView ()
@end

@implementation HRMapView
{
    GMSMapView *mapView_;
    BOOL firstLocationUpdate_;
    
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    
    CLLocationDegrees Current_location_latitude;
    CLLocationDegrees Current_Location_longitude;
    
    NSTimer *HRMTimer;
#ifdef SaveLocationToFile
    BOOL fileExist;
    NSFileHandle *fileHandle;
    NSInteger TimerCounter;
#endif
#ifdef GradientPolyline
    GMSPolyline *polyline_;
    GMSMutablePath *path;
    NSMutableArray *trackData_;
#endif
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


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    //NSLog(@"viewDidDisappear");
    [HRMTimer invalidate];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#ifdef BatteryLevel
- (void)batteryLevelChanged:(NSNotification *)notification
{
    //Update Battery Level
    float batteryLevel = [UIDevice currentDevice].batteryLevel;
    if (batteryLevel < 0.0) {
        // -1.0 means battery state is UIDeviceBatteryStateUnknown
        self.BatteryLabel.text = @"Battery: 90%";
    }
    else {
        static NSNumberFormatter *numberFormatter = nil;
        if (numberFormatter == nil) {
            numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
            [numberFormatter setMaximumFractionDigits:1];
        }
        
        NSNumber *levelObj = [NSNumber numberWithFloat:batteryLevel];
        //self.BatteryLabel.text = [numberFormatter stringFromNumber:levelObj];
        self.BatteryLabel.text = [@"Battery: " stringByAppendingString:[numberFormatter stringFromNumber:levelObj]];
    }

}
#endif

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Check iOS Version
    /*
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    int ver_int = [ver intValue];
    float ver_float = [ver floatValue];
    */
    //NSLog(@"System version = %d,%f",ver_int , ver_float);
    
    //Check SDK version
    //NSLog(@"%@",[@"Google MapSDK Ver:" stringByAppendingString:[NSString stringWithFormat:@"%@",[GMSServices SDKVersion]]]);
    
    //Disable Idle Timer
    //[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    #ifdef BatteryLevel
    // Register for battery level and state change notifications.
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(batteryLevelChanged:)
												 name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    //NSLog(@"BatteryMonitorEnabled!");
    #endif
    
    //Start/Stop button
    [self.CustomButton setBackgroundImage:[UIImage imageNamed:@"Button1.png"] forState:UIControlStateNormal];
    [self.CustomButton setBackgroundImage:[UIImage imageNamed:@"Button1Pressed.png"] forState:UIControlStateHighlighted];
    
    [self.SwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    //if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        locationManager = [[CLLocationManager alloc]init];
        locationManager.delegate = self;
        //locationManager.distanceFilter = kCLDistanceFilterNone;
        //locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [locationManager requestWhenInUseAuthorization];
        }
        
        //[locationManager startUpdatingLocation];
    }
    
    geocoder = [[CLGeocoder alloc] init];

    // Create a GMSCameraPosition that tells the map to display the
    // coordinate 24.161369,120.604799(Merry Electronics co., ltd.) at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:24.161369 longitude:120.604799 zoom:8];
    
    //Debug
    //GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:44.1314 longitude:9.6921 zoom:14.059f bearing:328.f viewingAngle:40.f];
    //firstLocationUpdate_ = YES;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        //Full Screen
        //mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
        //self.view = mapView_;
        mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, 768, 924) camera:camera];
        [self.view addSubview:mapView_];
        
        mapView_.settings.compassButton = YES;
        mapView_.settings.myLocationButton = YES;
        
        // Listen to the myLocation property of GMSMapView.
        [mapView_ addObserver:self
                   forKeyPath:@"myLocation"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];

        dispatch_async(dispatch_get_main_queue(), ^{
            //NSLog(@"MyLocationEnabled");
            mapView_.myLocationEnabled = YES;});
        
        //self.CustomButton.hidden = YES;
        self.HeartRateLabel.hidden = YES;
        self.TimeLabel.hidden = YES;
        self.CaloriesLabel.hidden = YES;
        self.BatteryLabel.hidden = YES;
    }
    else
    {
        #ifdef iPhoneMapFullScreen
            mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
            self.view = mapView_; //Full screen
            [self.view addSubview:self.HeartRateLabel];
            [self.view addSubview:self.TimeLabel];
        #else
            mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, 320, 400) camera:camera];
            [self.view addSubview:mapView_];
        #endif
        
        //mapView_.myLocationEnabled = YES;
        mapView_.settings.myLocationButton = YES;
        mapView_.settings.compassButton = YES;
        mapView_.settings.zoomGestures = YES;
        
        // Listen to the myLocation property of GMSMapView.
        [mapView_ addObserver:self
                   forKeyPath:@"myLocation"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            mapView_.myLocationEnabled = YES;
            //NSLog(@"MyLocationEnabled");
        });
    }
    
    HRMDataObject* theDataObject = [self theAppDataObject];
    self.APPConfig = theDataObject.APPConfig;
    
    if((self.APPConfig & BLE_Connected) == 0)
    {
        [[self delegate] passCommand:@"BLE_Connect"];
        
        [self.CustomButton setTitle:NSLocalizedString(@"StartButton", @"") forState:UIControlStateNormal];
    }
    else
    {
#ifdef DebugMessagex
        if((self.APPConfig & StartActivity) == StartActivity)
        {
            if(!([HRMTimer isValid]))
            {
                //NSLog(@"Start HRMapView Timer!");
                HRMTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                            target:self
                                                          selector:@selector         (UpdateHRMData)
                                                          userInfo:nil
                                                           repeats:YES];
                
                [self.CustomButton setTitle:NSLocalizedString(@"PauseButton", @"") forState:UIControlStateNormal];
            }
        }
#endif
    }
    
#ifdef SaveLocationToFile
    TimerCounter = 0;
    
    NSString *path1;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path1 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Mapdata.txt"];
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:path1];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path1])
    {
        NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:path1];
        if(fh != nil)
        {
            int fileSize = (int)[fh seekToEndOfFile];
            [fh closeFile];
            
            NSError *error;
            if(fileSize < 100)
            {
                BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path1 error:&error];
                if (!success)
                {
#ifdef DebugMessage
                    NSLog(@"Remove file error!!");
#endif
                }
                else
                {
#ifdef DebugMessage
                    NSLog(@"Remove old file");
#endif
                }
                
                if(fileSize < 100)
                {
                    //Create new file
                    [[NSFileManager defaultManager] changeCurrentDirectoryPath:[paths objectAtIndex:0]];
                    
                    if([[NSFileManager defaultManager] createFileAtPath:@"./Mapdata.txt" contents:nil attributes:nil])
                    {
#ifdef DebugMessage
                        NSLog(@"Create new file");
#endif
                        fileExist = TRUE;
                    }
                    else
                    {
#ifdef DebugMessage
                        NSLog(@"Create file Error!!");
#endif
                        fileExist = FALSE;
                    }
                    
                    //Get File handle
                    if(fileExist == TRUE)
                    {
                        fileHandle = nil;
                        NSString *path2;
                        NSArray *Dpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        path2 = [[Dpaths objectAtIndex:0] stringByAppendingPathComponent:@"Mapdata.txt"];
                        [[NSFileManager defaultManager] changeCurrentDirectoryPath:path2];
                        
                        if ([[NSFileManager defaultManager] fileExistsAtPath:path2])
                        {
                            //Get File Size
                            fileHandle = [NSFileHandle fileHandleForWritingAtPath:path2];
                            if(fileHandle != nil)
                            {
#ifdef DebugMessage
                                NSLog(@"Get file handle:PASS");
#endif
                            }
                            else
                            {
                                fileExist = FALSE;
#ifdef DebugMessage
                                NSLog(@"Can't get file handle!");
#endif
                            }
                        }
                    }
                }
                
            }
            else
            {
                //[self GradientPolyLine];
            }
        }
    }
    else
    {
        //Create new file
        [[NSFileManager defaultManager] changeCurrentDirectoryPath:[paths objectAtIndex:0]];
        
        if([[NSFileManager defaultManager] createFileAtPath:@"./Mapdata.txt" contents:nil attributes:nil])
        {
#ifdef DebugMessage
            NSLog(@"File not exist,Create file..");
#endif
            fileExist = TRUE;
        }
        else
        {
#ifdef DebugMessage
            NSLog(@"Create file Error!!");
#endif
            fileExist = FALSE;
        }
        
        //Get File handle
        if(fileExist == TRUE)
        {
            fileHandle = nil;
            NSString *path2;
            NSArray *Dpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            path2 = [[Dpaths objectAtIndex:0] stringByAppendingPathComponent:@"Mapdata.txt"];
            [[NSFileManager defaultManager] changeCurrentDirectoryPath:path2];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:path2])
            {
                //Get File Size
                fileHandle = [NSFileHandle fileHandleForWritingAtPath:path2];
                if(fileHandle != nil)
                {
#ifdef DebugMessage
                    NSLog(@"Get file handle:PASS");
#endif
                }
                else
                {
                    fileExist = FALSE;
#ifdef DebugMessage
                    NSLog(@"Can't get file handle!");
#endif
                }
            }
        }
    }
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [mapView_ removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
}


#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!firstLocationUpdate_) {
        // If the first location update has not yet been recieved, then jump to that
        // location.
        firstLocationUpdate_ = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate zoom:16];
        //Reverse Geocoding
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            //NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
            if (error == nil && [placemarks count] > 0)
            {
                placemark = [placemarks lastObject];
                
                GMSMarker *marker = [[GMSMarker alloc] init];
                //marker.position = CLLocationCoordinate2DMake(Current_location_latitude, Current_Location_longitude);
                marker.position = location.coordinate;
                
                marker.title =  [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",placemark.subThoroughfare, placemark.thoroughfare,placemark.postalCode, placemark.locality,placemark.administrativeArea,placemark.country];
                marker.snippet = @"My Location";
                marker.map = mapView_;
                //NSLog(@"PlaceMark");
            }
            else
            {
                //NSLog(@"Error!");
            }
        }];

    }
}

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
    
    if (currentLocation != nil) {
        
        // Stop Location Manager
        if(fileExist == TRUE)
        {
            double lat = currentLocation.coordinate.latitude;
            double lng = currentLocation.coordinate.longitude;
            if((lat != Current_location_latitude) && (lng != Current_Location_longitude))
            {
                NSMutableData *writer = [[NSMutableData alloc]init];
                [writer appendBytes:&(lat) length:sizeof(double)];
                [writer appendBytes:&(lng) length:sizeof(double)];
                [fileHandle seekToEndOfFile];
                [fileHandle writeData:writer];
                Current_location_latitude = lat;
                Current_Location_longitude = lng;
#ifdef DebugMessage
                NSLog(@"w%d,%f,%f",(int)[writer length],lat,lng);
#endif
                
                /* Track user's location
                 NSString *pointString=[NSString    stringWithFormat:@"%f,%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude];
                 [self.points addObject:pointString];
                 GMSMutablePath *path = [GMSMutablePath path];
                 for (int i=0; i<self.points.count; i++)
                 {
                 NSArray *latlongArray = [[self.points   objectAtIndex:i]componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
                 
                 [path addLatitude:[[latlongArray objectAtIndex:0] doubleValue] longitude:[[latlongArray objectAtIndex:1] doubleValue]];
                 }
                 
                 if (self.points.count>2)
                 {
                 GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
                 polyline.strokeColor = [UIColor blueColor];
                 polyline.strokeWidth = 5.f;
                 polyline.map = mapView_;
                 self.view = mapView_;
                 }
                */
            }
        }

        [locationManager stopUpdatingLocation];
    }
    
    // Stop Location Manager
    //[locationManager stopUpdatingLocation];
}
- (IBAction)SwipeLeftAction:(id)sender {
    //NSLog(@"Swipe  recognized");
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) UpdateHRMData
{
    HRMDataObject* theDataObject = [self theAppDataObject];

    self.TimeLabel.text = theDataObject.TimeStr;
    
    if(theDataObject.CaloriesStr != nil)
        self.CaloriesLabel.text = theDataObject.CaloriesStr;
    
    self.HeartRateLabel.text = [@"HR: " stringByAppendingString:[NSString stringWithFormat:@"%ld bpm",theDataObject.HRM]];
    
    if((theDataObject.APPConfig & BLE_Connected) == 0)
    {
        [HRMTimer invalidate];
        self.APPConfig = theDataObject.APPConfig;
        self.HeartRateLabel.text = @"HR: 095 bpm";
        self.CaloriesLabel.text = @"Calories: 00000 cal";
        self.TimeLabel.text = @"Time:00h:00m:00s";
    }
    else{
#ifdef SaveLocationToFile
        if(TimerCounter == 5)
        {
            TimerCounter = 0;
            [locationManager startUpdatingLocation];
        }
        else
        {
            TimerCounter++;
        }
#endif
    }
    
}

-(IBAction)PressStartButton:(id)sender {
    HRMDataObject* theDataObject = [self theAppDataObject];
    self.APPConfig = theDataObject.APPConfig;
#ifdef DebugMessage
    NSLog(@"APPConfig = %d",self.APPConfig);
#endif
    
    if((self.APPConfig & BLE_Connected) == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HRM", @"AlertViewTitle") message:NSLocalizedString(@"Device", @"AlertMessage") delegate:self cancelButtonTitle:NSLocalizedString(@"End", @"Test") otherButtonTitles:nil, nil];
        
        [alert show];
        
        return;
    }
    
#ifdef DebugMessagex
    if((self.APPConfig & StartActivity) == 0)
    {
        [[self delegate] passCommand:@"Start_HRM_Timer"];
    }
#endif
    
    if(!([HRMTimer isValid]))
    {
#ifdef DebugMessagex
        self.APPConfig |= (StartActivity);
#endif
        
        HRMTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                               target:self
                                                             selector:@selector         (UpdateHRMData)
                                                             userInfo:nil
                                                              repeats:YES];
        [self.CustomButton setTitle:NSLocalizedString(@"PauseButton", @"") forState:UIControlStateNormal];
#ifdef DebugMessage
        NSLog(@"Pressing start button");
#endif
    }
    else{
        self.APPConfig &= ~(StartActivity);
        
        [HRMTimer invalidate];
        
        [self.CustomButton setTitle:NSLocalizedString(@"StartButton", @"") forState:UIControlStateNormal];

#ifdef SaveLocationToFile
        TimerCounter = 0;
        [locationManager stopUpdatingLocation];
        #ifdef DebugMessage
        int fileSize = (int)[fileHandle seekToEndOfFile];
        #endif
        [fileHandle closeFile];
        #ifdef DebugMessage
        NSLog(@"Press buuton,file_total w = %d",fileSize);
        #endif
#endif
//#ifdef GradientPolyline
//        polyline_ = [GMSPolyline polylineWithPath:path];
//        polyline_.strokeWidth = 6;
//        polyline_.map = mapView_;
//        NSLog(@"GradientPolyline Demo : %d",(int)[trackData_ count]);
//#endif
    }
}

/*
// Google Map SDK Demo example code
- (NSArray *)gradientSpans {
 NSLog(@"gradientSpans");
 NSMutableArray *colorSpans = [NSMutableArray array];
 NSUInteger count = [trackData_ count];
 UIColor *prevColor;
 for (NSUInteger i = 0; i < count; i++) {
 double elevation = [[[trackData_ objectAtIndex:i] objectForKey:@"elevation"] doubleValue];
 
 UIColor *toColor = [UIColor colorWithHue:(float)elevation/700
 saturation:1.f
 brightness:.9f
 alpha:1.f];
 
 if (prevColor == nil) {
 prevColor = toColor;
 }
 
 GMSStrokeStyle *style = [GMSStrokeStyle gradientFromColor:prevColor toColor:toColor];
 [colorSpans addObject:[GMSStyleSpan spanWithStyle:style]];
 
 prevColor = toColor;
 }
 return colorSpans;
}
 
- (void)parseTrackFile {
    NSLog(@"parseTrackFile");
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"track" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    trackData_ = [[NSMutableArray alloc] init];
    GMSMutablePath *path = [GMSMutablePath path];
    
    for (NSUInteger i = 0; i < [json count]; i++) {
        NSDictionary *info = [json objectAtIndex:i];
        NSNumber *elevation = [info objectForKey:@"elevation"];
        CLLocationDegrees lat = [[info objectForKey:@"lat"] doubleValue];
        CLLocationDegrees lng = [[info objectForKey:@"lng"] doubleValue];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
        [trackData_ addObject:@{@"loc": loc, @"elevation": elevation}];
        [path addLatitude:lat longitude:lng];
        //if(i == 0)
        //  NSLog(@"SW evalution data = %d",[json count]);
    }
    
    polyline_ = [GMSPolyline polylineWithPath:path];
    polyline_.strokeWidth = 6;
    polyline_.map = mapView_;
}
*/
- (IBAction)DeleteTrackFile:(id)sender {
    NSString *path1;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path1 = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Mapdata.txt"];
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:path1];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path1])
    {
        NSError *error;
 
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path1 error:&error];
        
        if (!success)
        {
#ifdef DebugMessage
            NSLog(@"Remove file error!!");
#endif
        }
        else
        {
#ifdef DebugMessage
            NSLog(@"Remove exist file (Mapdata.txt)");
#endif
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TrackPath" message:@"Remove Mapdata.txt!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alert show];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"TrackPath" message:@"Mapdata.txt not exist!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    }
}

- (IBAction)DebugFunction:(id)sender {
#ifdef DebugMessage
    NSLog(@"Debug function.");
#endif
    [mapView_ removeFromSuperview];
    [self GradientPolyLine];
    [self.view addSubview:mapView_];
/*
    GMSVisibleRegion visibleRegion = mapView_.projection.visibleRegion;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithRegion:visibleRegion];
    CLLocationCoordinate2D northEast = bounds.northEast;
    GMSMarker *marker1 = [[GMSMarker alloc] init];
    marker1.position = northEast;
    marker1.title = @"L1";
    marker1.map = mapView_;
    //NSLog(@"bound: %f,%f",northEast.latitude,northEast.longitude);
    CLLocationCoordinate2D northWest = CLLocationCoordinate2DMake(bounds.northEast.latitude, bounds.southWest.longitude);
    GMSMarker *marker2 = [[GMSMarker alloc] init];
    marker2.position = northWest;
    marker2.title = @"L2";
    marker2.map = mapView_;
    CLLocationCoordinate2D southEast = CLLocationCoordinate2DMake(bounds.southWest.latitude, bounds.northEast.longitude);
    GMSMarker *marker3 = [[GMSMarker alloc] init];
    marker3.position = southEast;
    marker3.title = @"L3";
    marker3.map = mapView_;
    CLLocationCoordinate2D southWest = bounds.southWest;
    GMSMarker *marker4 = [[GMSMarker alloc] init];
    marker4.position = southWest;
    marker4.title = @"L4";
    marker4.map = mapView_;

    //NSLog(@"bound: %f,%f",southWest.latitude,southWest.longitude);
    
    CLLocationCoordinate2D testLocation = CLLocationCoordinate2DMake(Current_location_latitude, Current_Location_longitude);
    if(!([bounds containsCoordinate:testLocation]))
    {
        NSLog(@"Not visible");
    }
    else
    {
        NSLog(@"Visible");
    }
*/
}

- (void)GradientPolyLine
{
#ifdef GradientPolyline
    //Real TrackPath data
    //Read file
    NSString *path3;
    NSArray *Ppaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path3 = [[Ppaths objectAtIndex:0] stringByAppendingPathComponent:@"Mapdata.txt"];
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:path3];
    
    NSFileHandle *fHandle = [NSFileHandle fileHandleForReadingAtPath:path3];
    if(fHandle != nil)
    {
        int fileSize = (int)[fHandle seekToEndOfFile];
        int LoopCount;
        NSData *databuffer = nil;
#ifdef DebugMessage
        NSLog(@"Mapdata.txt ,fsize = %i",fileSize);
#endif
        if(fileSize != 0)
        {
            LoopCount = fileSize/16;
            GMSMutablePath *TrackPath = [GMSMutablePath path];
            
            for(int loop = 0; loop < LoopCount; loop++)
            {
                [fHandle seekToFileOffset:(loop * 16)];
                databuffer = [fHandle readDataOfLength:16];
                
                if(databuffer == nil)
                {
                    break;
                }
                else
                {
                    if(databuffer.length == 0)
                    {
                        //NSLog(@"Databuffer length = 0");
                        break;
                    }
                    NSRange Range1 = NSMakeRange(0, 8);
                    NSData *SubData1 = [databuffer subdataWithRange:Range1];
                    double lat;
                    [SubData1 getBytes:&(lat) length:sizeof(double)];
                    NSRange Range2 = NSMakeRange(8, 8);
                    NSData *SubData2 = [databuffer subdataWithRange:Range2];
                    double lng;
                    [SubData2 getBytes:&(lng) length:sizeof(double)];
                    //NSLog(@"r%d : %f,%f",loop,lat,lng);
                    
                    [TrackPath addLatitude:lat longitude:lng];
                }
            }
            
            polyline_ = [GMSPolyline polylineWithPath:TrackPath];
            polyline_.strokeWidth = 6;
            polyline_.map = mapView_;
#ifdef DebugMessage
            NSLog(@"GradientPolyline demo,%d",LoopCount);
#endif
        }
        [fHandle closeFile];
    }
#endif
}
@end
