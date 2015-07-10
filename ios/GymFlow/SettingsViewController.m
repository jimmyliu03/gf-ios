//
//  SettingsViewController.m
//  GymFlow
//
//  Created by Jiangyang Zhang on 3/26/13.
//  Copyright (c) 2013 Jiangyang Zhang. All rights reserved.
//

#import "SettingsViewController.h"
#import "SelectGymViewController.h"
#import "LeaveFeedbackViewController.h"
#import "AppDelegate.h"
#import "GymFlowStore.h"

#define kMyGymSectionIndex          0
#define kOtherSettingsSectionIndex  1
#define kAboutUsRowIndex            0
#define kRateUsRowIndex             1
#define kLeaveFeedbackRowIndex      2


@implementation SettingsViewController

@synthesize settingsTableView;

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
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(refreshTableView)
                                                 name: @"updateSettings"
                                               object: nil];
	// Do any additional setup after loading the view.
}

- (void) refreshTableView
{
    [settingsTableView reloadData];
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
    if (section == kMyGymSectionIndex) {
        return 1;
    } else if (section == kOtherSettingsSectionIndex){
        return 3;
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    static NSString *MyGymTableCellIdentifier = @"setting_mygym_cell";
    static NSString *SettingsTableCellIdentifier = @"setting_other_cell";
    
    UITableViewCell *cell;
    if (section == kMyGymSectionIndex) {
        cell = [tableView dequeueReusableCellWithIdentifier:MyGymTableCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyGymTableCellIdentifier];
        }
        UILabel *detailTextLabel = (UILabel *)[cell viewWithTag:1];
        
        detailTextLabel.text = [[GymFlowStore sharedStore] currentGymName];
    }
    else if (section == kOtherSettingsSectionIndex) {
        cell = [tableView dequeueReusableCellWithIdentifier: SettingsTableCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SettingsTableCellIdentifier];
        }
        UILabel *titleTextLabel = (UILabel *)[cell viewWithTag:1];
        
        if (row == kAboutUsRowIndex) {
            titleTextLabel.text = @"About GymFlow";
        } else if (row == kLeaveFeedbackRowIndex) {
            titleTextLabel.text = @"Leave Feedback";
        } else if (row == kRateUsRowIndex){
            titleTextLabel.text = @"Rate us on AppStore";
        }
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (section == kMyGymSectionIndex) {
        SelectGymViewController *selectGymController = (SelectGymViewController *) [delegate.mainStoryboard instantiateViewControllerWithIdentifier:@"select_gym"];
        [self presentViewController:selectGymController animated:YES completion:NULL];
    } else if (section == kOtherSettingsSectionIndex) {
     
        if (row == kAboutUsRowIndex) {
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"http://www.mygymflow.com"]];
        } else if (row == kLeaveFeedbackRowIndex) {
            LeaveFeedbackViewController *feedbackController = (LeaveFeedbackViewController *) [delegate.mainStoryboard instantiateViewControllerWithIdentifier:@"leave_feedback"];
            [self presentViewController:feedbackController animated:YES completion:NULL];
        } else if (row == kRateUsRowIndex) {
            static NSString *const iOSAppStoreURLFormat=@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=590211921";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iOSAppStoreURLFormat]];
        }
    }
}


@end
