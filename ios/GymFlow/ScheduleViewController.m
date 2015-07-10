//
//  ScheduleViewController.m
//  GymFlow
//
//  Created by Jiangyang Zhang on 11/15/12.
//  Copyright (c) 2012 Jiangyang Zhang. All rights reserved.
//

#import "ScheduleViewController.h"
#import "ClassDetailViewController.h"
#import "AppDelegate.h"
#import "GymFlowStore.h"
#import "GymClass.h"
#import "AFJSONRequestOperation.h"
#import "Flurry.h"

#define kUpdateClassURL   @"http://54.243.28.121/beta/server_call_2.1/load_gym_classes.php" 

@implementation ScheduleViewController
@synthesize dateLabel;
@synthesize scheduleTableView;
@synthesize morningClasses;
@synthesize afternoonClasses;
@synthesize eveningClasses;
@synthesize dayName;
@synthesize curDayIndex;
@synthesize dateFormat;
@synthesize dateFormat2;
@synthesize curDate;
@synthesize delegate;
@synthesize classExist;
@synthesize prevDayButton;
@synthesize nextDayButton;

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
    self.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 90)];
    footer.backgroundColor = [UIColor clearColor];
    scheduleTableView.tableFooterView = footer;
    
    self.dayName = [[NSArray alloc] initWithObjects: @"Sun", @"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat", nil];
    self.curDate = [NSDate date];
    
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar]
                                        components:(NSHourCalendarUnit| NSMinuteCalendarUnit | NSWeekdayCalendarUnit)
                                        fromDate: self.curDate];
    self.curDayIndex = [dateComponents weekday] - 1;
    
    self.dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"cccc, MMM d yyyy"];
    
    self.dateFormat2 = [[NSDateFormatter alloc] init];
    [dateFormat2 setDateFormat:@"yyyy-MM-dd"];
    
    dateLabel.text = @"Today";
    classExist = false;
    
    self.morningClasses = [[NSMutableArray alloc] init];
    self.afternoonClasses = [[NSMutableArray alloc] init];
    self.eveningClasses = [[NSMutableArray alloc] init];
    [self refreshResult];
    
}

- (void) refreshResult {
    [morningClasses removeAllObjects];
    [afternoonClasses removeAllObjects];
    [eveningClasses removeAllObjects];
    
    GymClass *gymClass = nil;
   
    for (gymClass in [[GymFlowStore sharedStore] curSchedule]) {
        if ([gymClass.weekday isEqualToString: [dayName objectAtIndex:curDayIndex]]) {
            if ([gymClass.startTime hour] < 12) {
                [morningClasses addObject:gymClass];
            } else if ([gymClass.startTime hour] < 18) {
                [afternoonClasses addObject:gymClass];
            } else {
                [eveningClasses addObject:gymClass];
            }
        }
    }
    
    if (([morningClasses count] > 0) || ([afternoonClasses count] > 0) || ([eveningClasses count] > 0)){
        classExist = true;
    } else {
        classExist = false;
    }
    [self.scheduleTableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextDay:(id)sender
{
    [delegate initHUD];
    [delegate.HUD show:YES];
    delegate.HUD.labelText = @"Loading classes ...";
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    self.curDate = [self.curDate dateByAddingTimeInterval: secondsPerDay];

    NSDateComponents *curDateComponents = [[NSCalendar currentCalendar]
                                           components:(NSMonthCalendarUnit | NSDayCalendarUnit)
                                           fromDate: self.curDate];
    NSDateComponents *todayDateComponents = [[NSCalendar currentCalendar]
                                             components:(NSMonthCalendarUnit | NSDayCalendarUnit)
                                             fromDate: [NSDate date]];
    
    [prevDayButton setEnabled: true];
    if (([curDateComponents year] == 2013) && ([curDateComponents month] == 5) &&
        ([curDateComponents day] == 31)) {
        [nextDayButton setEnabled: true];
    }

    if (([curDateComponents month] == [todayDateComponents month]) &&
        ([curDateComponents day] == [todayDateComponents day])) {
        dateLabel.text = @"Today";
    } else {
        dateLabel.text = [dateFormat stringFromDate:self.curDate];
    }

    curDayIndex++;
    if(curDayIndex > 6) {
        curDayIndex = 0;
    }
    [self getClassSchedule];
}

- (IBAction)prevDay:(id)sender {
    [delegate initHUD];
    [delegate.HUD show:YES];
    delegate.HUD.labelText = @"Loading classes ...";

    NSTimeInterval secondsPerDay = -1.0f * 24 * 60 * 60;
    self.curDate = [self.curDate dateByAddingTimeInterval: secondsPerDay];
    
    NSDateComponents *curDateComponents = [[NSCalendar currentCalendar]
                                           components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                           fromDate: self.curDate];
    NSDateComponents *todayDateComponents = [[NSCalendar currentCalendar]
                                           components:(NSMonthCalendarUnit | NSDayCalendarUnit)
                                           fromDate: [NSDate date]];
    
   [nextDayButton setEnabled: true];
    if (([curDateComponents year] == 2012) && ([curDateComponents month] == 12) &&
        ([curDateComponents day] == 19)) {
        [prevDayButton setEnabled: false];
    }
    
    if (([curDateComponents month] == [todayDateComponents month]) &&
        ([curDateComponents day] == [todayDateComponents day])) {
        dateLabel.text = @"Today";
    } else {
        dateLabel.text = [dateFormat stringFromDate:self.curDate];
    }

    curDayIndex--;
    if(curDayIndex < 0) {
        curDayIndex = 6;
    }
    [self getClassSchedule];
}


- (IBAction) goToToday: (id) sender {
    [delegate initHUD];
    [delegate.HUD show:YES];
    delegate.HUD.labelText = @"Loading classes ...";
    
    self.curDate = [NSDate date];
    [nextDayButton setEnabled: true];
    [prevDayButton setEnabled: true];
  
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar]
                                        components:(NSHourCalendarUnit| NSMinuteCalendarUnit | NSWeekdayCalendarUnit)
                                        fromDate: self.curDate];
    dateLabel.text = @"Today";
    self.curDayIndex = [dateComponents weekday] - 1;
    [self getClassSchedule];
}


