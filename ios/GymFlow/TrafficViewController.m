//
//  TrafficViewController.m
//  GymFlow
//
//  Created by Jiangyang Zhang on 11/15/12.
//  Copyright (c) 2012 Jiangyang Zhang. All rights reserved.
//

#import "TrafficViewController.h"
#import "RoomTrafficViewController.h"
#import "MBProgressHUD.h"
#import "GymFlowStore.h"

#define IS_WIDESCREEN (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)

#define IS_IPHONE ([[[UIDevice currentDevice]model] isEqualToString:@"iPhone"])
#define IS_IPOD   ([[[UIDevice currentDevice]model] isEqualToString:@"iPod touch"])
#define IS_IPHONE_5 (IS_IPHONE && IS_WIDESCREEN)

@implementation TrafficViewController

@synthesize trafficScrollView;
@synthesize centralBarView;
@synthesize selectedDate;

@synthesize selectedDayIndex;
@synthesize currentTimeIndex;
@synthesize selectedTimeIndex;
@synthesize timeFormat;
@synthesize dateFormat;
@synthesize dateFormat2;

@synthesize numTimePeriods;
@synthesize initialTimeIndex;
@synthesize lastTimeIndex;

@synthesize dateLabel;
@synthesize timeLabel;
@synthesize trafficLevelLabel;
@synthesize trafficTypeLabel;
@synthesize liveButton;
@synthesize roomTrafficButton;
@synthesize bubbleView;
@synthesize buttonSwitchOn;
@synthesize fullnessLabel;
@synthesize userNumLabel;

@synthesize prevDayButton;
@synthesize nextDayButton;
@synthesize delegate;


- (void) updateAndScrollToCurrenttraffic
{
    // Change the status of the "now" button.
    buttonSwitchOn = false;
    [liveButton setImage:[UIImage imageNamed:@"now_button"] forState:UIControlStateNormal];
    liveButton.alpha = 1.0;
    
    // Change the selectedDate as current date.
    selectedDate = [NSDate date];
    timeLabel.text = [timeFormat stringFromDate: selectedDate];
    
    // Change traffic labels.
    trafficTypeLabel.text = @"Current Traffic";
    selectedDayIndex = 0;
    [prevDayButton setEnabled:true];
    [nextDayButton setEnabled:true];
    dateLabel.text = @"Today";
    
    // Update current time index and selected time index.
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar]
                                        components:(NSHourCalendarUnit| NSMinuteCalendarUnit | NSWeekdayCalendarUnit)
                                        fromDate: selectedDate];
    
    currentTimeIndex = [dateComponents hour] * 4 + [dateComponents minute]/15;
    selectedTimeIndex = currentTimeIndex;
    
    // Update initial time index and last time index.
    [self updateTimeIndexAndPeriod];
    
    // Asks the delegate to update data from the server.
    [delegate updateData];
}

- (IBAction)switchToRoomTraffic:(id)sender
{
    RoomTrafficViewController *roomTrafficController = (RoomTrafficViewController *) [delegate.mainStoryboard instantiateViewControllerWithIdentifier:@"room_traffic"];
    [roomTrafficController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    
    [self presentViewController: roomTrafficController animated:YES completion:NULL];    
}



// Function called when the "now" button is pressed.
- (IBAction) getLiveTraffic: (id) sender
{
    [self updateAndScrollToCurrenttraffic];
    [bubbleView setImage:[UIImage imageNamed:@"greenbubble"]]; 
}


// Initializes the traffic scroll view
- (void) initTrafficScrollView
{
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar]
                                        components:(NSHourCalendarUnit| NSMinuteCalendarUnit | NSWeekdayCalendarUnit)
                                        fromDate: [NSDate date]];
    
    if ([trafficScrollView superview] == nil) {
      // Programatically set up the scroll view for traffic display.
      if(IS_IPHONE_5) {
          trafficScrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(0, kScrollViewYOffset, 320, kScrollViewHeight_IPhone5)];
      } else {
          trafficScrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(0, kScrollViewYOffset, 320, kScrollViewHeight_IPhone4)];
      }
    
      // Configure the traffic view.
      trafficScrollView.delegate = self;
      [self.view insertSubview: trafficScrollView belowSubview: bubbleView];
      [trafficScrollView setBackgroundColor:[UIColor clearColor]];
	  [trafficScrollView setCanCancelContentTouches:NO];
	  trafficScrollView.scrollEnabled = YES;
      trafficScrollView.showsHorizontalScrollIndicator = NO;
    }
    
    // Update the current and selected time index.
    currentTimeIndex = [dateComponents hour] * 4 + [dateComponents minute]/15;
    selectedTimeIndex = currentTimeIndex;
    
    // Update traffic scroll view.
    [self updateTrafficScroll];
}


