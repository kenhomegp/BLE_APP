//
//  HRHealthyCare.h
//  MerryBLEtool
//
//  Created by merry on 14-10-15.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HRMSetting.h"

#define TargetZoneAlarm     0x01
#define HRNotification      0x02
#define ApplicationMode     0x0C

#define Normal              0x04
#define Sports              0x08
#define Sleep               0x0C

//@protocol passingDataDelegate <NSObject>
//-(void) passComdFromHRHealthyView : (NSString *)string;
//@end

@interface HRHealthyCare : UIViewController
//@property (nonatomic, assign) id<passingDataDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *BackgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *HeartImage;
@property (nonatomic) NSInteger APPConfig;
@property (nonatomic) NSInteger SeguePassingData;
@property (weak, nonatomic) IBOutlet UILabel *TitleLabel;
- (IBAction)ChgHRThreshold:(id)sender;
@end
