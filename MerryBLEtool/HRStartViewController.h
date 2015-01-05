//
//  HRStartViewController.h
//  MyHRM
//
//  Created by merry on 14-11-9.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HRMCBTask.h"
#import "BLECBTask.h"
#import "BLEDebug.h"
#import "HRMTableSetting.h"

#ifdef BLE_Debug
@interface HRStartViewController : UITableViewController <CoreBTDelagate , UIAlertViewDelegate >
#else
@interface HRStartViewController : UITableViewController <BLECBDelegate , UIAlertViewDelegate >
#endif
{
#ifdef BLE_Debug
    BLECBTask *CoreBTObj;
#else
    HRMCBTask *CoreBTObj;
#endif
}
@property (nonatomic , strong) NSString *BLE_device1;
@property (nonatomic , strong) NSString *BLE_device2;
@property (nonatomic , strong) NSString *BLE_device3;
@property (nonatomic , strong) NSString *CBStatus;
@property (nonatomic , strong) NSString *LastConnectDevice;
#ifdef BLE_Debug
@property (nonatomic , strong) NSString *Log;
#endif
@end
