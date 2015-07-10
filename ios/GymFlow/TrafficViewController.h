//
//  TrafficViewController.h
//  GymFlow
//
//  Created by Jiangyang Zhang on 11/15/12.
//  Copyright (c) 2012 Jiangyang Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#define kNumDaySegments              7
#define kScrollViewSideOffset      160
#define kTrafficBarWidth            10
#define kTrafficBarSpace             3
#define kTrafficBarOffset           13
#define kScrollViewHeight_IPhone4  250
#define kScrollViewHeight_IPhone5  330
#define kCentralBarWidth            20
#define kScrollViewYOffset         140   //125
#define kMaxBarHeight_IPhone4      205
#define kMaxBarHeight_IPhone5      290

@interface TrafficViewController : UIViewController
<UIScrollViewDelegate>

@property (nonatomic, retain) NSArray                   *dayName;
@property (nonatomic, retain) UIScrollView              *trafficScrollView;
@property (nonatomic, retain) UIImageView               *centralBarView;

@property (nonatomic, retain) IBOutlet UILabel          *dateLabel;
@property (nonatomic, retain) IBOutlet UILabel          *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel          *trafficLevelLabel;
@property (nonatomic, retain) IBOutlet UILabel          *trafficTypeLabel;

@property (nonatomic, retain) IBOutlet UIButton         *liveButton;
@property (nonatomic, retain) IBOutlet UIImageView      *bubbleView;
@property (nonatomic, retain) IBOutlet UILabel          *fullnessLabel;
@property (nonatomic, retain) IBOutlet UILabel          *userNumLabel;
@property (nonatomic, retain) IBOutlet UIButton         *roomTrafficButton;

@property (nonatomic, retain) IBOutlet UIButton         *prevDayButton;
@property (nonatomic, retain) IBOutlet UIButton         *nextDayButton;

@property (nonatomic, retain) NSDate                    *selectedDate;
@property (nonatomic, retain) NSDateFormatter           *timeFormat;
@property (nonatomic, retain) NSDateFormatter           *dateFormat;
@property (nonatomic, retain) NSDateFormatter           *dateFormat2;

@property NSInteger                                     selectedDayIndex;
@property NSInteger                                     currentTimeIndex;
@property NSInteger                                     selectedTimeIndex;
@property NSInteger                                     initialTimeIndex;
@property NSInteger                                     lastTimeIndex;
@property NSInteger                                     numTimePeriods;
@property BOOL                                          buttonSwitchOn;

@property (nonatomic, retain) AppDelegate               *delegate;

- (IBAction) getLiveTraffic: (id) sender;
- (NSString *) getTimeStringForTimeIndex: (NSInteger) index;
- (void) updateTrafficScroll;
- (void) scrollViewToCurrentTime;
- (void) updateAndScrollToCurrenttraffic;
- (void) updateTrafficLabels;
- (void) updateTimeIndexAndPeriod;
- (void) updateForNewDay;
- (void) appDelegateDataReloaded;
- (void) initTrafficScrollView;
- (void) updateRoomTrafficButton;

- (IBAction)nextDay:(id)sender;
- (IBAction)prevDay:(id)sender;
- (IBAction)switchToRoomTraffic:(id)sender;

@end
