//
//  HRMapView.h
//  MerryBLEtool
//
//  Created by merry on 14-10-17.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "HRMTableSetting.h"

#define iPhoneBatteryLevelx
#define iPhoneMapFullScreenx
#define CoreLocationBackgroundx

@protocol passMapPositionDelegate <NSObject>
-(void) passDistance : (double)Map_distance;
-(void) passCommand : (NSString *)string;
@end

@interface HRMapView : UIViewController <CLLocationManagerDelegate , UIAlertViewDelegate>
@property (nonatomic, assign) id<passMapPositionDelegate> delegate;
@property (nonatomic) NSInteger APPConfig;
@property (retain, nonatomic) IBOutlet UIButton *CustomButton;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *SwipeRecognizer;
- (IBAction)SwipeLeftAction:(id)sender;
- (IBAction)PressStartButton:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *HeartRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *TimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *CaloriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *BatteryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *HRImage;
@property (weak, nonatomic) IBOutlet UIImageView *TimeImage;
@property (weak, nonatomic) IBOutlet UIImageView *BattImage;
@property (weak, nonatomic) IBOutlet UIImageView *CaloriesImage;
- (IBAction)DeleteTrackFile:(id)sender;
- (IBAction)DebugFunction:(id)sender;
@end
