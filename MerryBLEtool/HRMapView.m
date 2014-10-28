//
//  HRMapView.m
//  MerryBLEtool
//
//  Created by merry on 14-10-17.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import "HRMapView.h"
#import <GoogleMaps/GoogleMaps.h>

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
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.myLocationEnabled = YES;
    self.view = mapView_;
    
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
@end
