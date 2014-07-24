//
//  BLETabBarController.m
//  MerryBLEtool
//
//  Created by merry on 13-12-18.
//  Copyright (c) 2013年 merry. All rights reserved.
//

#import "BLETabBarController.h"

@interface BLETabBarController ()

@end

@implementation BLETabBarController
@synthesize DevCharacteristics;

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
    self.CBInit = YES;
    self.DeviceIsConnect = NO;
    self.DevName = @"";
    self.GATTService = @"";
    self.Log = @"";
    self.PeripheralRSSI = @"";
    self.DeviceType = 0;
    self.DevCharacteristics = [[NSMutableArray alloc] init];
    self.BLE_lookup_table = [NSMutableDictionary dictionary];
    [self.BLE_lookup_table setObject:@"Device Name <2a00>\n" forKey:@"<2a00>"];
    [self.BLE_lookup_table setObject:@"Appearance <2a01>\n" forKey:@"<2a01>"];
    [self.BLE_lookup_table setObject:@"Peripheral Privacy Flag <2a02>\n" forKey:@"<2a02>"];
    [self.BLE_lookup_table setObject:@"Reconnection Address <2a03>\n" forKey:@"<2a03>"];
    [self.BLE_lookup_table setObject:@"Peripheral Connection Parameters <2a04>\n" forKey:@"<2a04>"];
    [self.BLE_lookup_table setObject:@"Service Changed <2a05>\n" forKey:@"<2a05>"];
    [self.BLE_lookup_table setObject:@"Alert Level <2a06>\n" forKey:@"<2a06>"];
    [self.BLE_lookup_table setObject:@"Tx Power Level <2a07>\n" forKey:@"<2a07>"];
    [self.BLE_lookup_table setObject:@"Battery Level <2a19>\n" forKey:@"<2a19>"];
    [self.BLE_lookup_table setObject:@"System ID <2a23>\n" forKey:@"<2a23>"];
    [self.BLE_lookup_table setObject:@"Model Number <2a24>\n" forKey:@"<2a24>"];
    [self.BLE_lookup_table setObject:@"Serial Number <2a25>\n" forKey:@"<2a25>"];
    [self.BLE_lookup_table setObject:@"Hardware Revision <2a27>\n" forKey:@"<2a27>"];
    [self.BLE_lookup_table setObject:@"Firmware Revision <2a26>\n" forKey:@"<2a26>"];
    [self.BLE_lookup_table setObject:@"Software Revision <2a28>\n" forKey:@"<2a28>"];
    [self.BLE_lookup_table setObject:@"Manufacturer Name <2a29>\n" forKey:@"<2a29>"];
    [self.BLE_lookup_table setObject:@"IEEE 11073-20601 Regulatory Ceritification Data List <2a2a>\n" forKey:@"<2a2a>"];
    [self.BLE_lookup_table setObject:@"HeartRate Measurement <2a37>\n" forKey:@"<2a37>"];
    [self.BLE_lookup_table setObject:@"Body Sensor Location <2a38>\n" forKey:@"<2a38>"];
    [self.BLE_lookup_table setObject:@"HeartRate Control Point <2a39>\n" forKey:@"<2a39>"];
    [self.BLE_lookup_table setObject:@"PnP ID <2a50>\n" forKey:@"<2a50>"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