// Change the content offset so that scroll view is adjusted to the current time.
- (void) scrollViewToCurrentTime
{
    // If current time is earlier than the gym opening time.
    if (currentTimeIndex < self.initialTimeIndex) {
        if (trafficScrollView.contentOffset.x == 0.0) {
            buttonSwitchOn = true;
        }
        // Set the content offset slightly on the left side of the left-most traffic bar.
        [trafficScrollView setContentOffset: CGPointMake(-10, 0) animated:YES];
    }
    // If current time is later than the gym closing time.
    else if (currentTimeIndex > lastTimeIndex) {
        [trafficScrollView setContentOffset: CGPointMake(kScrollViewSideOffset + kTrafficBarOffset * (lastTimeIndex - initialTimeIndex) + 10 - 160 + kTrafficBarWidth/2, 0) animated:YES];
    }
    else {
        // If the user clicks "now" button twice.
        if (trafficScrollView.contentOffset.x == kScrollViewSideOffset + kTrafficBarOffset * (currentTimeIndex - self.initialTimeIndex) - 160 + kTrafficBarWidth/2) {
            buttonSwitchOn = true;
        }
        [trafficScrollView setContentOffset: CGPointMake(kScrollViewSideOffset + kTrafficBarOffset * (currentTimeIndex - self.initialTimeIndex) - 160 + kTrafficBarWidth/2, 0) animated:YES];
    }
}

- (void) updateRoomTrafficButton
{
    if ([[GymFlowStore sharedStore] roomTraficAvailable]){
        roomTrafficButton.alpha = 1.0;
        roomTrafficButton.enabled = true;
    } else {
        roomTrafficButton.alpha = 0.0;
        roomTrafficButton.enabled = false;
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Set up the "now" button.
    [liveButton setImage:[UIImage imageNamed:@"now_button"] forState:UIControlStateNormal];
    liveButton.alpha = 1.0;
    buttonSwitchOn = false;
    
    [self updateRoomTrafficButton];
    
    // Set up the time and date formatters.
    self.dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"ccc, MMM d yyyy"];
    self.dateFormat2 = [[NSDateFormatter alloc] init];
    [dateFormat2 setDateFormat: @"yyyy-MM-dd"];
    self.timeFormat = [[NSDateFormatter alloc] init];
    [timeFormat setDateFormat:@"hh:mm a"];
    
    // By default the selected day is "Today"
    self.selectedDayIndex = 0;
    self.selectedDate = [NSDate date];
    
    // Configure the next and previous day button.
    [prevDayButton setEnabled: true];
    [nextDayButton setEnabled: true];
    
    dateLabel.text = @"Today";
    timeLabel.text = [timeFormat stringFromDate: self.selectedDate];
    
    // Set up the detault initial and last time index.
    self.initialTimeIndex = 24;
    self.lastTimeIndex = 96;
    self.numTimePeriods = 72;
    
    // [self initTrafficScrollView];
    buttonSwitchOn = true;
}


