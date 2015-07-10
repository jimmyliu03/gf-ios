//
//  SelectGymViewController.m
//  GymFlow
//
//  Created by Jiangyang Zhang on 12/18/12.
//  Copyright (c) 2012 Jiangyang Zhang. All rights reserved.
//

#import "SelectGymViewController.h"
#import "AppDelegate.h"
#import "GymFlowStore.h"
#import "SubmitOtherGymViewController.h"

@implementation SelectGymViewController

@synthesize backButton;
@synthesize selectGymTable;

- (IBAction) backButtonPressed: (id)sender {
    [self dismissModalViewControllerAnimated: YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"gymSelected"]) {
        [backButton removeFromSuperview];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[GymFlowStore sharedStore] gymList] count] + 1;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    
    UITableViewCell *cell;
    if (row < [[[GymFlowStore sharedStore] gymList] count]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"selectGymCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"selectGymCell"];
        }
        UIImageView *gymMainPic = (UIImageView *)[cell viewWithTag:1];
        UILabel *gymNameLabel = (UILabel *)[cell viewWithTag:2];
        UILabel *addressLabel1 = (UILabel *)[cell viewWithTag:3];
        UILabel *addressLabel2 = (UILabel *)[cell viewWithTag:4];
        id gym_obj = [[[GymFlowStore sharedStore] gymList] objectAtIndex:row];
        [gymMainPic setImage: [UIImage imageNamed: [gym_obj objectForKey:@"img_name"]]];
        gymNameLabel.text = [gym_obj objectForKey:@"gym_name"];
        addressLabel1.text = [gym_obj objectForKey:@"address1"];
        addressLabel2.text = [gym_obj objectForKey:@"address2"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"selectOtherGymCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"selectOtherGymCell"];
        }
    }
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar2"]];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    
    if (row < [[[GymFlowStore sharedStore] gymList] count]) {
        id gym_obj = [[[GymFlowStore sharedStore] gymList] objectAtIndex:row];
        if ([[GymFlowStore sharedStore] currentGymIndex] == [[gym_obj objectForKey: @"gym_id"] integerValue])
        {
            [self dismissViewControllerAnimated:YES completion:NULL];
            return;
        } else {
            [self gymSelected: [[gym_obj objectForKey: @"gym_id"] integerValue]];
        }
    } else {
        [self selectOtherGyms];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}


- (void) selectOtherGyms
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    SubmitOtherGymViewController *submitOtherGymController = (SubmitOtherGymViewController *) [delegate.mainStoryboard instantiateViewControllerWithIdentifier:@"other_gym"];
    [submitOtherGymController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:submitOtherGymController animated:YES completion:NULL];
}

- (void) gymSelected: (NSInteger) gym_id
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate initHUD];
    
       // If the gym has been selected before.
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"gymSelected"]) {
        [[GymFlowStore sharedStore] setCurrentGymIndex: gym_id];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSettings" object:nil];
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else
    {  // If not, show tool tips.
        [[GymFlowStore sharedStore] setCurrentGymIndex: gym_id];
        [delegate removeSelectGymView];
        [delegate showToolTipView];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"gymSelected"];
    }
    [delegate loadInitialData];
}

@end
