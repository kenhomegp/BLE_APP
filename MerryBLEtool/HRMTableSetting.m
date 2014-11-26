//
//  HRMTableSetting.m
//  MyHRM
//
//  Created by merry on 14-11-17.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import "HRMTableSetting.h"

@interface HRMTableSetting ()

@end

@implementation HRMTableSetting
@synthesize UserName;
@synthesize UserAge;
@synthesize APPConfig;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    //Set focus to next UITextField
    if(textField.tag == 70)//Name
    {
        [self.UserAge becomeFirstResponder];
    }
    else if(textField.tag == 71)//Age
    {
        [self.UserRHR becomeFirstResponder];
    }
    
    [self CalculateHRData];
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.UserName.delegate = self;
    self.UserAge.delegate = self;
    self.UserMaxHR.delegate = self;
    self.UserRHR.delegate = self;
    self.UserTHR1.delegate = self;
    
    //Custom button
    [self.LoginButton setBackgroundImage:[UIImage imageNamed:@"Button1.png"] forState:UIControlStateNormal];
    [self.LoginButton setBackgroundImage:[UIImage imageNamed:@"Button1Pressed.png"] forState:UIControlStateHighlighted];
    
    if(!([self.HR_UserName isEqualToString:@""]))
        UserName.text = self.HR_UserName;
    
    if(!([self.HR_UserAge isEqualToString:@""]))
    {
        UserAge.text = self.HR_UserAge;
        self.UserAgeValue = [UserAge.text intValue];
    }
    
    self.UserRHR.text = [NSString stringWithFormat:@"%ld",(long)self.SetRHR];
    
    if((self.APPConfig & TargetZoneAlarm))
        [self.AlarmTHR setOn:YES];
    else
        [self.AlarmTHR setOn:NO];
    
    if((self.APPConfig & HRNotification))
        [self.HRNotify setOn:YES];
    else
        [self.HRNotify setOn:NO];
    
    if(self.SetMaxHR != 0)
    {
        self.SetNormalMaxHR.value = self.SetMaxHR;
        self.NormalMaxHR.text = [NSString stringWithFormat:@"%d",(int)self.SetNormalMaxHR.value];
    }
    
    if(self.SetMinHR != 0)
    {
        self.SetNormalMinHR.value = self.SetMinHR;
        self.NormalMinHR.text = [NSString stringWithFormat:@"%d",(int)self.SetNormalMinHR.value];
    }
        
    switch(self.APPConfig & ApplicationMode)
    {
        case (Normal):
            self.APPModeSelect.selectedSegmentIndex = 0;
            break;
        case (Sports):
            self.APPModeSelect.selectedSegmentIndex = 1;
            break;
        case (Sleep):
            self.APPModeSelect.selectedSegmentIndex = 2;
            break;
        default:
            break;
    }
    
    if(!([self.HR_UserAge isEqualToString:@""]) && self.SetRHR != 0)
        [self CalculateHRData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if(section == 0)
        return 5;
    else if(section == 1)
        return 3;
    else if(section == 2)
        return 2;
    else
        return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
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

- (void)SaveUserData
{
    int tempMaxHR,tempRHR,tempUpperTHR,tempLowerTHR,tempHRReserve = 0;
    int i,j;
    
    if([UserName.text isEqualToString:@""])
        return;
    if([UserAge.text isEqualToString:@""])
        return;
    if(([self.UserRHR.text intValue]) == 0)
        return;
    
    [self CalculateHRData];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:UserName.text forKey:@"myHRMApp_Name"];
    [userDefaults setObject:UserAge.text forKey:@"myHRMApp_Age"];
    tempMaxHR = 220 - ([self.HR_UserAge intValue]);
    [userDefaults setInteger:tempMaxHR forKey:@"myHRMApp_MaxHR"];
    tempRHR = [self.UserRHR.text intValue];
    [userDefaults setInteger:tempRHR forKey:@"myHRMApp_RHR"];
    tempHRReserve = tempMaxHR - tempRHR;
    tempUpperTHR = (tempHRReserve * 0.8) + tempRHR;
    tempLowerTHR = (tempHRReserve * 0.6) + tempRHR;
    [userDefaults setInteger:tempUpperTHR forKey:@"myHRMApp_UpperTHR"];
    [userDefaults setInteger:tempLowerTHR forKey:@"myHRMApp_LowerTHR"];
    i = [self.NormalMaxHR.text intValue];
    j = [self.NormalMinHR.text intValue];
    [userDefaults setInteger:i forKey:@"myHRMApp_SetMaxHR"];
    [userDefaults setInteger:j forKey:@"myHRMApp_SetMinHR"];
    
    if(self.AlarmTHR.isOn)
        self.APPConfig |= TargetZoneAlarm;
    else
        self.APPConfig &= ~(TargetZoneAlarm);
    
    if(self.HRNotify.isOn)
        self.APPConfig |= HRNotification;
    else
        self.APPConfig &= ~(HRNotification);
    
    [userDefaults setInteger:self.APPConfig forKey:@"myHRMApp_APPConfig"];
    
    [userDefaults synchronize];
    
    //NSLog(@"SaveUserData");
}

