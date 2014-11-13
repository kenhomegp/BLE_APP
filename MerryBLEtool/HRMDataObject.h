//
//  HRMDataObject.h
//  MyHRM
//
//  Created by merry on 14-11-12.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDataObject.h"

@interface HRMDataObject : AppDataObject
{
    NSString    *TimeStr;
    NSString    *DistanceStr;
    NSString    *CaloriesStr;
    NSInteger   HRM;
}
@property (nonatomic , copy) NSString *TimeStr;
@property (nonatomic , copy) NSString *DistanceStr;
@property (nonatomic , copy) NSString *CaloriesStr;
@property (nonatomic) NSInteger HRM;
@end
