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
            [self performSegueWithIdentifier:@"loginToTabBarSegue" sender:self];
        }
    }];
    
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