- (void)updateTrafficScroll
{    
    // Remove all the subviews from the scroll view
    for (UIView *subview in trafficScrollView.subviews) {
        if([subview isKindOfClass:[UIImageView class]] || [subview isKindOfClass:[UILabel class]])
            [subview removeFromSuperview];
    }

	for (int i = 0; i < self.numTimePeriods; i++)
	{
        NSInteger index = i + self.initialTimeIndex;
        // Set up the default bar color is light grey (also for future traffic).
        UIImageView *barView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar2"]];
       
        NSDate* curDate = [[NSDate date] dateByAddingTimeInterval: 24 * 60 * 60 * selectedDayIndex];
        NSString *trafficKey = [NSString stringWithFormat:@"t%d", index];
        NSString *dateKey = [dateFormat2 stringFromDate: curDate];
        
        // Fetch the user number for a particular time period.
        CGFloat userNum;
        if (selectedDayIndex < 0)
        {
            userNum = [[[GymFlowStore sharedStore] historicalTraffic][dateKey][trafficKey] floatValue];
        } else if ((selectedDayIndex == 0) && (i < [[[GymFlowStore sharedStore] currentTraffic] count]))
        {
            userNum = [[[GymFlowStore sharedStore] currentTraffic][trafficKey] floatValue];   //not 
        } else
        {
            userNum = [[[GymFlowStore sharedStore] predictedTraffic][dateKey][trafficKey] floatValue];
        }

        // Set up the bar height. The bar view's tag number equals to the time index.
        NSInteger fullCapacityUserNum = [[[[GymFlowStore sharedStore] gymMainInfo]
                                          objectForKey:@"full_capacity"] integerValue];
		CGRect rect = barView.frame;
        if(IS_IPHONE_5) {
            rect.size.height = round(kMaxBarHeight_IPhone5 * fmin(1.0, userNum/fullCapacityUserNum));
        } else {
            rect.size.height = round(kMaxBarHeight_IPhone4 * fmin(1.0, userNum/fullCapacityUserNum));
        }
		rect.size.width = kTrafficBarWidth;
		barView.frame = rect;
		barView.tag = index;
        
        // For the current selected traffic bar, make it green (live traffic) or blue (otherwise).
        if (index == selectedTimeIndex) {
            if (selectedTimeIndex == currentTimeIndex) {
                [barView setImage:[UIImage imageNamed:@"greenbar"]];
            } else {
                [barView setImage:[UIImage imageNamed:@"bluebar"]];
            }
        }
        
        // For past traffic, simply make it to be dark blue.
        if ( ((selectedDayIndex == 0) && (index < currentTimeIndex)) || (selectedDayIndex < 0)) {
            [barView setImage:[UIImage imageNamed:@"bluebar"]];
            [barView setAlpha:0.50f];
        }
        
        // Eventually add the bar view to the scroll view. 
		[trafficScrollView addSubview: barView];
	}
    
	UIImageView *view = nil;    
	// Reposition all image subviews in a horizontal serial fashion
	CGFloat curXLoc = kScrollViewSideOffset;
	for (view in [trafficScrollView subviews])
	{
		if ([view isKindOfClass:[UIImageView class]] && view.tag >= 0)
		{
			CGRect frame = view.frame;
            if(IS_IPHONE_5) {
                frame.origin = CGPointMake(curXLoc, kMaxBarHeight_IPhone5 - frame.size.height);
            } else {
                frame.origin = CGPointMake(curXLoc, kMaxBarHeight_IPhone4 - frame.size.height);
            }
			view.frame = frame;
			
            // For all the bars with integer hours, add a time label underneath.
            if (view.tag % 4 == 0) {
                UILabel *axisLabel;
                if(IS_IPHONE_5) {
                    axisLabel = [[UILabel alloc] initWithFrame:CGRectMake(curXLoc, kMaxBarHeight_IPhone5, 25, 15)];
                } else {
                    axisLabel = [[UILabel alloc] initWithFrame:CGRectMake(curXLoc, kMaxBarHeight_IPhone4, 25, 15)];
                }
                [axisLabel setBackgroundColor: [UIColor clearColor]];
            
                // Configure the content of the time label.
                NSInteger hourNum = view.tag/4;
                NSString *timePeriod;
                if (hourNum == 12) {
                    timePeriod = @"12pm";
                } else if (hourNum < 12) {
                    timePeriod = [NSString stringWithFormat:@"%dam", hourNum];
                } else {
                    timePeriod = [NSString stringWithFormat:@"%dpm", hourNum - 12];
                }
                axisLabel.text = timePeriod;
                axisLabel.textColor = [UIColor whiteColor];
                axisLabel.textAlignment = NSTextAlignmentLeft;
                axisLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:9];
                [trafficScrollView addSubview:axisLabel];
            }
            curXLoc += kTrafficBarOffset;
		}
	}
    
    // Update traffic labels.
    [self updateTrafficLabels];
    
	// Set the content size so it is scrollable.
    CGFloat scrollViewLength = (self.numTimePeriods * kTrafficBarOffset) + 2 * kScrollViewSideOffset;
	[trafficScrollView setContentSize:CGSizeMake(scrollViewLength, [trafficScrollView bounds].size.height)];
}


