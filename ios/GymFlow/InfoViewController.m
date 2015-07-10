//
//  InfoViewController.m
//  GymFlow
//
//  Created by Jiangyang Zhang on 11/15/12.
//  Copyright (c) 2012 Jiangyang Zhang. All rights reserved.
//

#import "InfoViewController.h"
#import "FacilityDetailViewController.h"
#import "AppDelegate.h"
#import "GymFlowStore.h"

#define kFacilityHourSectionNum   1
#define kMainGymInfoSectionNum    0

@implementation InfoViewController
@synthesize gymTableView;

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
    gymInfoDict = [[NSMutableDictionary alloc] init];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return [[[[GymFlowStore sharedStore] gymMainInfo] objectForKey:@"facility_num"] integerValue];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"";
    } else {
        return @"Facility Hours";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    [gymInfoDict setDictionary:[[GymFlowStore sharedStore] gymMainInfo]];
    
    if (section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"GymInfoCell"];
        
        UIImageView *gymMainPic = (UIImageView *)[cell viewWithTag:1];
        UILabel *cellLabel = (UILabel *)[cell viewWithTag:2];
        UILabel *addressLabel1 = (UILabel *)[cell viewWithTag:3];
        UILabel *addressLabel2 = (UILabel *)[cell viewWithTag:4];
        UILabel *phoneLabel = (UILabel *)[cell viewWithTag:5];
        
        [gymMainPic setImage:[UIImage imageNamed:[gymInfoDict objectForKey:@"profile_img"]]];
        cellLabel.text = [gymInfoDict objectForKey:@"name"];
        addressLabel1.text = [gymInfoDict objectForKey:@"address1"];
        addressLabel2.text = [gymInfoDict objectForKey:@"address2"];
        phoneLabel.text = [NSString stringWithFormat:@"(p) %@", [gymInfoDict objectForKey:@"phone"]];
        
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar2"]];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"GymFacilityCell"];
        UIImageView *facilityPic = (UIImageView *)[cell viewWithTag:1];
        UILabel *facilityNameLabel = (UILabel *)[cell viewWithTag:2];
        UILabel *todayHourLabel = (UILabel *)[cell viewWithTag:3];
        UILabel *openNowLabel = (UILabel *)[cell viewWithTag:4];
        
        // this code is so ugly.....
        NSMutableArray *facilities = [[NSMutableArray alloc] init];
        id curFacility = nil;
        for (curFacility in [[GymFlowStore sharedStore] facilityHour]) {
            if ([[curFacility objectForKey:@"facility_id"] integerValue] == row+1) {
                [facilities addObject:curFacility];
            }
        }
        
        id facility = nil;
        if ([facilities count] > 0) {
            facility = [facilities objectAtIndex:0];
        }
        ////////////////////////////////////////////////
        
        [facilityPic setImage:[UIImage imageNamed:
                               [[GymFlowStore sharedStore] getFacilityImgNameWithID:
                                [facility objectForKey: @"facility_id"]]]];
        
        facilityNameLabel.text = [facility objectForKey:@"facility_name"];
        if ([[facility objectForKey:@"is_open"] isEqualToString:@"0"]) {
            todayHourLabel.text = @"Closed";
            openNowLabel.text = @"Closed Now";
            openNowLabel.textColor = [UIColor redColor];
        } else {
            NSDateComponents *openTime = [[NSDateComponents alloc] init];
            NSDateComponents *closeTime = [[NSDateComponents alloc] init];
            NSDateComponents *openTime2 = [[NSDateComponents alloc] init];
            NSDateComponents *closeTime2 = [[NSDateComponents alloc] init];
            
            NSString *openString = [facility objectForKey: @"t_open"];
            NSString *closeString = [facility objectForKey: @"t_close"];
            [openTime setHour:[[openString substringWithRange:NSMakeRange(0, 2)] integerValue]];
            [openTime setMinute:[[openString substringWithRange:NSMakeRange(3, 2)] integerValue]];
            [closeTime setHour:[[closeString substringWithRange:NSMakeRange(0, 2)] integerValue]];
            [closeTime setMinute:[[closeString substringWithRange:NSMakeRange(3, 2)] integerValue]];
            NSDate* openDate = [[NSCalendar currentCalendar] dateFromComponents: openTime];
            NSDate* closeDate = [[NSCalendar currentCalendar] dateFromComponents:closeTime];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"hh:mm a"];
            
            if ([facilities count] > 1) {
                id facility2 = [facilities objectAtIndex:1];
                NSString *openString2 = [facility2 objectForKey: @"t_open"];
                NSString *closeString2 = [facility2 objectForKey: @"t_close"];
                [openTime2 setHour:[[openString2 substringWithRange:NSMakeRange(0, 2)] integerValue]];
                [openTime2 setMinute:[[openString2 substringWithRange:NSMakeRange(3, 2)] integerValue]];
                [closeTime2 setHour:[[closeString2 substringWithRange:NSMakeRange(0, 2)] integerValue]];
                [closeTime2 setMinute:[[closeString2 substringWithRange:NSMakeRange(3, 2)] integerValue]];
                NSDate* openDate2 = [[NSCalendar currentCalendar] dateFromComponents: openTime2];
                NSDate* closeDate2 = [[NSCalendar currentCalendar] dateFromComponents: closeTime2];
                todayHourLabel.text = [NSString stringWithFormat:@"%@ - %@, %@ - %@",
                                       [dateFormatter stringFromDate:openDate], [dateFormatter stringFromDate:closeDate], [dateFormatter stringFromDate:openDate2], [dateFormatter stringFromDate:closeDate2]];
            } else {
                todayHourLabel.text = [NSString stringWithFormat:@"%@ - %@",
                                       [dateFormatter stringFromDate:openDate], [dateFormatter stringFromDate:closeDate]];
            }
            
            NSDateComponents *curTime = [[NSCalendar currentCalendar]
                                                    components:(NSHourCalendarUnit| NSMinuteCalendarUnit | NSWeekdayCalendarUnit)
                                                    fromDate: [NSDate date]];
            
            BOOL openCheck = false;
            BOOL closeCheck = false;
        
            if ([curTime hour] > [openTime hour]) {
                openCheck = true;
            } else if (([curTime hour] == [openTime hour]) && ([curTime minute] > [openTime minute])) {
                openCheck = true;
            } else {
                openCheck = false;
            }
            
            if ([curTime hour] < [closeTime hour]) {
                closeCheck = true;
            } else if (([curTime hour] == [closeTime hour]) && ([curTime minute] < [closeTime minute])) {
                closeCheck = true;
            } else {
                closeCheck = false;
            }
            
            if ([facilities count] > 1) {
                BOOL openCheck2 = false;
                BOOL closeCheck2 = false;
                if ([curTime hour] > [openTime2 hour])
                    openCheck2 = true;
                else if (([curTime hour] == [openTime2 hour]) && ([curTime minute] > [openTime2 minute])) {
                    openCheck2 = true;
                } else {
                    openCheck2 = false;
                }
                
                if ([curTime hour] < [closeTime2 hour])
                    closeCheck2 = true;
                else if (([curTime hour] == [closeTime2 hour]) && ([curTime minute] < [closeTime2 minute]))
                    closeCheck2 = true;
                else
                    closeCheck2 = false;
                
                if ((openCheck && closeCheck) || (openCheck2 && closeCheck2)) {
                    openNowLabel.text = @"Open Now";
                    openNowLabel.textColor = [UIColor colorWithRed:0.00 green:0.70 blue:0.00 alpha:1.00];
                } else {
                    openNowLabel.text = @"Closed Now";
                    openNowLabel.textColor = [UIColor colorWithRed:1.00 green:0.00 blue:0.00 alpha:1.00];
                }
            } else {
                if (openCheck && closeCheck) {
                    openNowLabel.text = @"Open Now";
                    openNowLabel.textColor = [UIColor colorWithRed:0.00 green:0.70 blue:0.00 alpha:1.00];
                } else {
                    openNowLabel.text = @"Closed Now";
                    openNowLabel.textColor = [UIColor colorWithRed:1.00 green:0.00 blue:0.00 alpha:1.00];
                }
            }
        }
        cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar2"]];
        return cell;
    }
}
  
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == kFacilityHourSectionNum) {
        NSMutableArray *facilityInfo = [[NSMutableArray alloc] init];
        id curFacility = nil;
        for (curFacility in [[GymFlowStore sharedStore] normalHours]) {
            if ([[curFacility objectForKey:@"facility_id"] integerValue] == row+1) {
                [facilityInfo addObject:curFacility];
            }
        }
        FacilityDetailViewController *facilityDetailController = (FacilityDetailViewController *) [delegate.mainStoryboard instantiateViewControllerWithIdentifier:@"facility_info"];
        [facilityDetailController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        
        facilityDetailController.curFacilityInfo = [[NSArray alloc] initWithArray: facilityInfo];
        [self presentViewController:facilityDetailController animated:YES completion:NULL];
        facilityDetailController.hoursNameLabel.text = [[GymFlowStore sharedStore] normalHoursName];
        
        NSString *facilityNameString = [[GymFlowStore sharedStore] getFacilityImgNameWithID:
                                        [NSString stringWithFormat:@"%d", row+1]];
        [facilityDetailController.facilityImage setImage:[UIImage imageNamed: facilityNameString]];
        
        facilityDetailController.facilityNameLabel.text = [[GymFlowStore sharedStore] getFacilityNameWithID:
                                                           [NSString stringWithFormat:@"%d", row+1]];
    }
    else if (section == kMainGymInfoSectionNum) {
        
        [[[UIAlertView alloc] initWithTitle: [NSString stringWithFormat:@"Call %@?",
                                              [[[GymFlowStore sharedStore] gymMainInfo] objectForKey: @"phone"]]
                                    message:@""
                                   delegate:self
                          cancelButtonTitle:@"Yes"
                          otherButtonTitles:@"No", nil] show];
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Yes"]) {
        NSString *phoneString = [[[GymFlowStore sharedStore] gymMainInfo] objectForKey: @"phone"];
        NSString *callURLString = [NSString stringWithFormat: @"tel:%@",
                                   [phoneString stringByReplacingOccurrencesOfString:@"." withString:@""]];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: callURLString]];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    if (section == 0)
        return 100;
    else
        return 60;
}


@end
