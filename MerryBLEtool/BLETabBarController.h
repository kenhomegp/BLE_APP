//
//  BLETabBarController.h
//  MerryBLEtool
//
//  Created by merry on 13-12-18.
//  Copyright (c) 2013年 merry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEDebug.h"

@interface BLETabBarController : UITabBarController
@property (nonatomic) bool CBInit;
@property (nonatomic) bool DeviceIsConnect;
@property (nonatomic) NSString *DevName;
@property (nonatomic) NSString *GATTService;
@property (nonatomic) NSString *Log;
@property (strong,nonatomic) NSMutableDictionary *BLE_lookup_table;
@property (nonatomic) char DeviceType;
@property (strong,nonatomic) NSMutableArray *DevCharacteristics;
@property (nonatomic) NSString *PeripheralRSSI;
@end
