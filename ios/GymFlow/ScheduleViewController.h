//
//  ScheduleViewController.h
//  GymFlow
//
//  Created by Jiangyang Zhang on 11/15/12.
//  Copyright (c) 2012 Jiangyang Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ScheduleViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *scheduleTableView;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UIButton *prevDayButton;
@property (nonatomic, retain) IBOutlet UIButton *nextDayButton;

@property (nonatomic, retain) NSMutableArray *morningClasses;
@property (nonatomic, retain) NSMutableArray *afternoonClasses;
@property (nonatomic, retain) NSMutableArray *eveningClasses;
@property (nonatomic, retain) NSArray *dayName;

@property (nonatomic) NSInteger curDayIndex;
@property (nonatomic, retain) NSDate *curDate;
@property (nonatomic, retain) AppDelegate *delegate;
@property (nonatomic) BOOL classExist;

@property (nonatomic, retain) NSDateFormatter *dateFormat;
@property (nonatomic, retain) NSDateFormatter *dateFormat2;
 
- (IBAction) nextDay:(id)sender;
- (IBAction) prevDay:(id)sender;
- (IBAction) goToToday: (id) sender;
- (void) refreshResult;

@end
