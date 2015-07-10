//
//  ClassDetailViewController.m
//  GymFlow
//
//  Created by Jiangyang Zhang on 12/9/12.
//  Copyright (c) 2012 Jiangyang Zhang. All rights reserved.
//

#import "ClassDetailViewController.h"

@implementation ClassDetailViewController

@synthesize classImage;
@synthesize nameLabel;
@synthesize dateLabel;
@synthesize roomLabel;
@synthesize timeLabel;
@synthesize desciptText;
@synthesize curClass;
@synthesize dateString;


- (IBAction)backButtonPressed:(id)sender {
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    nameLabel.text = curClass.className;
    roomLabel.text = [NSString stringWithFormat:@"%@", curClass.classRoom];
    desciptText.text = curClass.description;
    
    
    NSDate* startDate = [[NSCalendar currentCalendar] dateFromComponents:curClass.startTime];
    NSDate* endDate = [[NSCalendar currentCalendar] dateFromComponents:curClass.endTime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    
    timeLabel.text = [NSString stringWithFormat:@"%@ - %@",
                      [dateFormatter stringFromDate:startDate], [dateFormatter stringFromDate:endDate]];
    dateLabel.text = dateString;
    
    [classImage setImage:[UIImage imageNamed: curClass.imageName]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