- (void) CalculateHRData
{
    _HR_UserAge = UserAge.text;
    
    NSInteger tmpAge = [_HR_UserAge intValue];
    if(tmpAge != self.UserAgeValue)
        self.UserAgeValue = tmpAge;
    
    //NSLog(@"Age : %@",_HR_UserAge);
    
    //if(!([self.HR_UserAge isEqualToString:@""]))
    if(tmpAge != 0)
    {
        NSInteger tempMaxHR,tempRHR,tempUpperTHR,tempLowerTHR,tempHRReserve = 0;
        
        tempMaxHR = 220 - ([self.HR_UserAge intValue]);
        self.MaximumHR = tempMaxHR;
        
        //self.MaxHR.text = [NSString stringWithFormat:@"Maximum Heart Rate = %ld",(long)tempMaxHR];
        
        self.UserMaxHR.text = [NSString stringWithFormat:@"%ld",(long)tempMaxHR];
        
        tempRHR = [self.UserRHR.text intValue];
        
        //NSLog(@"RHR : %@,%d",self.UserRHR.text,tempRHR);
        
        //if(!([self.UserRHR.text isEqualToString:@""]))
        if(tempRHR != 0)
        {
            if(self.SetRHR != tempRHR)
                self.SetRHR = tempRHR;
            
            //tempRHR = [self.UserRHR.text intValue];
            
            //if((tempRHR > 0) && (tempRHR < 90))
            if(self.SetRHR != 0)
            {
                //self.SetRHR = tempRHR;
                
                tempRHR = self.SetRHR;
                //NSLog(@"RestHR = %d",self.SetRHR);
                tempHRReserve = tempMaxHR - tempRHR;
                //NSLog(@"HR reserve = %d",tempHRReserve);
                tempUpperTHR = (tempHRReserve * 0.8) + tempRHR;
                tempLowerTHR = (tempHRReserve * 0.6) + tempRHR;
                self.UpperTHR = tempUpperTHR;
                self.LowerTHR = tempLowerTHR;
                //self.UserTHR.text = [NSString stringWithFormat:@"Target Heart Rate : %ld ~ %ld",(long)tempLowerTHR , (long)tempUpperTHR];
                self.UserTHR1.text = [NSString stringWithFormat:@"%ld ~ %ld",(long)tempLowerTHR , (long)tempUpperTHR];
                
            }
        }
    }
}

- (IBAction)SaveHRData:(id)sender {
    [self SaveUserData];
    [[self delegate] APPSetting:self.APPConfig];
    [[self delegate] passHeartRateData:self.MaximumHR SetMaxHR:self.SetMaxHR SetMinHR:self.SetMinHR RestHeartRate:self.SetRHR UpperTargetHeartRate:self.UpperTHR LowerTargetHeartRate:self.LowerTHR];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)MaxValueChanged:(id)sender {
    float i = self.SetNormalMaxHR.value;
    self.NormalMaxHR.text = [NSString stringWithFormat:@"%d",(int)i];
    self.SetMaxHR = (int)i;
}

- (IBAction)MinValueChanged:(id)sender {
    float i = self.SetNormalMinHR.value;
    self.NormalMinHR.text = [NSString stringWithFormat:@"%d",(int)i];
    self.SetMinHR = (int)i;
}

- (IBAction)APPModeChange:(id)sender {
    switch([sender selectedSegmentIndex])
    {
        case 0:
            //NSLog(@"Normal mode");
            self.APPConfig &= ~(ApplicationMode);
            self.APPConfig |= Normal;
            break;
        case 1:
            //NSLog(@"Sports mode");
            self.APPConfig &= ~(ApplicationMode);
            self.APPConfig |= Sports;
            break;
        case 2:
            //NSLog(@"Sleep mode");
            self.APPConfig &= ~(ApplicationMode);
            self.APPConfig |= Sleep;
            break;
        default:
            break;
    }
}
- (IBAction)backgroundTap:(id)sender
{
    [self.view endEditing:YES];
    
    [self CalculateHRData];
}
@end
