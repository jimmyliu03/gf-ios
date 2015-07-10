//
//  RoomTrafficViewController.h
//  GymFlow
//
//  Created by Jiangyang Zhang on 9/8/13.
//  Copyright (c) 2013 Jiangyang Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoomTrafficViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>

- (IBAction) backButtonPressed:(id)sender;

@property (nonatomic, retain) IBOutlet UITableView *roomTrafficTableView;

@end
