//
//  CustomHeaderCell.h
//  MyHRM
//
//  Created by merry on 14-11-24.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomHeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *APP_Mode;
@property (weak, nonatomic) IBOutlet UILabel *Run_Frequency;

@end
