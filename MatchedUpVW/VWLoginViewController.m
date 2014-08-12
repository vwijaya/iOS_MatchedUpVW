//
//  VWLoginViewController.m
//  MatchedUpVW
//
//  Created by Valerino on 7/22/14.
//  Copyright (c) 2014 VW. All rights reserved.
//

#import "VWLoginViewController.h"

@interface VWLoginViewController ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSMutableData *imageData;

@end

@implementation VWLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.activityIndicator.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    if([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self updateUserInformation];
        [self performSegueWithIdentifier:@"loginToTabBarSegue" sender:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)loginButtonPressed:(UIButton *)sender {
    
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    NSArray *permissionArray = @[@"user_about_me",
                                 @"user_interests",
                                 @"user_relationships",
                                 @"user_birthday",
                                 @"user_location",
                                 @"user_relationship_details"];
    
    [PFFacebookUtils logInWithPermissions:permissionArray block:^(PFUser *user, NSError *error){
        
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
        
        if(!user) {
            if(!error) {
                UIAlertView *alertView = [[UIAlertView alloc]
                    initWithTitle:@"Log In Error"
                    message:@"The Facebook login was cancelled"
                    delegate:nil
                    cancelButtonTitle:@"OK"
                    otherButtonTitles:nil];
                [alertView show];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"Log In Error"
                                          message:[error description]
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                [alertView show];
            }
        } else {
            [self updateUserInformation];
            [self performSegueWithIdentifier:@"loginToTabBarSegue" sender:self];
        }
    }];
    
}

#pragma mark - Helpers
-(void) updateUserInformation
{
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error ) {
        if(!error){
            
            NSDictionary *userDictionary = (NSDictionary *)result;
            
            // create URL
            NSString *facebookID = userDictionary[@"id"];
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:
                                                      @"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]
                                 ];
            
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:8];
            
            if(userDictionary[kVWUserProfileNameKey])
                userProfile[kVWUserProfileNameKey] = userDictionary[kVWUserProfileNameKey];
            if(userDictionary[kVWUserProfileFirstNameKey])
                userProfile[kVWUserProfileFirstNameKey] = userDictionary[kVWUserProfileFirstNameKey];
            if(userDictionary[kVWUserProfileLocationKey][kVWUserProfileNameKey])
                userProfile[kVWUserProfileLocationKey] = userDictionary[kVWUserProfileLocationKey][kVWUserProfileNameKey];
            if(userDictionary[kVWUserProfileGenderKey])
                userProfile[kVWUserProfileGenderKey] = userDictionary[kVWUserProfileGenderKey];
            if(userDictionary[kVWUserProfileBirthdayKey])
                userProfile[kVWUserProfileBirthdayKey] = userDictionary[kVWUserProfileBirthdayKey];
            if(userDictionary[kVWUserProfileInterestedInKey])
                userProfile[kVWUserProfileInterestedInKey] = userDictionary[kVWUserProfileInterestedInKey];
            if([pictureURL absoluteString])
                userProfile[kVWUserProfilePictureURL] = [pictureURL absoluteString];
                
            [[PFUser currentUser] setObject:userProfile forKey:kVWUserProfileKey];
            [[PFUser currentUser] saveInBackground];
            
            [self requestImage];
        } else {
            
            NSLog(@"Error in FB request %@", error);
        }
    }];
}

-(void) uploadPFFileToParse:(UIImage *)image
{
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    
    if(!imageData) {
        NSLog(@"Image data was not found");
        return;
    }
    
    PFFile *photoFile = [PFFile fileWithData:imageData];
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if(succeeded){
             PFObject *photo = [PFObject objectWithClassName:kVWPhotoClassKey];
             [photo setObject:[PFUser currentUser] forKey:kVWPhotoUserKey];
             [photo setObject:photoFile forKey:kVWPhotoPictureKey];
             [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
              {
                  NSLog(@"Successfully retrieving user photo");
              }];
         } else {
             NSLog(@"Something wrong");
         }
     }];
}

-(void) requestImage
{
    PFQuery *query = [PFQuery queryWithClassName:kVWPhotoClassKey];
    [query whereKey:kVWPhotoUserKey equalTo:[PFUser currentUser]];
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error)
     {
         if(number == 0) {
             PFUser *user = [PFUser currentUser];
             self.imageData = [[NSMutableData alloc] init];
             NSURL *profilePictureURL = [NSURL URLWithString:
                                         user[kVWUserProfileKey][kVWUserProfilePictureURL]];
             NSURLRequest *urlRequest = [NSURLRequest requestWithURL:
                                         profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
             NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
             
             if(!urlConnection) {
                 NSLog(@"Failed to establish URL connection");
             }
         }
     }];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.imageData appendData:data];
}

-(void) connectionDidFinishLoading:(NSURLConnection *) connection
{
    UIImage *profileImage = [UIImage imageWithData:self.imageData];
    [self uploadPFFileToParse:profileImage];
}

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
