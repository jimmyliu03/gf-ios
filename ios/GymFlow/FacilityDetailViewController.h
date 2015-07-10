//
//  FacilityDetailViewController.h
//  GymFlow
//
//  Created by Jiangyang Zhang on 12/18/12.
//  Copyright (c) 2012 Jiangyang Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FacilityDetailViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIImageView *facilityImage;
@property (nonatomic, retain) IBOutlet UILabel *monHourLabel;
@property (nonatomic, retain) IBOutlet UILabel *tueHourLabel;
@property (nonatomic, retain) IBOutlet UILabel *wedHourLabel;
@property (nonatomic, retain) IBOutlet UILabel *thuHourLabel;
@property (nonatomic, retain) IBOutlet UILabel *friHourLabel;
@property (nonatomic, retain) IBOutlet UILabel *satHourLabel;
@property (nonatomic, retain) IBOutlet UILabel *sunHourLabel;
@property (nonatomic, retain) IBOutlet UILabel *facilityNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *hoursNameLabel;
@property (nonatomic, retain) NSArray *curFacilityInfo;
@property (nonatomic, retain) NSString *facilityNameString;
@property (nonatomic, retain) NSString *facilityImgNameString;

- (IBAction) backButtonPressed:(id)sender;

@end
