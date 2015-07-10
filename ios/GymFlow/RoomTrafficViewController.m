//
//  RoomTrafficViewController.m
//  GymFlow
//
//  Created by Jiangyang Zhang on 9/8/13.
//  Copyright (c) 2013 Jiangyang Zhang. All rights reserved.
//

#import "RoomTrafficViewController.h"
#import "GymFlowStore.h"

@interface RoomTrafficViewController ()

@end

@implementation RoomTrafficViewController

@synthesize roomTrafficTableView;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark -
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[GymFlowStore sharedStore] roomTrafficInfo] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier: @"RoomTrafficCell"];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar2"]];
    
    UIImageView *roomImage = (UIImageView *)[cell viewWithTag:1];
    UILabel *roomNameLabel = (UILabel *)[cell viewWithTag:2];
    UILabel *trafficLevelLabel = (UILabel *)[cell viewWithTag:3];
    UILabel *lastUpdateLabel = (UILabel *)[cell viewWithTag:4];
    UILabel *trafficNumLabel = (UILabel *)[cell viewWithTag:5];
    
    id roomInfo = [[[GymFlowStore sharedStore] roomTrafficInfo] objectAtIndex:row];
    
    [roomImage setImage:[UIImage imageNamed: [roomInfo objectForKey:@"room_img_name"]]];
    roomNameLabel.text = [roomInfo objectForKey:@"room_name"];
    lastUpdateLabel.text = [NSString stringWithFormat:@"Today %@", [roomInfo objectForKey:@"last_update"]];
    trafficNumLabel.text =  [NSString stringWithFormat:@"%@ users", [roomInfo objectForKey:@"traffic_num"]];
    
    NSInteger curTraffic = [[roomInfo objectForKey:@"traffic_num"] integerValue];
    NSInteger crowdedThre = [[roomInfo objectForKey:@"thre_crowded"] integerValue];
    NSInteger moderateThre = [[roomInfo objectForKey:@"thre_moderate"] integerValue];
    NSInteger slightThre = [[roomInfo objectForKey:@"thre_slight"] integerValue];
    
    if (curTraffic > crowdedThre) {
        trafficLevelLabel.text = @"Crowded";
        trafficLevelLabel.textColor = [UIColor redColor];
    } else if (curTraffic > moderateThre) {
        trafficLevelLabel.text = @"Moderate";
        trafficLevelLabel.textColor = [UIColor orangeColor];
    } else if (curTraffic > slightThre) {
        trafficLevelLabel.text = @"Slight";
        trafficLevelLabel.textColor = [UIColor blueColor];
    } else {
        trafficLevelLabel.text = @"Empty";
        trafficLevelLabel.textColor = [UIColor greenColor];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}



@end
