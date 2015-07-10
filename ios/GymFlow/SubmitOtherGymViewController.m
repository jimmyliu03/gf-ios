//
//  SubmitOtherGymViewController.m
//  GymFlow
//
//  Created by Jiangyang Zhang on 12/24/12.
//  Copyright (c) 2012 Jiangyang Zhang. All rights reserved.
//

#import "SubmitOtherGymViewController.h"
#import "AFJSONRequestOperation.h"

@implementation SubmitOtherGymViewController

@synthesize emailTextField;
@synthesize gymNameTextField;
@synthesize gymLocationTextField;

@synthesize gymNameString;
@synthesize emailString;
@synthesize gymLocationString;

- (IBAction)submitGymInfo:(id)sender {
    if (([emailTextField.text length] == 0) || ([gymLocationTextField.text length] == 0) ||
        ([gymNameTextField.text length] == 0)) {
        [self showInputIncompleteWarning];
    } else {
        [self postInfoToServer];
    }
    
}

- (void) showAlertForErrorConnectingToServer {
    [[[UIAlertView alloc] initWithTitle: @"Error"
                                message: @"Failed to connect to server. Check your connection."
                               delegate: self
                      cancelButtonTitle: @"OK"
                      otherButtonTitles: nil] show];
}


- (void) postInfoToServer {
    gymLocationString = gymLocationTextField.text;
    gymNameString = gymNameTextField.text;
    emailString = emailTextField.text;
    
    NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys: emailString, @"email",
                          gymNameString, @"gym_name", gymLocationString, @"gym_location", nil];
    NSError *error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:info
                                                       options:NSJSONWritingPrettyPrinted error: &error];
    NSString *requestString = [NSString stringWithFormat:@"json=%@",
                               [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
    
    
    NSURL *url = [NSURL URLWithString: @"http://54.243.28.121/web-service/post.gym.suggestion.php"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: requestData];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self showThankYouNotice];
        [self dismissViewControllerAnimated:YES completion:NULL];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self showAlertForErrorConnectingToServer];
    }];
    
    [operation start];
}


- (void) showThankYouNotice {
    [[[UIAlertView alloc] initWithTitle:@"Submission Complete!"
                                message:@"Thanks for your feedback. You will be notified when GymFlow arrives at your favourite gym."
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles: nil] show];

}


- (void) showInputIncompleteWarning {
    [[[UIAlertView alloc] initWithTitle:@"Input Incomplete"
                                message:@"Please make sure you have filled in all fields before hitting submit."
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles: nil] show];
}


- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    emailTextField.text = @"";
    gymLocationTextField.text = @"";
    gymNameTextField.text = @"";
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [emailTextField resignFirstResponder];
    [gymLocationTextField resignFirstResponder];
    [gymNameTextField resignFirstResponder];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.50];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    self.view.frame = CGRectMake(0, 20.0, 320.0, self.view.frame.size.height);
    [UIView commitAnimations];
    
    return true;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.50];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    self.view.frame = CGRectMake(0, -110.0f, 320.0, self.view.frame.size.height);
    [UIView commitAnimations];
}



@end
