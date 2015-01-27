//
//  FBDemoViewController.m
//  MyHRM
//
//  Created by 黃銘隆 on 2015/1/27.
//  Copyright (c) 2015年 merry. All rights reserved.
//

#import "FBDemoViewController.h"

@interface FBDemoViewController ()

@end

@implementation FBDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self toggleHiddenState:YES];
    self.lblLoginStatus.text = @"";
    //self.loginButton.readPermissions = @[@"public_profile", @"email"];
    self.loginButton.delegate = self;
    
    [self.loginButton setReadPermissions:@[@"public_profile" , @"user_friends" , @"email"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)toggleHiddenState:(BOOL)shouldHide{
    self.lblUsername.hidden = shouldHide;
    self.lblEmail.hidden = shouldHide;
    self.profilePicture.hidden = shouldHide;
}

- (IBAction)ShareOGStory:(id)sender {
    // Check for publish permissions
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  // Walk the list of permissions looking to see if publish_actions has been granted
                                  NSArray *permissions = (NSArray *)[result data];
                                  BOOL publishActionsSet = FALSE;
                                  for (NSDictionary *perm in permissions) {
                                      if ([[perm objectForKey:@"permission"] isEqualToString:@"publish_actions"] &&
                                          [[perm objectForKey:@"status"] isEqualToString:@"granted"]) {
                                          publishActionsSet = TRUE;
                                          NSLog(@"publish_actions granted.");
                                          break;
                                      }
                                  }
                                  if (!publishActionsSet){
                                      // Permission hasn't been granted, so ask for publish_actions
                                      NSLog(@"publish_actions not granted.");
                                      [FBSession.activeSession requestNewPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                                                            defaultAudience:FBSessionDefaultAudienceFriends
                                                                          completionHandler:^(FBSession *session, NSError *error) {
                                                                              if (!error) {
                                                                                  if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound){
                                                                                      // Permission not granted, tell the user we will not share to Facebook
                                                                                      NSLog(@"Permission not granted, we will not share to Facebook.");
                                                                                      
                                                                                  } else {
                                                                                      // Permission granted, publish the OG story
                                                                                      [self pickImageAndPublishStory];
                                                                                  }
                                                                                  
                                                                              } else {
                                                                                  // An error occurred, we need to handle the error
                                                                                  // See: https://developers.facebook.com/docs/ios/errors
                                                                                  NSLog(@"Encountered an error requesting permissions: %@", error.description);
                                                                              }
                                                                          }];
                                      
                                  } else {
                                      // Permissions present, publish the OG story
                                      [self pickImageAndPublishStory];
                                  }
                                  
                              } else {
                                  // An error occurred, we need to handle the error
                                  // See: https://developers.facebook.com/docs/ios/errors
                                  NSLog(@"Encountered an error checking permissions: %@", error.description);
                              }
                          }];
}

- (void)pickImageAndPublishStory
{
    // Retrieve a picture from the device's photo library
    /*
     NOTE: SDK Image size limits are 480x480px minimum resolution to 12MB maximum file size.
     In this app we're not making sure that our image is within those limits but you should.
     Error code for images that go below or above the size limits is 102.
     */
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePicker setDelegate:self];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

// When the user is done picking the image
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // Dismiss the image picker off the screen
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // stage an image
    [FBRequestConnection startForUploadStagingResourceWithImage:image completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(!error) {
            NSLog(@"Successfuly staged image with staged URI: %@", [result objectForKey:@"uri"]);
            
            // instantiate a Facebook Open Graph object
            NSMutableDictionary<FBOpenGraphObject> *object = [FBGraphObject openGraphObjectForPost];
            
            // specify that this Open Graph object will be posted to Facebook
            object.provisionedForPost = YES;
            
            // for og:title
            object[@"title"] = @"HRM history";
            
            // for og:type, this corresponds to the Namespace you've set for your app and the object type name
            //object[@"type"] = @"myhrmapp:Activity";
            object[@"type"] = @"myhrmapp:Activity";
            
            // for og:description
            object[@"description"] = @"Strengthen the heart and lung function";
            
            // for og:url, we cover how this is used in the "Deep Linking" section below
            object[@"url"] = @"http://example.com/roasted_pumpkin_seeds";
            
            // for og:image we assign the uri of the image that we just staged
            object[@"image"] = @[@{@"url": [result objectForKey:@"uri"], @"user_generated" : @"false" }];
            
            // Post custom object
            [FBRequestConnection startForPostOpenGraphObject:object completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if(!error) {
                    // get the object ID for the Open Graph object that is now stored in the Object API
                    NSString *objectId = [result objectForKey:@"id"];
                    NSLog(@"object id: %@", objectId);
                    
                    // create an Open Graph action
                    id<FBOpenGraphAction> action = (id<FBOpenGraphAction>)[FBGraphObject graphObject];
                    [action setObject:objectId forKey:@"activity"];
                    
                    
                    // create action referencing user owned object
                    [FBRequestConnection startForPostWithGraphPath:@"/me/myhrmapp:start" graphObject:action completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                        if(!error) {
                            NSLog(@"OG story posted, story id: %@", [result objectForKey:@"id"]);
                            [[[UIAlertView alloc] initWithTitle:@"OG story posted"
                                                        message:@"Check your Facebook profile or activity log to see the story."
                                                       delegate:self
                                              cancelButtonTitle:@"OK!"
                                              otherButtonTitles:nil] show];
                        } else {
                            // An error occurred, we need to handle the error
                            // See: https://developers.facebook.com/docs/ios/errors
                            NSLog(@"Encountered an error posting to Open Graph: %@", error.description);
                        }
                    }];
                    
                } else {
                    // An error occurred, we need to handle the error
                    // See: https://developers.facebook.com/docs/ios/errors
                    NSLog(@"Encountered an error posting to Open Graph: %@", error.description);
                }
            }];
            
        } else {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
            NSLog(@"Error staging an image: %@", error.description);
        }
    }];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - FBLoginView

-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user{
    NSLog(@"%@", user);
    self.profilePicture.profileID = user.id;
    self.lblUsername.text = user.name;
    self.lblEmail.text = [user objectForKey:@"email"];
}

-(void)loginViewShowingLoggedInUser:(FBLoginView *)loginView{
    self.lblLoginStatus.text = @"You are logged in.";
    
    [self toggleHiddenState:NO];
}

-(void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView{
    self.lblLoginStatus.text = @"You are logged out";
    
    [self toggleHiddenState:YES];
}

-(void)loginView:(FBLoginView *)loginView handleError:(NSError *)error{
    NSLog(@"%@", [error localizedDescription]);
}

@end
