//
//  AboutViewController.m
//  MyHRM
//
//  Created by 黃銘隆 on 2015/1/20.
//  Copyright (c) 2015年 merry. All rights reserved.
//

#import "AboutViewController.h"

#import "HRMTableSetting.h"

#import "HRStartViewController.h"

@interface AboutViewController ()
{
   
}
@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //Load an external page into our UIWebView
    //NSURL *myNSURL = [[NSURL alloc] initWithString:@"http://www.merry.com.tw"];

#ifdef CustomBLEService
    UINavigationController *NavVC = (UINavigationController *)[self.tabBarController.viewControllers objectAtIndex:0];
    HRStartViewController *myVC = (HRStartViewController *)NavVC.topViewController;
    NSString *GPS = [NSString stringWithFormat:@"%f,%f",myVC.myLatitude,myVC.myLongitude];
    
    NSURL *myNSURL;
    if(myVC.myLatitude == 0.0 && myVC.myLongitude == 0.0)
    {
        myNSURL = [[NSURL alloc] initWithString:@"http://www.merry.com.tw"];
    }
    else
    {
        myNSURL = [[NSURL alloc] initWithString:[@"http://maps.google.com/?q=" stringByAppendingString:GPS]];
    }
#else
    NSURL *myNSURL = [[NSURL alloc] initWithString:@"http://maps.google.com/?q=24.161838,120.604486"];  //Merry Electronics Co.,Ltd
#endif
            
    NSURLRequest *myNSURLRequest = [[NSURLRequest alloc] initWithURL:myNSURL];
    
    [self.webView loadRequest:myNSURLRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
