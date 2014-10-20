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
    
    [self.BackgroundImage setImage:[UIImage imageNamed:@"Jogging"]];
    
    [self.HeartImage setImage:[UIImage imageNamed:@"HeartImage"]];
    
    switch(self.APPConfig & ApplicationMode)
    {
        case (Normal):
            self.TitleLabel.text = @"一般模式";
            break;
         case (Sleep):
            self.TitleLabel.text = @"睡眠模式";
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
