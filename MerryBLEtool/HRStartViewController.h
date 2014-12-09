//
//  HRStartViewController.h
//  MyHRM
//
//  Created by merry on 14-11-9.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HRMCBTask.h"

@interface HRStartViewController : UITableViewController <BLECBDelegate , UIAlertViewDelegate >
{
    HRMCBTask *CoreBTObj;
}
@property (nonatomic , strong) NSString *BLE_device1;
@property (nonatomic , strong) NSString *BLE_device2;
@property (nonatomic , strong) NSString *BLE_device3;
@property (nonatomic , strong) NSString *CBStatus;
@property (nonatomic , strong) NSString *LastConnectDevice;
@end