#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (classExist) {
        return 3;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (classExist) {
        if (section == 0) {
            return [morningClasses count];
        } else if (section == 1) {
            return [afternoonClasses count];
        } else {
            return [eveningClasses count];
        }
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (classExist) {
        if (section == 0) {
            if ([morningClasses count] > 0)
                return @"Morning";
            else
                return @"";
        } else if (section == 1) {
            if ([afternoonClasses count] > 0)
                return @"Afternoon";
            else
                return @"";
        } else {
            if ([eveningClasses count] > 0)
                return @"Evening";
            else
                return @"";
        }
    } else {
        return @"";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    UITableViewCell *cell;
    if (classExist) {
        cell = [tableView dequeueReusableCellWithIdentifier: @"ClassInfoCell"];
        
        UIImageView *classImage = (UIImageView *)[cell viewWithTag:1];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:2];
        UILabel *roomLabel = (UILabel *)[cell viewWithTag:3];
        UILabel *timeLabel = (UILabel *)[cell viewWithTag:4];
        
        GymClass *curClass;
        if (section == 0) {
            curClass = [morningClasses objectAtIndex:row];
        } else if (section == 1) {
            curClass = [afternoonClasses objectAtIndex:row];
        } else {
            curClass = [eveningClasses objectAtIndex:row];
        }
        
        [classImage setImage:[UIImage imageNamed: curClass.imageName ]];
        nameLabel.text = curClass.className;
        roomLabel.text = [NSString stringWithFormat:@"%@", curClass.classRoom];
        NSDate* startDate = [[NSCalendar currentCalendar] dateFromComponents:curClass.startTime];
        NSDate* endDate = [[NSCalendar currentCalendar] dateFromComponents:curClass.endTime];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"hh:mm a"];
        
        timeLabel.text = [NSString stringWithFormat:@"%@ - %@",
                          [dateFormatter stringFromDate:startDate], [dateFormatter stringFromDate:endDate]];
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier: @"NoClassCell"];
    }
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar2"]];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (classExist) {
        ClassDetailViewController *classDetailController = (ClassDetailViewController *) [delegate.mainStoryboard instantiateViewControllerWithIdentifier:@"class_info"];
        [classDetailController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
        
        if (section == 0) {
            classDetailController.curClass = [morningClasses objectAtIndex:row];
        } else if (section == 1) {
            classDetailController.curClass = [afternoonClasses objectAtIndex:row];
        } else {
            classDetailController.curClass = [eveningClasses objectAtIndex:row];
        }
        classDetailController.dateString = [dateFormat stringFromDate:self.curDate];
        [self presentViewController:classDetailController animated:YES completion:NULL];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}



- (void) getClassSchedule {
    NSString *URLString = [NSString stringWithFormat: @"%@?date=%@&gym_id=%d",
                           kUpdateClassURL, [dateFormat2 stringFromDate: self.curDate],
                           [[GymFlowStore sharedStore] currentGymIndex]];
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString: URLString]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        [[GymFlowStore sharedStore] setTodayClassSchedule:[JSON valueForKeyPath:@"class_schedules"]];
        [self refreshResult];
        [delegate HUDShowCompletedAndDisappear];   
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self showAlertForErrorLoadingClasses];
    }];
    
    [operation start];
}


- (void) showAlertForErrorLoadingClasses {
    [[[UIAlertView alloc] initWithTitle: @"Error"
                                message: @"Failed to load classes."
                               delegate: self
                      cancelButtonTitle: @"OK"
                      otherButtonTitles: nil] show];
}

@end
