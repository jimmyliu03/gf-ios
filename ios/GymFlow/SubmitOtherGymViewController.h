//
//  SubmitOtherGymViewController.h
//  GymFlow
//
//  Created by Jiangyang Zhang on 12/24/12.
//  Copyright (c) 2012 Jiangyang Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubmitOtherGymViewController : UIViewController
<UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UITextField *emailTextField;
@property (nonatomic, retain) IBOutlet UITextField *gymNameTextField;
@property (nonatomic, retain) IBOutlet UITextField *gymLocationTextField;

@property (nonatomic, retain) NSString *emailString;
@property (nonatomic, retain) NSString *gymNameString;
@property (nonatomic, retain) NSString *gymLocationString;

- (IBAction)submitGymInfo:(id)sender;
- (IBAction)backButtonPressed: (id)sender;

@end
