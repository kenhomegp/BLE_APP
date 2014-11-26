//
//  CustomHeaderCell.m
//  MyHRM
//
//  Created by merry on 14-11-24.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import "CustomHeaderCell.h"

@implementation CustomHeaderCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/*
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 68.0;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // 1. Dequeue the custom header cell
    CustomHeaderCell* headerCell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    
    // 2. Set the various properties
    headerCell.APP_Mode.text = @"Custom header from cell";
    [headerCell.APP_Mode sizeToFit];
    
    headerCell.Run_Frequency.text = @"The subtitle";
    [headerCell.Run_Frequency sizeToFit];
    
    headerCell.image.image = [UIImage imageNamed:@"smiley-face"];
    
    // 3. And return
    return headerCell;
}
*/

@end