- (void) updateForNewDay {
    // Change the status of the "now button"
    if (selectedDayIndex != 0) {
        [liveButton setImage:[UIImage imageNamed:@"now_button"] forState:UIControlStateNormal];
        liveButton.alpha = 0.85f;
    }
    
    // Update the date label.
    if (selectedDayIndex == 0) {
        dateLabel.text = @"Today";
    } else {
        dateLabel.text = [dateFormat stringFromDate: self.selectedDate];
    }
    
    // If the gym is closed for the whole day, set the scroll view to be non-scrollable.
    if (self.numTimePeriods == 0) {
        trafficScrollView.scrollEnabled = false;
    } else {
        trafficScrollView.scrollEnabled = true;
    }
    
    [self updateTrafficScroll];
    [self updateTrafficBar: selectedTimeIndex];
    
    if (([self selectedDayIsClosed]) && (selectedDayIndex != 0)) {
        timeLabel.text = @"";
    }
}


- (IBAction) nextDay: (id) sender {
    self.selectedDayIndex++;
    self.selectedDate = [[NSDate date] dateByAddingTimeInterval: 24 * 60 * 60 * selectedDayIndex];
 
    if (selectedDayIndex == -6) {
        [prevDayButton setEnabled: true];
        [self updateTimeIndexAndPeriod];
    } else if (selectedDayIndex == 1){
        [bubbleView setImage:[UIImage imageNamed:@"bluebubble"]];
        [self updateTimeIndexAndPeriod];
    } else if (selectedDayIndex == 0) {
        buttonSwitchOn = false;
        [liveButton setImage:[UIImage imageNamed:@"now_button"] forState:UIControlStateNormal];
        liveButton.alpha = 1.0f;
        [self updateTimeIndexAndPeriod];
        [self scrollViewToCurrentTime];
        timeLabel.text = [timeFormat stringFromDate: [NSDate date]];
        [bubbleView setImage:[UIImage imageNamed:@"greenbubble"]];
    } else if (selectedDayIndex == 7) {
        [nextDayButton setEnabled: false];
        [self updateTimeIndexAndPeriod];
    } else {
        [self updateTimeIndexAndPeriod];
    }
    
    [self updateForNewDay];
}


- (IBAction) prevDay: (id) sender {
    self.selectedDayIndex--;
    self.selectedDate = [[NSDate date] dateByAddingTimeInterval: 24 * 60 * 60 * selectedDayIndex];
    
    // If the previous day is "today".
    if (self.selectedDayIndex == 0) {
        buttonSwitchOn = false;
        [liveButton setImage:[UIImage imageNamed:@"now_button"] forState:UIControlStateNormal];
        liveButton.alpha = 1.0f;
        [self updateTimeIndexAndPeriod];
        [self scrollViewToCurrentTime];
        timeLabel.text = [timeFormat stringFromDate: [NSDate date]];
        [bubbleView setImage:[UIImage imageNamed:@"greenbubble"]];
    } else if (self.selectedDayIndex == -1) {
        [bubbleView setImage:[UIImage imageNamed:@"bluebubble"]];
        [self updateTimeIndexAndPeriod];
    } else if (self.selectedDayIndex == -7) {
        [prevDayButton setEnabled:false];
        [self updateTimeIndexAndPeriod];
    } else if (self.selectedDayIndex == 6) {
        [nextDayButton setEnabled: true];
        [self updateTimeIndexAndPeriod];
    } else {
        [self updateTimeIndexAndPeriod];
    }
    [self updateForNewDay];
}

