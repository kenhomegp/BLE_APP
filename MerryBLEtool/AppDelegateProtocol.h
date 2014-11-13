//
//  AppDelegateProtocol.h
//  MyHRM
//
//  Created by merry on 14-11-12.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDataObject;

@protocol AppDelegateProtocol
- (AppDataObject*) theAppDataObject;
@end
