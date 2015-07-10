//
//  LeaveFeedbackViewController.h
//  GymFlow
//
//  Created by Jiangyang Zhang on 3/27/13.
//  Copyright (c) 2013 Jiangyang Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeaveFeedbackViewController : UIViewController
<UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, retain) IBOutlet UITextField *userNameTextField;
@property (nonatomic, retain) IBOutlet UITextField *userEmailTextField;
@property (nonatomic, retain) IBOutlet UITextView *feedbackTextView;

- (IBAction) backButtonPressed :(id)sender;
- (IBAction) feedbackSubmitted:(id)sender;
@end
