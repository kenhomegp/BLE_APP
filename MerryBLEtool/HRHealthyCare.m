//
//  HRHealthyCare.m
//  MerryBLEtool
//
//  Created by merry on 14-10-15.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import "HRHealthyCare.h"

@interface HRHealthyCare ()

@end

@implementation HRHealthyCare

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
    
    //NSLog(@"SeguePassingData = %ld",self.SeguePassingData);
    
    switch(self.APPConfig & ApplicationMode)
    {
        case (Normal):
            //self.TitleLabel.text = @"一般模式";
            //self.title = @"心率偵測_一般模式";
            self.TitleLabel.text = NSLocalizedString(@"HCLabel", @"none");
            //self.title = NSLocalizedString(@"MainViewController", @"title");
            self.title = NSLocalizedString(@"HealthyCareVC", @"none");
            [self.BackgroundImage setImage:[UIImage imageNamed:@"HeartRateDemo.jpg"]];
            break;
         case (Sleep):
            //self.TitleLabel.text = @"睡眠模式";
            //self.title = @"心率偵測_睡眠模式";
            self.TitleLabel.text = NSLocalizedString(@"HCLabel", @"none");
            //self.title = NSLocalizedString(@"MainViewController", @"title");
            self.title = NSLocalizedString(@"HealthyCareVC", @"none");
            [self.BackgroundImage setImage:[UIImage imageNamed:@"sleepy.jpg"]];
            break;
        default:
            break;
    }
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

@end
