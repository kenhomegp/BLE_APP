//
//  HRStartViewController.m
//  MyHRM
//
//  Created by merry on 14-11-9.
//  Copyright (c) 2014年 merry. All rights reserved.
//

#import "HRStartViewController.h"
#import "HRMViewController.h"
#import "HRHealthyCare.h"
#import "HRMSetting.h"

#import "HRMSetting.h"
#import "AppDelegateProtocol.h"
#import "HRMDataObject.h"

@interface HRStartViewController ()

@end

@implementation HRStartViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Assign our own backgroud for the view
    self.parentViewController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"common_bg"]];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    //self.title = @"應用類型";
    self.title = @"Application Mode";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    
    //HRMDataObject* theDataObject = [self theAppDataObject];
    HRMDataObject* theDataObject = [self theAppDataObject];
    theDataObject.APPConfig &= ~(ApplicationMode);
    
    if ([segue.identifier isEqualToString:@"SegueForHRM"]) {
        //NSIndexPath *indexPath = nil;
        //indexPath = [self.tableView indexPathForSelectedRow];
        //NSLog(@"HRM %ld",(long)indexPath.row);
        
        HRMViewController *vc = [segue destinationViewController];
        vc.APPConfig &= ~(ApplicationMode);
        vc.APPConfig |= Sports;
        
        theDataObject.APPConfig |= Sports;
    }
    else if([segue.identifier isEqualToString:@"SegueForTest"])
    {
        indexPath = [self.tableView indexPathForSelectedRow];
        //NSLog(@"TEST %ld",(long)indexPath.row);
        
        HRHealthyCare *vc = [segue destinationViewController];
        vc.SeguePassingData = indexPath.row;
        
        vc.APPConfig &= ~(ApplicationMode);
        if(indexPath.row == 1)
        {
            vc.APPConfig |= Normal;
            theDataObject.APPConfig |= Normal;
        }
        else if(indexPath.row == 2)
        {
            vc.APPConfig |= Sleep;
            theDataObject.APPConfig |= Sleep;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 3;
}

- (UIImage *)cellBackgroundForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowCount = [self tableView:[self tableView] numberOfRowsInSection:0];
    NSInteger rowIndex = indexPath.row;
    UIImage *background = nil;
    
    if (rowIndex == 0) {
        background = [UIImage imageNamed:@"cell_top.png"];
    } else if (rowIndex == rowCount - 1) {
        background = [UIImage imageNamed:@"cell_bottom.png"];
    } else {
        background = [UIImage imageNamed:@"cell_middle.png"];
    }
    
    return background;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UIImageView *APPImage = (UIImageView *)[cell viewWithTag:100];
    UILabel *APPTitle = (UILabel *)[cell viewWithTag:101];
    UILabel *APPDetail = (UILabel *)[cell viewWithTag:102];
    UILabel *APPUseFreq = (UILabel *)[cell viewWithTag:103];
    
    if(indexPath.row == 0)
    {
        APPImage.image = [UIImage imageNamed:@"Distance.png"];
        //APPTitle.text = @"跑步";
        //APPDetail.text = @"加強肌肉與耐力";
        APPTitle.text = @"Running";
        APPDetail.text = @"Strengthen the muscles";
        APPUseFreq.text = @"60%";
    }
    else if(indexPath.row == 1)
    {
        APPImage.image = [UIImage imageNamed:@"AppHealthy.png"];
        //APPTitle.text = @"保健";
        //APPDetail.text = @"隨時隨地監控心跳";
        APPTitle.text = @"Healthy care";
        APPDetail.text = @"Monitor heartbeat any time";
        APPUseFreq.text = @"30%";
        
    }
    else if(indexPath.row == 2)
    {
        APPImage.image = [UIImage imageNamed:@"AppSleep.png"];
        //APPTitle.text = @"睡眠";
        //APPDetail.text = @"放鬆並輔助睡眠";
        APPTitle.text = @"Sleeping";
        APPDetail.text = @"Relaxation and help sleep";
        APPUseFreq.text = @"10%";
    }
    
    /*
    // Assign our own background image for the cell
    UIImage *background = [self cellBackgroundForRowAtIndexPath:indexPath];
    
    UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:background];
    cellBackgroundView.image = background;
    cell.backgroundView = cellBackgroundView;
    */
    
    return cell;
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        //NSLog(@"Test 0");
    }
    else if(indexPath.row == 1)
    {
        //NSLog(@"Test 1");
    }
    else if(indexPath.row == 2)
    {
        //NSLog(@"Test 2");
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        [self performSegueWithIdentifier:@"SegueForHRM" sender:[tableView cellForRowAtIndexPath:indexPath]];

    }
    else if(indexPath.row == 1)
    {
        [self performSegueWithIdentifier:@"SegueForTest" sender:[tableView cellForRowAtIndexPath:indexPath]];
    }
    else if(indexPath.row == 2)
    {
        [self performSegueWithIdentifier:@"SegueForTest" sender:[tableView cellForRowAtIndexPath:indexPath]];
    }
}

#pragma mark -
#pragma mark instance methods

- (HRMDataObject *) theAppDataObject;
{
    id<AppDelegateProtocol> theDelegate = (id<AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    HRMDataObject *theDataObject;
    theDataObject = (HRMDataObject*) theDelegate.theAppDataObject;
    return theDataObject;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
