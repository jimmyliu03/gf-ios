//
//  SelectGymViewController.h
//  GymFlow
//
//  Created by Jiangyang Zhang on 12/18/12.
//  Copyright (c) 2012 Jiangyang Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectGymViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>

- (IBAction) backButtonPressed: (id)sender;
@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic, retain) IBOutlet UITableView *selectGymTable;

@end
