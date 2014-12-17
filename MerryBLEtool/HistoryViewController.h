//
//  HistoryViewController.h
//  MyHRM
//
//  Created by merry on 14/12/12.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HRMTableSetting.h"

@interface HistoryViewController : UIViewController <UIPickerViewDelegate , UIPickerViewDataSource>
@property (strong, nonatomic) IBOutlet UIPickerView *DatePicker;
@property (strong, nonatomic) IBOutlet UITableView *HistoryTable;
@property (nonatomic , strong) NSString *HRMeasurement;
@property (nonatomic , strong) NSString *HRCalories;
@property (nonatomic , strong) NSString *HRTime;
@end
