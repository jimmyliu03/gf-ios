//
//  AppDelegate.m
//  GymFlow
//
//  Created by Jiangyang Zhang on 11/12/12.
//  Copyright (c) 2012 Jiangyang Zhang. All rights reserved.
//

#import "AppDelegate.h"
#import "Flurry.h"
#import "GymClass.h"
#import "TrafficViewController.h"
#import "InfoViewController.h"
#import "ScheduleViewController.h"
#import "SelectGymViewController.h"
#import "AFJSONRequestOperation.h"
#import "GymFlowStore.h"

@interface AppDelegate ()
@property (strong, nonatomic) UIViewController *initialViewController;
@end

@implementation AppDelegate

@synthesize trafficController;
@synthesize infoController;
@synthesize scheduleController;
@synthesize selectGymController;

@synthesize mainStoryboard;
@synthesize window;
@synthesize HUD;
@synthesize toolTipButton;
@synthesize toolTipTextImage;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initializeFlurry];
    [self checkGymIndex];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        self.mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    } else {
        self.mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_ios5" bundle:nil];
    }
    
    self.initialViewController = [self.mainStoryboard instantiateInitialViewController];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.initialViewController;
    [self.window makeKeyAndVisible];
    [self setUpTabBarAndViewControllers];

    [self initHUD];
    [self loadGymList];
        
    // Show the select gym page here.
    if(![[NSUserDefaults standardUserDefaults] boolForKey: @"gymSelected"]) {
        self.selectGymController = (SelectGymViewController *) [self.mainStoryboard instantiateViewControllerWithIdentifier:@"select_gym"];
        [self.window addSubview:selectGymController.view];
    } else {        
        [self loadInitialData];
        NSString *user_msg = [NSString stringWithFormat:@"User from %d", [[GymFlowStore sharedStore] currentGymIndex]];
        [Flurry logEvent:user_msg];
    }
    return YES;
}


//  Check if the gym index is valid. Fix bug for iOS5 version, where new installs will have "gymSelected"=true and
//  gym_id set to a very large number.

- (void) checkGymIndex
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"current_gym_index"]  != nil) {
        NSInteger curIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:@"current_gym_index"] integerValue];
        // Set the abnormal index number to default gym index.
        if ((curIndex <= 0) || (curIndex > kMaxGymIndex)) {
            [[GymFlowStore sharedStore] setCurrentGymIndex: kDefaultGymIndex];
        } 
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"gymSelected"];
    }
}


- (void) setUpTabBarAndViewControllers
{
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    [self changeTabbarIconStatus: false];
    [tabController setSelectedIndex: kTrafficTabBarIndex];
    [Flurry logAllPageViews:tabController];
    
    infoController = [tabController.viewControllers objectAtIndex: kGymInfoTabBarIndex];
    trafficController = [tabController.viewControllers objectAtIndex: kTrafficTabBarIndex];
    scheduleController = [tabController.viewControllers objectAtIndex: kScheduleTabBarIndex];
    
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components: NSDayCalendarUnit
                                                                       fromDate: [NSDate date]];
    UITabBarItem *dateTabBarItem = [[tabController.tabBar items] objectAtIndex:2];
    [dateTabBarItem setImage:[UIImage imageNamed:
                              [NSString stringWithFormat:@"icon_d%d", [dateComponents day]]]];
}


- (void) initializeFlurry
{
    [Flurry startSession:@"T6JDM7ZQ6ZS55B7QNMNV"];
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [Flurry logEvent:@"START_USING_APP" timed:YES];
}


