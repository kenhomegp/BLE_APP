//
//  AppDelegate.m
//  MerryBLEtool
//
//  Created by merry on 13-12-18.
//  Copyright (c) 2013年 merry. All rights reserved.
//

#import "AppDelegate.h"
#import <GoogleMaps/GoogleMaps.h>
#import "AppDelegateProtocol.h"
#import "HRMDataObject.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation AppDelegate

@synthesize APPState;
@synthesize theAppDataObject;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    switch(application.applicationState)
    {
        case UIApplicationStateActive :
            //NSLog(@"APP state Active\n");
            break;
        case UIApplicationStateBackground :
            APPState = @"Background";
            //NSLog(@"APP state Background\n");
            break;
        case UIApplicationStateInactive :
            //NSLog(@"APP state Inactive\n");
            break;
        default :
            break;
    }
    
    //[[UINavigationBar appearance] setBarTintColor:[UIColor yellowColor]];
    //[[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x067AB5)];
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x00D3F2)];
    
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = CGSizeMake(0, 1);
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,shadow, NSShadowAttributeName,[UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil]];
    
    //Google Map service
    [GMSServices provideAPIKey:@"AIzaSyDs4IWNLiwvRicNC9-tuJvz7A347tQ-r8M"];
    
    
    //Passing data from APP delegate to View Controller
    /*
    UINavigationController *vc = (UINavigationController *)self.window.rootViewController;
    HRMViewController *myvc = (HRMViewController *)vc.topViewController;
    myvc.APPState = APPState;
    */
    
    self.theAppDataObject = [[HRMDataObject alloc] init];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    //NSLog(@"appWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    APPState = @"Background";
    NSLog(@"App Enter Background\n");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    if([self.APPState isEqualToString:@"Background"])
    {
        APPState = @"Foreground";
        //NSLog(@"APP state : Background to Foreground\n");
        /*
        UINavigationController *vc = (UINavigationController *)self.window.rootViewController;
        HRMViewController *myvc = (HRMViewController *)vc.topViewController;
        myvc.APPState = APPState;
        */
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //NSLog(@"App Become Active\n");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
