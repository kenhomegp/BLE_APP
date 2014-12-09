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

//#define iPhoneMapFullScreen

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
        //NSLog(@"chk 1");
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
    
    //NSLog(@"%@",[@"Google MapSDK Ver:" stringByAppendingString:[NSString stringWithFormat:@"%@",[GMSServices SDKVersion]]]);
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
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
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        locationManager = [[CLLocationManager alloc]init];
        locationManager.delegate = self;
        //locationManager.distanceFilter = kCLDistanceFilterNone;
        //locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [locationManager requestWhenInUseAuthorization];
        }
        [locationManager startUpdatingLocation];
        //NSLog(@"Init locationManager");
        
    }
    
    
    geocoder = [[CLGeocoder alloc] init];

    // Create a GMSCameraPosition that tells the map to display the
    // coordinate 24.161369,120.604799(Merry Electronics co., ltd.) at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:24.161369 longitude:120.604799 zoom:6];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
        self.view = mapView_; //Full screen
        //mapView_.myLocationEnabled = YES;
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
        
        
        self.CustomButton.hidden = YES;
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
        mapView_.settings.zoomGestures = NO;
        
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
    else{        
        if((self.APPConfig & StartActivity) == StartActivity)
        {
            //NSLog(@"Start HRMapView Timer!");
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
    }
    
/*
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = mapView_;
*/
    //[self MoveCameraToMyLocation];
    
}

- (void) GetMyLocation
{
    //NSLog(@"Get My location!");
    
    //NSString *longitude = [NSString stringWithFormat:@"%.8f", mapView_.myLocation.coordinate.longitude];
    //NSString *latitude = [NSString stringWithFormat:@"%.8f", mapView_.myLocation.coordinate.latitude];
    
    //NSLog(@"Mylocation= %@ , %@",latitude , longitude);
}

/*
- (void) MoveCameraToMyLocation
{
    Current_location_latitude = mapView_.myLocation.coordinate.latitude;
    Current_Location_longitude = mapView_.myLocation.coordinate.longitude;
    
    CLLocation *Location;
    [Location initWithLatitude:Current_location_latitude longitude:Current_Location_longitude];
    
    
    GMSCameraPosition *currposition = [GMSCameraPosition cameraWithLatitude:Current_location_latitude longitude:Current_Location_longitude zoom:15];
    
    [mapView_ setCamera:currposition];
    
    [mapView_ animateToBearing:0];
    
    //Reverse Geocoding
    [geocoder reverseGeocodeLocation:Location completionHandler:^(NSArray *placemarks, NSError *error) {
        //NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake(Current_location_latitude, Current_Location_longitude);
            
            marker.title =  [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",placemark.subThoroughfare, placemark.thoroughfare,placemark.postalCode, placemark.locality,placemark.administrativeArea,placemark.country];
            marker.snippet = @"台灣";
            marker.map = mapView_;
            
        } else {
            //NSLog(@"Error!");
        }
    }];
    
    //NSLog(@"Move Camera to MyLocation");
}
*/

