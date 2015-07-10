//
//  InfoViewController.h
//  GymFlow
//
//  Created by Jiangyang Zhang on 11/15/12.
//  Copyright (c) 2012 Jiangyang Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    NSMutableDictionary *gymInfoDict;
}
@property (nonatomic, retain) IBOutlet UITableView *gymTableView;
@end
