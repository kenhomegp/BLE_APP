//
//  HistoryViewController.m
//  MyHRM
//
//  Created by merry on 14/12/12.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import "HistoryViewController.h"

@interface HistoryViewController ()
{
    //NSArray *MyPickerData;
    NSMutableArray *HRDataArray;
    NSMutableArray *HRBpmArray;
    NSMutableArray *HRTimeArray;
    NSMutableArray *HRCaloriesArray;
}
@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"HistoryVC", @"title");
    
    //Test data
    //MyPickerData = @[@"Item 1", @"Item 2", @"Item 3", @"Item 4", @"Item 5", @"Item 6"];
    //MyPickerData = [NSArray arrayWithObjects:@"Test 123",@"Test456", nil];
    
    HRDataArray = [NSMutableArray arrayWithCapacity:10];
    HRBpmArray = [NSMutableArray arrayWithCapacity:10];
    HRTimeArray = [NSMutableArray arrayWithCapacity:10];
    HRCaloriesArray = [NSMutableArray arrayWithCapacity:10];
    
    self.DatePicker.dataSource = self;
    self.DatePicker.delegate = self;
    
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"HRMdata.txt"];
    [[NSFileManager defaultManager] changeCurrentDirectoryPath:path];
    
#ifdef NSFileHandleReadWrite
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *databuffer = nil;
    //int LoopCount = 0;
    if(fileHandle != nil)
    {
        int fileSize = (int)[fileHandle seekToEndOfFile];
        //NSLog(@"Read file size = %i",fileSize);
        
        if(fileSize != 0)
        {
            //LoopCount = fileSize/40;
            
            //for(int loop = 0; loop < LoopCount; loop++)
            for(int loop = 0; loop < 10; loop++)
            {
                //[fileHandle seekToFileOffset:(loop * 34)];
                //databuffer = [fileHandle readDataOfLength:34];
                [fileHandle seekToFileOffset:(loop * 40)];
                databuffer = [fileHandle readDataOfLength:40];
                
                //databuffer = [fileHandle readDataToEndOfFile];
                if(databuffer == nil)
                {
                    //NSLog(@"Read file , ERROR!!");
                    break;
                }
                else
                {
                    if(databuffer.length == 0)
                    {
                        //NSLog(@"Databuffer length = 0");
                        break;
                    }
                    
                    //NSLog(@"Parse Data %d",loop);
                    //Parse data
                    //NSRange Range1 = NSMakeRange(0, 10);
                    NSRange Range1 = NSMakeRange(0, 16);
                    NSData *SubData1 = [databuffer subdataWithRange:Range1];
                    NSString *DateString = [[NSString alloc] initWithData:SubData1 encoding:NSUTF8StringEncoding];
                    //NSLog(@"r1: %@",DateString);
                    [HRDataArray addObject:DateString];
                
                    //NSRange Range2 = NSMakeRange(10, 8);
                    NSRange Range2 = NSMakeRange(16, 8);
                    NSData *SubData2 = [databuffer subdataWithRange:Range2];
                    NSInteger HR;
                    [SubData2 getBytes:&(HR) length:sizeof(HR)];
                    //NSLog(@"r2: %lu", (unsigned long)HR);
                    [HRBpmArray addObject:[NSString stringWithFormat:@"%lu",HR]];
                
                    NSInteger calories;
                    //NSData *SubData3 = [databuffer subdataWithRange:NSMakeRange(18, 8)];
                    NSData *SubData3 = [databuffer subdataWithRange:NSMakeRange(24, 8)];
                    [SubData3 getBytes:&(calories) length:sizeof(calories)];
                    //NSLog(@"r3: %lu", (unsigned long)calories);
                    [HRCaloriesArray addObject:[NSString stringWithFormat:@"%lu",calories]];
                
                    //NSRange Range4 = NSMakeRange(26, 8);
                    NSRange Range4 = NSMakeRange(32, 8);
                    NSData *SubData4 = [databuffer subdataWithRange:Range4];
                    NSString *TimeString = [[NSString alloc] initWithData:SubData4 encoding:NSUTF8StringEncoding];
                    //NSLog(@"r4: %@",TimeString);
                    [HRTimeArray addObject:TimeString];
                    
                }
            }
        }
        [fileHandle closeFile];
    }
