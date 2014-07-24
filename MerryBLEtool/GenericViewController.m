//
//  GenericViewController.m
//  MerryBLEtool
//
//  Created by merry on 13-12-18.
//  Copyright (c) 2013年 merry. All rights reserved.
//

#import "GenericViewController.h"

#ifdef DEBUG_ViewControl
#define MAIN_DEBUG(x) {printf x;}
#else
#define MAIN_DEBUG(x)
#endif

@interface GenericViewController ()
@end

@implementation GenericViewController
@synthesize TIBLEUIBatteryBar;
@synthesize TIBLEUIBatteryBarLabel;
@synthesize TIBLEUILeftButton;
@synthesize TIBLEUIRightButton;
@synthesize TIBLEUISpinner;
@synthesize TIBLEUIConnBtn;
@synthesize TIBLEUIBuzzer;

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
    // Do any additional setup after loading the view from its nib.
    
    //printf("###viewDidLoad");
    
    if(((BLETabBarController *)self.parentViewController).CBInit)
    {
        ((BLETabBarController *)self.parentViewController).CBInit = NO;

        t = [[BLECBTask alloc] init];   // Init TIBLECBKeyfob class.
        [t controlSetup:1];                 // Do initial setup of TIBLECBKeyfob class.
        t.delegate = self;
        // Set TIBLECBKeyfob delegate class to point at methods implemented in this class.
    
        t.TIBLEConnectBtn = self.TIBLEUIConnBtn;
        t.m_Device = self.BLE_Device;
        t.m_Service = self.BLE_Service;
    
        t.activePeripheral = nil;
        
        self.BLE_Device.text = @"";
        self.BLE_Characteristics.text = @"";
        self.BLE_Service.text = @"";
        self.BLE_Log.text = @"";
        
        [TIBLEUILeftButton setOn: FALSE];
        [TIBLEUIRightButton setOn:FALSE];
        
        //printf("CBCentralManager Init...\r\n");
        MAIN_DEBUG(("CBCentralManager Init...\r\n"));
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //printf("###viewWillAppear\r\n");
    //MAIN_DEBUG(("###viewWillApper,%d\r\n",((BLETabBarController *)self.parentViewController).DeviceType));
    
    if(((BLETabBarController *)self.parentViewController).DeviceIsConnect)
    {
        self.BLE_Device.text = ((BLETabBarController *)self.parentViewController).DevName;
        self.BLE_Service.text = ((BLETabBarController *)self.parentViewController).GATTService;
        self.BLE_Log.text = ((BLETabBarController *)self.parentViewController).Log;
        
        //int uumlines = self.BLE_Service.contentSize.height/self.BLE_Service.font.lineHeight;
#if 1
        if([self.BLE_Characteristics.text isEqualToString:@""])
        {
            for(int i = 0; i < ((BLETabBarController *)self.parentViewController).DevCharacteristics.count ; i++)
            {
                #if 1
                if(!([((BLETabBarController *)self.parentViewController).BLE_lookup_table objectForKey:[((BLETabBarController *)self.parentViewController).DevCharacteristics objectAtIndex:i]]))
                {
                    MAIN_DEBUG(("Unknown Characteristic..\n"));
                }
                else
                {
                    self.BLE_Characteristics.text = [self.BLE_Characteristics.text stringByAppendingString:[((BLETabBarController *)self.parentViewController).BLE_lookup_table objectForKey:[((BLETabBarController *)self.parentViewController).DevCharacteristics objectAtIndex:i]]];
                }
                #else
                self.BLE_Characteristics.text = [self.BLE_Characteristics.text stringByAppendingString:[((BLETabBarController *)self.parentViewController).BLE_lookup_table objectForKey:[((BLETabBarController *)self.parentViewController).DevCharacteristics objectAtIndex:i]]];
                #endif
            }
        }
#endif
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (IBAction)TIBLEUIScanForPeripheralsButton:(id)sender {
    if (t.activePeripheral) {
        if(t.activePeripheral.isConnected) {
            [[t CM] cancelPeripheralConnection:[t activePeripheral]];
            //printf("Cancel an active connection to a peripheral\r\n");
            MAIN_DEBUG(("Cancel an active connection to a peripheral\r\n"));
            [TIBLEUIConnBtn setTitle:@"Scan and Connect" forState:UIControlStateNormal];
            t.activePeripheral = nil;
            ((BLETabBarController *)self.parentViewController).DevName = @"";
            ((BLETabBarController *)self.parentViewController).GATTService = @"";
            ((BLETabBarController *)self.parentViewController).Log = @"";
            ((BLETabBarController *)self.parentViewController).DeviceType = 0;
            ((BLETabBarController *)self.parentViewController).DeviceIsConnect = NO;
            self.BLE_Device.text = @"";
            self.BLE_Log.text = @"";
            self.BLE_Service.text = @"";
            self.BLE_Characteristics.text = @"";
        }
    } else {
        if (t.peripherals) t.peripherals = nil;
        [t findBLEPeripherals:5];
        //        [NSTimer scheduledTimerWithTimeInterval:(float)5.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
        [TIBLEUISpinner startAnimating];
        [TIBLEUIConnBtn setTitle:@"Scanning.." forState:UIControlStateNormal];
    }
}

- (IBAction)TIBLEUISoundBuzzerButton:(id)sender {
    NSString *str;
    str = TIBLEUIBuzzer.currentTitle;
    
    if((t.activePeripheral) && (t.activePeripheral.isConnected) )
    {
        if([str isEqualToString:@"Sound buzzer"])
        {
            [TIBLEUIBuzzer setTitle:@"High alert" forState:UIControlStateNormal];
        
            [t soundBuzzer:0x02 p:[t activePeripheral]]; //Sound buzzer with 0x02 as data value
        
            //Alert level (
            //https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicViewer.aspx?u=org.bluetooth.characteristic.alert_level.xml
            //Value 0, meaning "No Alert"
            //Value 1, meaning "Mild Alert"
            //Value 2, meaning "High Alert"
        }
        else if([str isEqualToString:@"Find Me"])
        {
            [TIBLEUIBuzzer setTitle:@"High alert" forState:UIControlStateNormal];
            
            [t soundBuzzer:0x02 p:[t activePeripheral]]; //Sound buzzer with 0x02 as data value
        }
        else if([str isEqualToString:@"High alert"])
        {
            [TIBLEUIBuzzer setTitle:@"Low alert" forState:UIControlStateNormal];
        
            [t soundBuzzer:0x01 p:[t activePeripheral]]; //Sound buzzer with 0x01 as data value
        
        }
        else if([str isEqualToString:@"Low alert"])
        {
            [TIBLEUIBuzzer setTitle:@"No alert" forState:UIControlStateNormal];
        
            [t soundBuzzer:0x00 p:[t activePeripheral]]; //Sound buzzer with 0x00 as data value
        
        }
        else if([str isEqualToString:@"No alert"])
        {
            if(((BLETabBarController *)self.parentViewController).DeviceType == TI_keyfob)
            {
                [TIBLEUIBuzzer setTitle:@"Keyfob_LED1" forState:UIControlStateNormal];
        
                [t soundBuzzer:0x03 p:[t activePeripheral]]; //Sound buzzer with 0x02 as data value
            }
            else if(((BLETabBarController *)self.parentViewController).DeviceType == CSR_security_tag)
            {
                [TIBLEUIBuzzer setTitle:@"Find Me" forState:UIControlStateNormal];
            }
            else
            {
                [TIBLEUIBuzzer setTitle:@"Sound buzzer" forState:UIControlStateNormal];
            }
        }
        else if([str isEqualToString:@"Keyfob_LED1"])
        {
            [TIBLEUIBuzzer setTitle:@"Keyfob_LED2" forState:UIControlStateNormal];
        
            [t soundBuzzer:0x04 p:[t activePeripheral]]; //Sound buzzer with 0x02 as data value
        
        }
        else if([str isEqualToString:@"Keyfob_LED2"])
        {
            [TIBLEUIBuzzer setTitle:@"Sound buzzer" forState:UIControlStateNormal];
        }
    }
}

- (IBAction)BLE_Scene_Connect:(id)sender {
    
    //printf("BLE Scene Connect button!\r\n");
    
    //self.BLE_Service.text = @"abd\ndef\n\n\nghi";
    //self.BLE_Device.text = @"123";    
#if 0
    self.BLE_Device.text =  [((BLETabBarController *)self.parentViewController).DevName stringByAppendingString:@" test "];
#endif
}

- (void) batteryIndicatorTimer:(NSTimer *)timer {
    TIBLEUIBatteryBar.progress = t.batteryLevel / 100;
    [t readBattery:[t activePeripheral]];               // Read battery value of keyfob again
    
    //NSLog(@"Read battery level!\n");
}

-(void) connectionTimer:(NSTimer *)timer {
    /*    if(t.peripherals.count > 0)
     {
     for (CBPeripheral *p in t.peripherals) {
     if ([p.name rangeOfString:@"Keyfob"].location != NSNotFound) {
     [t connectPeripheral:p];
     printf("Equal\n");
     } else {
     printf("Not equal\n");
     }
     }
     //[t connectPeripheral:[t.peripherals objectAtIndex:0]];
     
     }
     else
     */
    [TIBLEUISpinner stopAnimating];
    [TIBLEUIConnBtn setTitle:@"Scan and Connect" forState:UIControlStateNormal];
}

-(void) UpdateRSSITimer:(NSTimer *)timer {
    
    if(t.activePeripheral.isConnected)
    {
        [t.activePeripheral readRSSI];
    
        //NSLog(@"Update RSSI!\n");
    
        self.BLE_RSSI.text = t.DevRSSI;
    }
}

// Method from TIBLECBKeyfobDelegate, called when accelerometer values are updated
-(void) accelerometerValuesUpdated:(char)x y:(char)y z:(char)z {
    //TIBLEUIAccelXBar.progress = (float)(x + 50) / 100;
    //TIBLEUIAccelYBar.progress = (float)(y + 50) / 100;
    //TIBLEUIAccelZBar.progress = (float)(z + 50) / 100;
}
// Method from TIBLECBKeyfobDelegate, called when key values are updated
-(void) keyValuesUpdated:(char)sw {
    //printf("Key values updated ! \r\n");
    if (sw & 0x1) [TIBLEUILeftButton setOn:TRUE];
    else [TIBLEUILeftButton setOn: FALSE];
    if (sw & 0x2) [TIBLEUIRightButton setOn: TRUE];
    else [TIBLEUIRightButton setOn: FALSE];
    
}

//Method from TIBLECBKeyfobDelegate, called when keyfob has been found and all services have been discovered
-(void) keyfobReady:(char)DeviceFound GATT_Service_1:(int)Service_1 GATT_Service_2:(int)Service_2{
    NSString *str;
    str = TIBLEUIBuzzer.currentTitle;
    if([str isEqualToString:@"Scanning.."]){
        [TIBLEUIConnBtn setTitle:@"Disconnect" forState:UIControlStateNormal];
    }
    else if([str isEqualToString:@"Discovering characteristics.."]) {
        [TIBLEUIConnBtn setTitle:@"Disconnect" forState:UIControlStateNormal];        
    }
    
    ((BLETabBarController *)self.parentViewController).DeviceType = DeviceFound;
    
    //if(DeviceFound)
    if(((BLETabBarController *)self.parentViewController).DeviceType == TI_keyfob)
    {
        // Start battery indicator timer, calls batteryIndicatorTimer method every 2 seconds
        //[NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(batteryIndicatorTimer:) userInfo:nil repeats:YES];
        
        //TI KeyfobDemo
        MAIN_DEBUG(("TI keyfob found!\r\n"));
        
        //[t enableAccelerometer:[t activePeripheral]];   // Enable accelerometer (if found)
        [t enableButtons:[t activePeripheral]];         // Enable button service (if found)
        [t enableTXPower:[t activePeripheral]];         // Enable TX power service (if found)
        
        [TIBLEUISpinner stopAnimating];
#if 1
        ((BLETabBarController *)self.parentViewController).DeviceIsConnect = YES;
        
        ((BLETabBarController *)self.parentViewController).DevName = [((BLETabBarController *)self.parentViewController).DevName stringByAppendingString:t.activePeripheral.name];
        
        [self logMessage:[NSString stringWithFormat:@"Connected to %@", t.activePeripheral.name]];
                        
        if(Service_1 != 0 || Service_2 != 0)
        {
            NSArray *array1 = [NSArray arrayWithObjects:@"Immediate alert <1802>\n",@"Linkl loss <1803>\n",@"Tx power <1804>\n",@"Current time <1805>\n",@"Reference time updte <1806>\n",@"Next DST change <1807>\n",@"Glucose <1808>\n",@"Health thermometer <1809>\n",@"Device information <180a>\n",@"Heart rate <180d>\n", nil];
            
            NSArray *array2 = [NSArray arrayWithObjects:@"Phone alert <180e>\n",@"Battery <180f>\n",@"Blood pressure <1810>\n",@"Alert notification <1811>\n",@"Human interface <1812>\n",@"Scan parameters <1813>\n",@"Running speed cadence <1814>\n",@"Cycling speed cadence <1816>\n",@"Cycling power <1818>\n",@"Location navigation <1819>\n", nil];
                                    
            for(int k = 0; k < 10; k++)
            {
                if((Service_1 & (1 << k)))
                {
                    id mystr1 = [array1 objectAtIndex:k];

                    ((BLETabBarController *)self.parentViewController).GATTService = [((BLETabBarController *)self.parentViewController).GATTService stringByAppendingString:mystr1];
                }
  
                if((Service_2 & (1 << k)))
                {
                    id mystr2 = [array2 objectAtIndex:k];
                        
                    ((BLETabBarController *)self.parentViewController).GATTService = [((BLETabBarController *)self.parentViewController).GATTService stringByAppendingString:mystr2];
                }
            }
        }
#endif
        
        //[t.activePeripheral readRSSI];
    }
    else if(((BLETabBarController *)self.parentViewController).DeviceType == CSR_security_tag)
    {
        [TIBLEUISpinner stopAnimating];        
                
        ((BLETabBarController *)self.parentViewController).DeviceIsConnect = YES;
        
        if([((BLETabBarController *)self.parentViewController).DevName isEqualToString:@""])
        {
            MAIN_DEBUG(("CSR device found!\r\n"));
            
            ((BLETabBarController *)self.parentViewController).DevName = [((BLETabBarController *)self.parentViewController).DevName stringByAppendingString:t.activePeripheral.name];
            
            [self logMessage:[NSString stringWithFormat:@"Connected to %@", t.activePeripheral.name]];
        }
        
        if([((BLETabBarController *)self.parentViewController).GATTService isEqualToString:@""])
        {
            if(Service_1 != 0 || Service_2 != 0)
            {
                NSArray *array1 = [NSArray arrayWithObjects:@"Immediate alert <1802>\n",@"Linkl loss <1803>\n",@"Tx power <1804>\n",@"Current time <1805>\n",@"Reference time updte <1806>\n",@"Next DST change <1807>\n",@"Glucose <1808>\n",@"Health thermometer <1809>\n",@"Device information <180a>\n",@"Heart rate <180d>\n", nil];
                
                NSArray *array2 = [NSArray arrayWithObjects:@"Phone alert <180e>\n",@"Battery <180f>\n",@"Blood pressure <1810>\n",@"Alert notification <1811>\n",@"Human interface <1812>\n",@"Scan parameters <1813>\n",@"Running speed cadence <1814>\n",@"Cycling speed cadence <1816>\n",@"Cycling power <1818>\n",@"Location navigation <1819>\n", nil];

                
                for(int k = 0; k < 10; k++)
                {
                    if((Service_1 & (1 << k)))
                    {
                        id mystr1 = [array1 objectAtIndex:k];
                    
                        ((BLETabBarController *)self.parentViewController).GATTService = [((BLETabBarController *)self.parentViewController).GATTService stringByAppendingString:mystr1];
                    }
                
                    if((Service_2 & (1 << k)))
                    {
                        id mystr2 = [array2 objectAtIndex:k];
                    
                        ((BLETabBarController *)self.parentViewController).GATTService = [((BLETabBarController *)self.parentViewController).GATTService stringByAppendingString:mystr2];
                    }
                }
            }
        }
    }
    else
    {
        [TIBLEUISpinner stopAnimating];
        
        ((BLETabBarController *)self.parentViewController).DeviceIsConnect = YES;
        
        if([((BLETabBarController *)self.parentViewController).DevName isEqualToString:@""])
        {
            MAIN_DEBUG(("Unknown device found!\r\n"));
            
            ((BLETabBarController *)self.parentViewController).DevName = [((BLETabBarController *)self.parentViewController).DevName stringByAppendingString:t.activePeripheral.name];
            
            [self logMessage:[NSString stringWithFormat:@"Connected to %@", t.activePeripheral.name]];
            
            NSLog(@"%@\n",t.activePeripheral.name);
        }
        
        if([((BLETabBarController *)self.parentViewController).GATTService isEqualToString:@""])
        {
            if(Service_1 != 0 || Service_2 != 0)
            {
                //NSLog(@"check point xxx\n");
                
                NSArray *array1 = [NSArray arrayWithObjects:@"Immediate alert <1802>\n",@"Linkl loss <1803>\n",@"Tx power <1804>\n",@"Current time <1805>\n",@"Reference time updte <1806>\n",@"Next DST change <1807>\n",@"Glucose <1808>\n",@"Health thermometer <1809>\n",@"Device information <180a>\n",@"Heart rate <180d>\n", nil];
                
                NSArray *array2 = [NSArray arrayWithObjects:@"Phone alert <180e>\n",@"Battery <180f>\n",@"Blood pressure <1810>\n",@"Alert notification <1811>\n",@"Human interface <1812>\n",@"Scan parameters <1813>\n",@"Running speed cadence <1814>\n",@"Cycling speed cadence <1816>\n",@"Cycling power <1818>\n",@"Location navigation <1819>\n", nil];
                
                for(int k = 0; k < 10; k++)
                {
                    if((Service_1 & (1 << k)))
                    {
                        id mystr1 = [array1 objectAtIndex:k];
                        
                        ((BLETabBarController *)self.parentViewController).GATTService = [((BLETabBarController *)self.parentViewController).GATTService stringByAppendingString:mystr1];
                    }
                    
                    if((Service_2 & (1 << k)))
                    {
                        id mystr2 = [array2 objectAtIndex:k];
                        
                        ((BLETabBarController *)self.parentViewController).GATTService = [((BLETabBarController *)self.parentViewController).GATTService stringByAppendingString:mystr2];
                    }
                }
            }
        }    
    }
    
    //
    if(((BLETabBarController *)self.parentViewController).DeviceType != TI_keyfob)
    {
        if([self.BLE_Service.text rangeOfString:@"<1802>"].location != NSNotFound)//Immediate Alert service found!
        {
            [TIBLEUIBuzzer setTitle:@"Find Me" forState:UIControlStateNormal];
        }
    }
    
    if(((BLETabBarController *)self.parentViewController).DeviceType != Unknown_Device)
    {
        [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(UpdateRSSITimer:) userInfo:nil repeats:YES];
        
        //Battery Service found,start readBattery timer!
        if([self.BLE_Service.text rangeOfString:@"<180f>"].location != NSNotFound)
        {
            // Start battery indicator timer, calls batteryIndicatorTimer method every 2 seconds
            [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(batteryIndicatorTimer:) userInfo:nil repeats:YES];
        }
    }
}

//Method from TIBLECBKeyfobDelegate, called when TX powerlevel values are updated
-(void) TXPwrLevelUpdated:(char)TXPwr {
}

- (void) logMessage:(NSString *)message
{
    ((BLETabBarController *)self.parentViewController).Log = [((BLETabBarController *)self.parentViewController).Log stringByAppendingFormat:@"%@\n", message];
}

-(void) logBLEMessage:(NSString *)message
{
    ((BLETabBarController *)self.parentViewController).Log = [((BLETabBarController *)self.parentViewController).Log stringByAppendingFormat:@"%@\n", message];    
}

//Update BLE Characteristics : <2a00>,<2a01>..
-(void) UpdateCharacteristic:(NSString *)ble_char
{    
    if([ble_char rangeOfString:@"<2a"].location != NSNotFound)
    {
        //NSLog(@"%@\n",ble_char);
        [((BLETabBarController *)self.parentViewController).DevCharacteristics addObject:ble_char];
    }
}
@end