- (void) showToolTipView {
     self.toolTipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if(IS_IPHONE_5) {
        self.toolTipTextImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay5textarrow"]];
        [toolTipButton setImage:[UIImage imageNamed:@"overlay5black"] forState:UIControlStateNormal];
    } else {
        self.toolTipTextImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay4textarrow"]];
        [toolTipButton setImage:[UIImage imageNamed:@"overlay4black"] forState:UIControlStateNormal];
    }

    toolTipTextImage.alpha = 1.0f;
    toolTipButton.alpha = 0.80f;
    
    [toolTipButton addTarget:self action:@selector(toolTipButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    toolTipButton.frame = [[UIScreen mainScreen] bounds];
    toolTipTextImage.frame = [[UIScreen mainScreen] bounds];

    [self.window addSubview:toolTipButton];
    [self.window addSubview:toolTipTextImage];
}

- (IBAction) toolTipButtonPressed : (id) sender {
    [toolTipButton removeFromSuperview];
    [toolTipTextImage removeFromSuperview];
}
                                           

void uncaughtExceptionHandler(NSException* exception) {
    [Flurry logError: @"Uncaught" message:@"Crash!" exception:exception];
}


- (void) removeSelectGymView {
    [UIView beginAnimations:@"curldown" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:selectGymController.view.superview cache:YES];
    [selectGymController.view removeFromSuperview];
    [UIView commitAnimations];
}


- (void) showAlertForErrorLoadingData {
    [[[UIAlertView alloc] initWithTitle: @"Warning"
                                message: @"Failed to load all data."
                               delegate: self
                      cancelButtonTitle: @"OK"
                      otherButtonTitles: nil] show];
}


- (void) showAlertForErrorConnectingToServer {
    [[[UIAlertView alloc] initWithTitle: @"Error"
                                message: @"Failed to connect to server. Check your connection."
                               delegate: self
                      cancelButtonTitle: @"OK"
                      otherButtonTitles: @"Retry", nil] show];
}

- (void) initHUD {
    HUD = [[MBProgressHUD alloc] initWithView:self.window];
    HUD.color = [UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:0.70];
	[self.window addSubview:HUD];
	HUD.delegate = self;
}


- (void) HUDShowCompletedAndDisappear {
    HUD.labelText = @"Completed";
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];;
    HUD.mode = MBProgressHUDModeCustomView;
    [HUD hide:YES afterDelay: 0.30];
}


- (BOOL) dataIsComplete
{
    if (([[[GymFlowStore sharedStore] predictedTraffic] count] == 0) ||
       ([[[GymFlowStore sharedStore] facilityHour] count] == 0) ||
       ([[[GymFlowStore sharedStore] normalHours] count] == 0)) {
        return false;
    } else {
        return true;
    }
}


- (void) loadGymList {
    [HUD show:YES];
    HUD.labelText = @"Loading list of gyms ...";
    
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString: kLoadGymListURL]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        [[GymFlowStore sharedStore] setGymList: [JSON valueForKeyPath: @"gym_list"]];
        [selectGymController.selectGymTable reloadData];
        [self HUDShowCompletedAndDisappear];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self showAlertForErrorConnectingToServer];
    }];
    
    [operation start];
}


- (void) loadInitialData
{
    [HUD show:YES];
    HUD.labelText = @"Loading data ...";
    
    NSString *initialURLString = [NSString stringWithFormat:@"%@?gym_id=%d",
                                  kInitialDataURL, [[GymFlowStore sharedStore] currentGymIndex]];
    
    // NSLog(@"%@", initialURLString);
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString: initialURLString]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        // NSLog(@"%@", JSON);
        [[GymFlowStore sharedStore] setCurrentTraffic: [JSON valueForKeyPath: @"updated_traffic"]];
        [[GymFlowStore sharedStore] setPredictedTraffic: [JSON valueForKeyPath: @"predicted_traffic"]];
        [[GymFlowStore sharedStore] setHistoricalTraffic: [JSON valueForKeyPath: @"historical_traffic"]];
        [[GymFlowStore sharedStore] setFacilityHours: [JSON valueForKeyPath: @"today_hours"]];
        [[GymFlowStore sharedStore] setNormalHours: [JSON valueForKeyPath: @"normal_hours"]];
        [[GymFlowStore sharedStore] setTodayClassSchedule:[JSON valueForKeyPath:@"class_schedules"]];
        [[GymFlowStore sharedStore] setGymMainInfo:[JSON valueForKeyPath:@"gym_info"]];
        [[GymFlowStore sharedStore] setRoomTrafficInfo: [JSON valueForKeyPath:@"room_traffic"]];
        // NSLog(@"%d", [[[GymFlowStore sharedStore] roomTrafficInfo] count]);

        [self HUDShowCompletedAndDisappear];
        [trafficController initTrafficScrollView];
        [trafficController appDelegateDataReloaded];
        // trafficController.buttonSwitchOn = false;
        
        [infoController.gymTableView reloadData];
        [scheduleController refreshResult];
        [self changeTabbarIconStatus: true];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self showAlertForErrorConnectingToServer];
    }];
    
    [operation start];
}