- (void) updateTimeIndexAndPeriod {
    NSString *dateKey = [dateFormat2 stringFromDate: selectedDate];
  
    if (selectedDayIndex >= 0) {
        self.initialTimeIndex = [[[GymFlowStore sharedStore] predictedTraffic][dateKey][@"open_index"] integerValue];
        self.lastTimeIndex = [[[GymFlowStore sharedStore] predictedTraffic][dateKey][@"close_index"] integerValue];
    } else {
        self.initialTimeIndex = [[[GymFlowStore sharedStore] historicalTraffic][dateKey][@"open_index"] integerValue];
        self.lastTimeIndex = [[[GymFlowStore sharedStore] historicalTraffic][dateKey][@"close_index"] integerValue];
    }
    
    if ((initialTimeIndex >=0) && (lastTimeIndex >= 0)) {
        self.numTimePeriods = lastTimeIndex - initialTimeIndex + 1;
    } else {
        self.numTimePeriods = 0;
    }
    
    if (self.numTimePeriods == 0) {
        trafficScrollView.scrollEnabled = false;
    } else {
        trafficScrollView.scrollEnabled = true;
    }
}


- (NSString *) getTimeStringForTimeIndex: (NSInteger) index {    
    NSDate *startTime = [NSDate date];
    NSDateComponents *timeComponents = [[NSCalendar currentCalendar] components:( NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit ) fromDate: startTime];
    
    [timeComponents setHour: 0];
    [timeComponents setMinute: 0];
    [timeComponents setSecond:0];
    startTime = [[NSCalendar currentCalendar] dateFromComponents: timeComponents];
    
    NSTimeInterval secondsPerDay = 15 * 60 * index;
    startTime = [startTime dateByAddingTimeInterval: secondsPerDay];
    NSString *timeString = [NSString stringWithFormat:@"%@",
                            [timeFormat stringFromDate: startTime]];
    
    return timeString;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (buttonSwitchOn) {
        buttonSwitchOn = false;
        [liveButton setImage:[UIImage imageNamed:@"now_button"] forState:UIControlStateNormal];
        liveButton.alpha = 0.85f;
    }
    
    double tempIndex = (scrollView.contentOffset.x - kTrafficBarWidth/2)/kTrafficBarOffset + self.initialTimeIndex;
    
    NSDate *curTime = [NSDate date];
    // Detect if the time has changed

    if (round(tempIndex) != selectedTimeIndex) {
        NSInteger oldIndex = selectedTimeIndex;
        
        if (([self selectedDayIsClosed]) && (selectedDayIndex != 0)) {
            timeLabel.text = @"";
        } else if (tempIndex < 0) {
            timeLabel.text = [timeFormat stringFromDate: curTime];
            selectedTimeIndex = -1;
        } else if ( round(tempIndex) > lastTimeIndex) {
            timeLabel.text = [timeFormat stringFromDate: curTime];
            selectedTimeIndex = lastTimeIndex+1;
        } else {
            selectedTimeIndex = round(tempIndex);
            if (selectedTimeIndex == currentTimeIndex) {
                timeLabel.text = [timeFormat stringFromDate: curTime];
            } else {
                timeLabel.text = [self getTimeStringForTimeIndex:selectedTimeIndex];
            }
        }
        [self updateTrafficBar: oldIndex];
        [self updateTrafficLabels];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (buttonSwitchOn == false) {
        buttonSwitchOn = true;
    }

    if (currentTimeIndex < self.initialTimeIndex) {
        trafficLevelLabel.text = @"Closed";
        fullnessLabel.text = @"0% Full";
        userNumLabel.text = @"0";
        [bubbleView setImage:[UIImage imageNamed:@"greenbubble"]];
        if (([self selectedDayIsClosed]) && (selectedDayIndex != 0)) {
            timeLabel.text = @"";
        } else {
            timeLabel.text = [timeFormat stringFromDate: [NSDate date]];
        }
    } else if (currentTimeIndex > lastTimeIndex) {
        trafficLevelLabel.text = @"Closed";
        fullnessLabel.text = @"0% Full";
        userNumLabel.text = @"0";
        [bubbleView setImage:[UIImage imageNamed:@"greenbubble"]];
        if (([self selectedDayIsClosed]) && (selectedDayIndex != 0)) {
            timeLabel.text = @"";
        } else {
            timeLabel.text = [timeFormat stringFromDate: [NSDate date]];
        }
    }
}

- (bool) selectedDayIsClosed {
    NSString *dateKey = [dateFormat2 stringFromDate: selectedDate];
    NSInteger open_index, close_index;
    if (selectedDayIndex >= 0) {
        open_index = [[[GymFlowStore sharedStore] predictedTraffic][dateKey][@"open_index"] integerValue];
        close_index = [[[GymFlowStore sharedStore] predictedTraffic][dateKey][@"close_index"] integerValue];
    } else {
        open_index = [[[GymFlowStore sharedStore] historicalTraffic][dateKey][@"open_index"] integerValue];
        close_index = [[[GymFlowStore sharedStore] historicalTraffic][dateKey][@"close_index"] integerValue];
    }
    
    if ((open_index == -1) && (close_index == -1)) {
        return true;
    } else {
        return false;
    }
}


- (void) updateTrafficLabels {
    // Update the traffic type label
    if (selectedDayIndex < 0) {
        trafficTypeLabel.text = @"Past Traffic";
    } else if (selectedDayIndex == 0) {
        if (selectedTimeIndex == currentTimeIndex) {
            trafficTypeLabel.text = @"Current Traffic";
        } else if (selectedTimeIndex < currentTimeIndex) {
            trafficTypeLabel.text = @"Past Traffic";
        } else {
            trafficTypeLabel.text = @"Estimated Traffic";
        }
    } else {
        trafficTypeLabel.text = @"Estimated Traffic";
    }
    
    NSString *trafficKey = [NSString stringWithFormat:@"t%d", selectedTimeIndex];
    NSString *dateKey = [dateFormat2 stringFromDate: selectedDate];
        
    CGFloat curTraffic;

    if (selectedDayIndex < 0) {
        curTraffic = [[[GymFlowStore sharedStore] historicalTraffic][dateKey][trafficKey] floatValue];
    } else if ((selectedDayIndex == 0) && (selectedTimeIndex <= currentTimeIndex)) {
        curTraffic =  [[[GymFlowStore sharedStore] currentTraffic][trafficKey] floatValue];
    } else {
        curTraffic = [[[GymFlowStore sharedStore] predictedTraffic][dateKey][trafficKey] floatValue];
    }
    
    NSInteger fullCapacityNum = [[[[GymFlowStore sharedStore] gymMainInfo]
                                  objectForKey: @"full_capacity"] integerValue];
    NSInteger crowdedThreNum = [[[[GymFlowStore sharedStore] gymMainInfo]
                                 objectForKey: @"thre_crowded"] integerValue];
    NSInteger moderateThreNum = [[[[GymFlowStore sharedStore] gymMainInfo]
                                  objectForKey: @"thre_moderate"] integerValue];
    NSInteger slightThreNum = [[[[GymFlowStore sharedStore] gymMainInfo]
                                objectForKey: @"thre_slight"] integerValue];
    
    if (curTraffic == 0) {
        trafficLevelLabel.text = @"Closed";
    } else if (curTraffic > crowdedThreNum) {
        trafficLevelLabel.text = @"Crowded";
    } else if (curTraffic > moderateThreNum) {
        trafficLevelLabel.text = @"Moderate";
    } else if (curTraffic > slightThreNum) {
        trafficLevelLabel.text = @"Slight";
    } else {
        trafficLevelLabel.text = @"Empty";
    }
    
    // Calculate the fullness value.
    NSInteger fullness = round(curTraffic* 100.0f/fullCapacityNum);
    if (fullness > 100) {
        fullness = 100;
    }
    self.fullnessLabel.text = [NSString stringWithFormat:@"%d%% Full", fullness];
    
    if (curTraffic == 0) {
        self.userNumLabel.text = @"0";
    } else if (curTraffic >= fullCapacityNum) {
        self.userNumLabel.text = [NSString stringWithFormat:@"%d+", fullCapacityNum];
    } else {
        self.userNumLabel.text = [NSString stringWithFormat:@"%.0f-%.0f",
                                  floor(curTraffic/10)*10, floor(curTraffic/10)*10+10];
    }
}


- (void) updateTrafficBar: (NSInteger) oldIndex {
    for (UIView *subview in trafficScrollView.subviews) {
        if([subview isKindOfClass:[UIImageView class]] && subview.tag == selectedTimeIndex) {
            // If it's today, then color varies from green to light blue.
            if (self.selectedDayIndex < 0) {
                [(UIImageView *) subview setImage:[UIImage imageNamed:@"bluebar"]];
                [bubbleView setImage:[UIImage imageNamed:@"bluebubble"]];
                subview.alpha = 1.0;
            } else if (self.selectedDayIndex == 0) {
                if (selectedTimeIndex == currentTimeIndex) {
                    [(UIImageView *) subview setImage:[UIImage imageNamed:@"greenbar"]];
                    [bubbleView setImage:[UIImage imageNamed:@"greenbubble"]];
                } else {
                    [(UIImageView *) subview setImage:[UIImage imageNamed:@"bluebar"]];
                    [bubbleView setImage:[UIImage imageNamed:@"bluebubble"]];
                    subview.alpha = 1.0;
                }
            } else {
                [(UIImageView *) subview setImage:[UIImage imageNamed:@"bluebar"]];
                [bubbleView setImage:[UIImage imageNamed:@"bluebubble"]];
                subview.alpha = 1.0;
            }
        } else if ([subview isKindOfClass:[UIImageView class]] && subview.tag == oldIndex) {
            if (self.selectedDayIndex < 0) {
                [(UIImageView *) subview setImage:[UIImage imageNamed:@"bluebar"]];
                subview.alpha = 0.50f;
            } else if (self.selectedDayIndex == 0) {
                if (oldIndex >= currentTimeIndex) {
                    [(UIImageView *) subview setImage:[UIImage imageNamed:@"bar2"]];
                } else {
                    [(UIImageView *) subview setImage:[UIImage imageNamed:@"bluebar"]];
                    subview.alpha = 0.50f;
                }
            } else {
                [(UIImageView *) subview setImage:[UIImage imageNamed:@"bar2"]];
            }
        }
    }
}

- (void) appDelegateDataReloaded
{
    selectedDayIndex = 0;
    selectedDate = [NSDate date] ;
    [prevDayButton setEnabled:true];
    [nextDayButton setEnabled:true];
    [liveButton setImage:[UIImage imageNamed:@"now_button"] forState:UIControlStateNormal];
    
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit| NSMinuteCalendarUnit | NSWeekdayCalendarUnit) fromDate: [NSDate date]];
    currentTimeIndex = [dateComponents hour] * 4 + [dateComponents minute]/15;
    selectedTimeIndex = currentTimeIndex;
    
    [self updateTimeIndexAndPeriod];
    [self scrollViewToCurrentTime];
    [self updateForNewDay];
    
    [bubbleView setImage:[UIImage imageNamed:@"greenbubble"]];
    timeLabel.text = [timeFormat stringFromDate: [NSDate date]];
    
    [self updateRoomTrafficButton];
    self.buttonSwitchOn = false;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


@end