#else
    NSData *reader = [NSData dataWithContentsOfFile:path];
    //Read data
    NSString *DateString;
    DateString = [[NSString alloc] initWithData:[reader subdataWithRange:NSMakeRange(0, 10)] encoding:NSUTF8StringEncoding];
    //NSLog(@"r1: %@", DateString);
    
    NSInteger HR;
    [reader getBytes:&(HR) range:NSMakeRange(10, sizeof(HR))];
    //NSLog(@"r2: %lu", (unsigned long)HR);
    
    NSInteger calories;
    [reader getBytes:&(calories) range:NSMakeRange(10+sizeof(HR), sizeof(calories))];
    //NSLog(@"r3: %lu", (unsigned long)calories);
    
    NSString *HRTime;
    HRTime = [[NSString alloc] initWithData:[reader subdataWithRange:NSMakeRange(10+sizeof(HR)+sizeof(calories), 8)] encoding:NSUTF8StringEncoding];
    //NSLog(@"r4: %@", HRTime);
#endif
    
    self.HRMeasurement = [HRBpmArray objectAtIndex:0];
    self.HRCalories = [HRCaloriesArray objectAtIndex:0];
    self.HRTime = [HRTimeArray objectAtIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIPickerView delegate

// The number of columns of data
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //return MyPickerData.count;
    return [HRDataArray count];
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //return MyPickerData[row];
    return [HRDataArray objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    //NSLog(@"Select row = %lu",(unsigned long)row);
    self.HRMeasurement = [HRBpmArray objectAtIndex:row];
    self.HRCalories = [HRCaloriesArray objectAtIndex:row];
    self.HRTime = [HRTimeArray objectAtIndex:row];
    [self.HistoryTable reloadData];
}

#pragma mark - UITableView delegate
/****************************************************************************/
/*							TableView Delegates								*/
/****************************************************************************/

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell	*cell;
    //CBPeripheral	*peripheral;
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
    
        if([indexPath section] == 0)
        {
            //[[cell textLabel] setTextColor:[UIColor redColor]];
            [[cell textLabel] setTextColor:[UIColor blueColor]];
            //UIFont *myFont = [ UIFont fontWithName: @"Arial" size: 18.0 ];
            UIFont *myFont = [ UIFont fontWithName: @"ArialRoundedMTBold" size: 16.0 ];
            
            if([indexPath row] == 0)//Heart Rate measurement data
            {
                cell.textLabel.font = myFont;
                //[[cell textLabel] setText:@"test 1"];
                //[[cell textLabel] setText:self.HRMeasurement];
                NSString *str = NSLocalizedString(@"HistoryTableViewCell1", @"cell1");
                [[cell textLabel] setText:[str stringByAppendingString:self.HRMeasurement]];
                
                //[[cell imageView] setImage:[UIImage imageNamed:@"rsz_heartrate.png"]];
            }
            else if([indexPath row] == 1)
            {
                cell.textLabel.font = myFont;
                //[[cell textLabel] setText:@"test 2"];
                //[[cell textLabel] setText:self.HRTime];
                NSString *str = NSLocalizedString(@"HistoryTableViewCell2", @"cell2");
                [[cell textLabel] setText:[str stringByAppendingString:self.HRTime]];
                
                //[[cell imageView] setImage:[UIImage imageNamed:@"rsz_time.png"]];
            }
            else if([indexPath row] == 2)
            {
                cell.textLabel.font = myFont;
                //[[cell textLabel] setText:@"test 3"];
                //[[cell textLabel] setText:self.HRCalories];
                NSString *str = NSLocalizedString(@"HistoryTableViewCell3", @"cell3");
                [[cell textLabel] setText:[str stringByAppendingString:self.HRCalories]];
                
                //cell.imageView.image = [UIImage imageNamed:@"rsz_speed.png"];
            }
            else if([indexPath row] == 3)
            {
                cell.textLabel.font = myFont;
                [[cell textLabel] setText:@"Reserve"];
                
                //cell.imageView.image = [UIImage imageNamed:@"Energy.png"];
            }
            
        }
    
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
    //CBPeripheral	*peripheral;
    //NSArray			*devices;
    //NSInteger		row	= [indexPath row];
    
    if ([indexPath section] == 0) {
        //		devices = [[LeDiscovery sharedInstance] connectedServices];
        //        peripheral = [(LeTemperatureAlarmService*)[devices objectAtIndex:row] peripheral];
    } else {
        //		devices = [[LeDiscovery sharedInstance] foundPeripherals];
        //    	peripheral = (CBPeripheral*)[devices objectAtIndex:row];
    }
    
    /*
     if (![peripheral isConnected]) {
     //[[LeDiscovery sharedInstance] connectPeripheral:peripheral];
     //[currentlyConnectedSensor setText:[peripheral name]];
     
     //[currentlyConnectedSensor setEnabled:NO];
     //[currentTemperatureLabel setEnabled:NO];
     //[maxAlarmLabel setEnabled:NO];
     //[minAlarmLabel setEnabled:NO];
     }
     else
     {
     //if ( currentlyDisplayingService != nil ) {
     //    [currentlyDisplayingService release];
     //    currentlyDisplayingService = nil;
     //}
     
     
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
     
     }
     */
}

@end
