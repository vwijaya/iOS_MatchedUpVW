//
//  VWSecondViewController.m
//  MatchedUpVW
//
//  Created by Valerino on 7/22/14.
//  Copyright (c) 2014 VW. All rights reserved.
//

#import "VWSecondViewController.h"

@interface VWSecondViewController ()

@end

@implementation VWSecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    PFQuery *query = [PFQuery queryWithClassName:kVWPhotoClassKey];
    [query whereKey:kVWPhotoUserKey equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if([objects count] > 0) {
             PFObject *photo = objects[0];
             PFFile *pictureFile = photo[kVWPhotoPictureKey];
             [pictureFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
              {
                  self.profilePictureImageView.image = [UIImage imageWithData:data];
              }];
         }
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
