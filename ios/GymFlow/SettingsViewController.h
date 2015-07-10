//
//  SettingsViewController.h
//  GymFlow
//
//  Created by Jiangyang Zhang on 3/26/13.
//  Copyright (c) 2013 Jiangyang Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *settingsTableView;

@end
