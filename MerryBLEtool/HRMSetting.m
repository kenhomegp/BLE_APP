//
//  HRMSetting.m
//  MerryBLEtool
//
//  Created by merry on 14-9-24.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import "HRMSetting.h"
#import "HRMViewController.h"

@interface HRMSetting ()

@end

@implementation HRMSetting

@synthesize UserName;
@synthesize UserAge;
@synthesize APPConfig;

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
    _HR_UserName = @"";
    _HR_UserAge = @"";
    self.APPConfig = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backgroundTap:(id)sender
{
    [self.view endEditing:YES];
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

- (IBAction)SaveData:(id)sender {
    
    _HR_UserName = UserName.text;
    [[self delegate] setName:_HR_UserName];
    
    _HR_UserAge = UserAge.text;
    [[self delegate] setAge:_HR_UserAge];
    
    [[self delegate] APPSetting:self.APPConfig];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
