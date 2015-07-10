//
//  AppDelegate.h
//  GymFlow
//
//  Created by Jiangyang Zhang on 11/12/12.
//  Copyright (c) 2012 Jiangyang Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

// #define kLoadGymListURL        @"http://54.243.28.121/web-service/server_call2.0/load_gym_list.php"
// #define kInitialDataURL        @"http://54.243.28.121/web-service/server_call2.0/load_initial_data.php"
// #define kUpdatedDataURL        @"http://54.243.28.121/web-service/server_call2.0/load_updated_data.php"

#define kLoadGymListURL        @"http://54.243.28.121/beta/server_call_2.1/load_gym_list.php"
#define kInitialDataURL        @"http://54.243.28.121/beta/server_call_2.1/load_initial_data.php"
#define kUpdatedDataURL        @"http://54.243.28.121/beta/server_call_2.1/load_updated_data.php"

#define kGymInfoTabBarIndex    0
#define kTrafficTabBarIndex    1
#define kScheduleTabBarIndex   2
#define kDefaultGymIndex       1
#define kMaxGymIndex           3

#define IS_WIDESCREEN (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:(v) options:NSNumericSearch] != NSOrderedAscending)

#define IS_IPHONE ([[[UIDevice currentDevice]model] isEqualToString:@"iPhone"])
#define IS_IPOD   ([[[UIDevice currentDevice]model] isEqualToString:@"iPod touch"])
#define IS_IPHONE_5 (IS_IPHONE && IS_WIDESCREEN)

@class TrafficViewController;
@class InfoViewController;
@class ScheduleViewController;
@class SelectGymViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, MBProgressHUDDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIStoryboard *mainStoryboard;

@property (retain, nonatomic) TrafficViewController *trafficController;
@property (retain, nonatomic) InfoViewController *infoController;
@property (retain, nonatomic) ScheduleViewController *scheduleController;
@property (retain, nonatomic) SelectGymViewController *selectGymController;

@property (nonatomic, retain) MBProgressHUD *HUD;
@property (nonatomic, retain) UIButton *toolTipButton;
@property (nonatomic, retain) UIImageView *toolTipTextImage;

- (void) updateData;
- (void) removeSelectGymView;
- (void) initHUD;
- (void) loadInitialData;
- (void) showToolTipView;
- (void) HUDShowCompletedAndDisappear;

@end