- (void) MoveCamera:(CLLocation *)Location
{
    //NSString *str;

    GMSCameraPosition *currposition = [GMSCameraPosition cameraWithLatitude:Current_location_latitude longitude:Current_Location_longitude zoom:15];
    
    [mapView_ setCamera:currposition];
    
    [mapView_ animateToBearing:0];
    
    //Reverse Geocoding
    [geocoder reverseGeocodeLocation:Location completionHandler:^(NSArray *placemarks, NSError *error) {
        //NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake(Current_location_latitude, Current_Location_longitude);
            
            marker.title =  [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",placemark.subThoroughfare, placemark.thoroughfare,placemark.postalCode, placemark.locality,placemark.administrativeArea,placemark.country];
            marker.snippet = @"台灣";
            marker.map = mapView_;
            
        } else {
            //NSLog(@"Error!");
        }
     }];
    
    /*
    if((self.APPConfig & StartActivity) == StartActivity)
    {
        NSLog(@"Start exercise");
        
        if(!([self.GetMyLocationTimer isValid]))
        {
            self.GetMyLocationTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(GetMyLocation) userInfo:nil repeats:YES];
            
            NSLog(@"Timer enabled");
        }
    }
    else{
        NSLog(@"Stop exercise");
        
        if([self.GetMyLocationTimer isValid])
        {
            [self.GetMyLocationTimer invalidate];
            
            NSLog(@"Timer disable");
        }
    }
    */
    
    //[[self delegate] passDistance:10.0];//Test protocol
    
    //GMSMarker *marker = [[GMSMarker alloc] init];
    //marker.position = CLLocationCoordinate2DMake(Current_location_latitude, Current_Location_longitude);
    
    //marker.title = @"Your location";
    //marker.snippet = @"Taiwan";
    //marker.map = mapView_;
    
    //NSLog(@"MoveCamera");
}

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
        mapView_.camera = [GMSCameraPosition cameraWithTarget:location.coordinate zoom:14];
        //NSLog(@"FirstLocationUpdate");
        
    }
    //NSLog(@"observerValueForKeyPath");
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
        //longitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        //latitudeLabel.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        
        //NSString *longitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        //NSString *latitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        
        Current_location_latitude = currentLocation.coordinate.latitude;
        Current_Location_longitude = currentLocation.coordinate.longitude;
        
        //NSLog(@"MY HOME : %@",latitude);
        //NSLog(@"MY HOME : %@",longitude);
        //NSLog(@"didUpdateToLocation");
        
        // Stop Location Manager
        [locationManager stopUpdatingLocation];

        //[self MoveCamera:currentLocation];
    }
    
    // Stop Location Manager
    //[locationManager stopUpdatingLocation];
}
- (IBAction)SwipeLeftAction:(id)sender {
    //NSLog(@"Swipe  recognized");
    
    //[[self navigationController] popToRootViewControllerAnimated:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) UpdateHRMData
{
    HRMDataObject* theDataObject = [self theAppDataObject];
    //NSLog(@"t:%@,d:%@,c:%@",theDataObject.TimeStr,theDataObject.DistanceStr,theDataObject.CaloriesStr);
    
    self.TimeLabel.text = theDataObject.TimeStr;
    
    //self.CaloriesLabel.text = theDataObject.CaloriesStr;
    //NSLog(@"ccc %@",self.CaloriesLabel.text);
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
}

-(IBAction)PressStartButton:(id)sender {
    //[[self delegate] passDistance:10.0];//Test protocol
    //NSLog(@"Test protocol");
    
    HRMDataObject* theDataObject = [self theAppDataObject];
    self.APPConfig = theDataObject.APPConfig;
    
    if((self.APPConfig & BLE_Connected) == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HRM", @"AlertViewTitle") message:NSLocalizedString(@"Device", @"AlertMessage") delegate:self cancelButtonTitle:NSLocalizedString(@"End", @"Test") otherButtonTitles:nil, nil];
        
        [alert show];
        
        //Debug code
        /* MoveCamera to "田中火車站"*/
        GMSCameraPosition *currposition = [GMSCameraPosition cameraWithLatitude:23.858337 longitude:120.591495 zoom:15];
        [mapView_ setCamera:currposition];

        return;
    }
    
    if((self.APPConfig & StartActivity) == 0)
    {
        [[self delegate] passCommand:@"Start_HRM_Timer"];
    }
    
    if(!([HRMTimer isValid]))
    {
        HRMTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                               target:self
                                                             selector:@selector         (UpdateHRMData)
                                                             userInfo:nil
                                                              repeats:YES];
        [self.CustomButton setTitle:NSLocalizedString(@"PauseButton", @"") forState:UIControlStateNormal];
    }
    else{
        [HRMTimer invalidate];
        
        [self.CustomButton setTitle:NSLocalizedString(@"StartButton", @"") forState:UIControlStateNormal];
    }
}
@end
