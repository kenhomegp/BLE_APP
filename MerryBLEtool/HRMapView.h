//
//  HRMapView.h
//  MerryBLEtool
//
//  Created by merry on 14-10-17.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#import "HRMSetting.h"

@protocol passMapPositionDelegate <NSObject>
-(void) passDistance : (double)Map_distance;
@end

@interface HRMapView : UIViewController <CLLocationManagerDelegate>
@property (nonatomic, assign) id<passMapPositionDelegate> delegate;
@property (nonatomic) NSInteger APPConfig;
//@property (nonatomic, retain) NSTimer *GetMyLocationTimer;
//@property (nonatomic, retain) CLLocation *previousLocation;
@end
