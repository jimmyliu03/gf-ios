//
//  ClassDetailViewController.h
//  GymFlow
//
//  Created by Jiangyang Zhang on 12/9/12.
//  Copyright (c) 2012 Jiangyang Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GymClass.h"

@interface ClassDetailViewController : UIViewController

@property (nonatomic, retain) IBOutlet UIImageView *classImage;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UILabel *roomLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UITextView *desciptText;
@property (nonatomic, retain) GymClass *curClass;

@property (nonatomic, copy) NSString *dateString;

- (IBAction) backButtonPressed:(id)sender;

@end
