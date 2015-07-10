//
//  LeaveFeedbackViewController.m
//  GymFlow
//
//  Created by Jiangyang Zhang on 3/27/13.
//  Copyright (c) 2013 Jiangyang Zhang. All rights reserved.
//

#import "LeaveFeedbackViewController.h"
#import "AFJSONRequestOperation.h"

@implementation LeaveFeedbackViewController

@synthesize userNameTextField;
@synthesize userEmailTextField;
@synthesize feedbackTextView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//
// Alerts
//

- (void) showInputIncompleteWarning {
    [[[UIAlertView alloc] initWithTitle:@"Empty Feedback?"
                                message:@"Please leave your valuable feedback. We appreciate your time."
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles: nil] show];
}

- (void) showAlertForErrorConnectingToServer {
    [[[UIAlertView alloc] initWithTitle: @"Error"
                                message: @"Failed to connect to server. Check your connection."
                               delegate: self
                      cancelButtonTitle: @"OK"
                      otherButtonTitles: nil] show];
}

- (void) showThankYouNotice {
    [[[UIAlertView alloc] initWithTitle:@"Feedback Submitted!"
                                message:@"We appreciate your time and effort in providing feedback to us."
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles: nil] show];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) backButtonPressed :(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction) feedbackSubmitted:(id)sender {
    if ([feedbackTextView.text length] == 0) {
        [self showInputIncompleteWarning];
    } else {
        [self postFeedbackToServer];
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}


- (void) postFeedbackToServer {
    NSLog(@"post to server!");
    NSLog(@"name: %@\n", userNameTextField.text);
    NSLog(@"name: %@\n", userEmailTextField.text);
    NSLog(@"name: %@\n", feedbackTextView.text);
    
    NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys: userEmailTextField.text, @"email",
                          userNameTextField.text, @"user", feedbackTextView.text, @"feedback", nil];
    NSError *error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:info
                                                       options:NSJSONWritingPrettyPrinted error: &error];
    NSString *requestString = [NSString stringWithFormat:@"json=%@",
                               [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    NSData *requestData = [NSData dataWithBytes: [requestString UTF8String] length: [requestString length]];
    
    
    NSURL *url = [NSURL URLWithString: @"http://54.243.28.121/web-service/post.feedback.php"];
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


- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [userNameTextField resignFirstResponder];
    [userEmailTextField resignFirstResponder];
    
    return true;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {

}

- (void) textViewDidBeginEditing:(UITextView *)textView {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.50];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    self.view.frame = CGRectMake(0, -160.0f, 320.0, self.view.frame.size.height);
    [UIView commitAnimations];
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
{
	if ([text isEqualToString: @"\n"]) {
        [textView resignFirstResponder];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.50];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        self.view.frame = CGRectMake(0, 20.0, 320.0, self.view.frame.size.height);
        [UIView commitAnimations];
        return NO;
    }
    return YES;
}

@end