- (void) updateData
{
    // Don't update the data when the user is still in select/suggest gym page.
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"gymSelected"]) {
        return;
    }
    [self initHUD];
    [HUD show:YES];
    HUD.labelText = @"Updating data ...";
    
    NSString *updateURLString = [NSString stringWithFormat:@"%@?gym_id=%d",
                                 kUpdatedDataURL, [[GymFlowStore sharedStore] currentGymIndex]];
    NSString *initialURLString = [NSString stringWithFormat:@"%@?gym_id=%d",
                                     kInitialDataURL, [[GymFlowStore sharedStore] currentGymIndex]];

    NSURLRequest *request;
    if ([self dataIsComplete]) {
        request = [NSURLRequest requestWithURL: [NSURL URLWithString: updateURLString]];
    } else {
        request = [NSURLRequest requestWithURL: [NSURL URLWithString: initialURLString]];
    }
    
    if ([[[GymFlowStore sharedStore] gymList] count] == 0) {
        [self loadGymList];
    }
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        /* If data is incomplete, simply load everything. */
        if (![self dataIsComplete]) {
            [[GymFlowStore sharedStore] setCurrentTraffic: [JSON valueForKeyPath: @"updated_traffic"]];
            [[GymFlowStore sharedStore] setPredictedTraffic: [JSON valueForKeyPath: @"predicted_traffic"]];
            [[GymFlowStore sharedStore] setHistoricalTraffic: [JSON valueForKeyPath: @"historical_traffic"]];
            [[GymFlowStore sharedStore] setFacilityHours: [JSON valueForKeyPath: @"today_hours"]];
            [[GymFlowStore sharedStore] setNormalHours: [JSON valueForKeyPath: @"normal_hours"]];
            [[GymFlowStore sharedStore] setTodayClassSchedule:[JSON valueForKeyPath:@"class_schedules"]];
            [[GymFlowStore sharedStore] setGymMainInfo:[JSON valueForKeyPath:@"gym_info"]];
            [[GymFlowStore sharedStore] setRoomTrafficInfo: [JSON valueForKeyPath:@"room_traffic"]];
            
            // Reload the facility hour table.
            [infoController.gymTableView reloadData];
            
            // Reload the class schedule table.
            [scheduleController refreshResult];
            
            // Reload the traffic page.
            [trafficController initTrafficScrollView];
            [trafficController appDelegateDataReloaded];
            trafficController.buttonSwitchOn = false;
        }
        /* If data is complete, only load the updated traffic. */
        else {
            [[GymFlowStore sharedStore] setCurrentTraffic: [JSON valueForKeyPath: @"updated_traffic"]];
            [[GymFlowStore sharedStore] updateTodayPredictedTraffic:[JSON valueForKeyPath:@"updated_prediction"]];
            [[GymFlowStore sharedStore] setRoomTrafficInfo: [JSON valueForKeyPath:@"room_traffic"]];
        }
        
        [trafficController appDelegateDataReloaded];
        [self HUDShowCompletedAndDisappear];
        [self changeTabbarIconStatus: true];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self showAlertForErrorConnectingToServer];
    }];
    
    [operation start];    
}


- (void) changeTabbarIconStatus: (BOOL) flag
{
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    for(UITabBarItem *item in tabController.tabBar.items) {
        item.enabled = flag;
    }
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if ([HUD superview] != nil) {
        [HUD removeFromSuperview];
    }
	HUD = nil;
    if ([toolTipButton superview] != nil) {
        [toolTipButton removeFromSuperview];
    }
    toolTipButton = nil;
    
    if ([toolTipTextImage superview] != nil) {
        [toolTipTextImage removeFromSuperview];
    }
    toolTipTextImage = nil;
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    [tabController setSelectedIndex: kTrafficTabBarIndex];
    [self updateData];
    
    NSString *user_msg = [NSString stringWithFormat:@"User from %d", [[GymFlowStore sharedStore] currentGymIndex]];
    [Flurry logEvent:user_msg];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [Flurry endTimedEvent:@"START_USING_APP" withParameters:nil];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Retry"]) {
        [self loadInitialData];
    }
    [HUD hide:YES afterDelay:0.00];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	//Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}

@end



