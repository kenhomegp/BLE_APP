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

@interface HRMapView ()
@end

@implementation HRMapView
{
    GMSMapView *mapView_;
    
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
        //NSLog(@"chk 2");
    }

}
#endif

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //NSLog(@"HRMapViewDidLoad");
    
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
    
    //[swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.SwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    //[self.SwipeRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionRight)];
    
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    geocoder = [[CLGeocoder alloc] init];

    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    //mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 0, 320, 400) camera:camera];
    mapView_.myLocationEnabled = YES;
    
    //self.view = mapView_; //Full screen
    [self.view addSubview:mapView_];
    
    //NSString *restorationId = self.restorationIdentifier;
    //NSLog(@"RestorationID = %@",restorationId);
    
    HRMDataObject* theDataObject = [self theAppDataObject];
    self.APPConfig = theDataObject.APPConfig;
    
    if((self.APPConfig & BLE_Connected) == 0)
    {
        //NSLog(@"@@@BLE disconnected!");
        
        [[self delegate] passCommand:@"BLE_Connect"];
    }
    else{
        //NSLog(@"!!!BLE connected");
        
        if((self.APPConfig & StartActivity) == StartActivity)
        {
            //NSLog(@"Start HRMapView Timer!");
            if(!([HRMTimer isValid]))
            {
                NSLog(@"Start HRMapView Timer!");
                HRMTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                            target:self
                                                          selector:@selector         (UpdateHRMData)
                                                          userInfo:nil
                                                           repeats:YES];
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
        
        // Stop Location Manager
        [locationManager stopUpdatingLocation];

        [self MoveCamera:currentLocation];
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
    }
    else{
        [HRMTimer invalidate];
    }
}
@end
