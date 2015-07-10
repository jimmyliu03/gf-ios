//
//  FacilityDetailViewController.m
//  GymFlow
//
//  Created by Jiangyang Zhang on 12/18/12.
//  Copyright (c) 2012 Jiangyang Zhang. All rights reserved.
//

#import "FacilityDetailViewController.h"
#import "GymFlowStore.h"

@implementation FacilityDetailViewController

@synthesize facilityImage;
@synthesize monHourLabel;
@synthesize tueHourLabel;
@synthesize wedHourLabel;
@synthesize thuHourLabel;
@synthesize friHourLabel;
@synthesize satHourLabel;
@synthesize sunHourLabel;
@synthesize facilityNameLabel;
@synthesize hoursNameLabel;
@synthesize curFacilityInfo;
@synthesize facilityImgNameString;
@synthesize facilityNameString;

- (IBAction) backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSDate *) convertToDate: (NSString *) timeString {
     NSDateComponents *dateComponent = [[NSDateComponents alloc] init];
    [dateComponent setHour:[[timeString substringWithRange:NSMakeRange(0, 2)] integerValue]];
    [dateComponent setMinute:[[timeString substringWithRange:NSMakeRange(3, 2)] integerValue]];
   
    NSDate* date = [[NSCalendar currentCalendar] dateFromComponents: dateComponent];
    return date;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    
    id hours = nil;
    for (hours in curFacilityInfo) {
        NSDate *open_time = [self convertToDate:[hours objectForKey:@"t_open"]];
        NSDate *close_time = [self convertToDate:[hours objectForKey:@"t_close"]];
        
        if ([[hours objectForKey:@"week_day"] isEqualToString: @"Mon"]) {
            if ([monHourLabel.text isEqualToString:@"Closed"]) {
                monHourLabel.text = [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate: open_time], [dateFormatter stringFromDate:close_time]];
            } else {
                monHourLabel.text = [NSString stringWithFormat:@"%@, %@ - %@",  monHourLabel.text, [dateFormatter stringFromDate: open_time], [dateFormatter stringFromDate:close_time]];
            }
        } else if ([[hours objectForKey:@"week_day"] isEqualToString: @"Tue"]) {
            if ([tueHourLabel.text isEqualToString:@"Closed"]) {
                tueHourLabel.text = [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate: open_time], [dateFormatter stringFromDate:close_time]];
            } else {
                tueHourLabel.text = [NSString stringWithFormat:@"%@, %@ - %@",  tueHourLabel.text, [dateFormatter stringFromDate: open_time], [dateFormatter stringFromDate:close_time]];
            }
        } else if ([[hours objectForKey:@"week_day"] isEqualToString: @"Wed"]) {
            if ([wedHourLabel.text isEqualToString:@"Closed"]) {
                wedHourLabel.text = [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate: open_time], [dateFormatter stringFromDate:close_time]];
            } else {
                wedHourLabel.text = [NSString stringWithFormat:@"%@, %@ - %@",  wedHourLabel.text, [dateFormatter stringFromDate: open_time], [dateFormatter stringFromDate:close_time]];
            }
        } else if ([[hours objectForKey:@"week_day"] isEqualToString: @"Thu"]) {
            if ([thuHourLabel.text isEqualToString:@"Closed"]) {
                thuHourLabel.text = [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate: open_time], [dateFormatter stringFromDate:close_time]];
            } else {
                thuHourLabel.text = [NSString stringWithFormat:@"%@, %@ - %@",  thuHourLabel.text, [dateFormatter stringFromDate: open_time], [dateFormatter stringFromDate:close_time]];
            }
        } else if ([[hours objectForKey:@"week_day"] isEqualToString: @"Fri"]) {
            if ([friHourLabel.text isEqualToString:@"Closed"]) {
                friHourLabel.text = [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate: open_time], [dateFormatter stringFromDate:close_time]];
            } else {
                friHourLabel.text = [NSString stringWithFormat:@"%@, %@ - %@",  friHourLabel.text, [dateFormatter stringFromDate: open_time], [dateFormatter stringFromDate:close_time]];
            }
        } else if ([[hours objectForKey:@"week_day"] isEqualToString: @"Sat"]) {
            if ([satHourLabel.text isEqualToString:@"Closed"]) {
                satHourLabel.text = [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate: open_time], [dateFormatter stringFromDate:close_time]];
            } else {
                satHourLabel.text = [NSString stringWithFormat:@"%@, %@ - %@",  satHourLabel.text, [dateFormatter stringFromDate: open_time], [dateFormatter stringFromDate:close_time]];
            }
        } else if ([[hours objectForKey:@"week_day"] isEqualToString: @"Sun"]) {
            if ([sunHourLabel.text isEqualToString:@"Closed"]) {
                sunHourLabel.text = [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate: open_time], [dateFormatter stringFromDate:close_time]];
            } else {
                sunHourLabel.text = [NSString stringWithFormat:@"%@, %@ - %@",  sunHourLabel.text, [dateFormatter stringFromDate: open_time], [dateFormatter stringFromDate:close_time]];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
