//
//  HRMDataObject.m
//  MyHRM
//
//  Created by merry on 14-11-12.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import "HRMDataObject.h"

@implementation HRMDataObject
@synthesize TimeStr,DistanceStr,CaloriesStr,HRM,APPConfig;

- (void)dealloc
{
    TimeStr = nil;
    DistanceStr = nil;
    CaloriesStr = nil;
    HRM = 0;
    APPConfig = 0;
}

@end
