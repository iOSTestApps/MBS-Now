//
//  RSVPViewController.m
//  MBS Now
//
//  Created by gdyer on 11/3/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import "RSVPViewController.h"

@implementation RSVPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.boolLabel.text = @"yes";
    self.label = [self.label componentsSeparatedByString:@" "][1]; // removes the "RSVP: " text
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"yourName"])
        self.nameField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"yourName"];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self go:nil];
    return YES;
}

#pragma mark Actions
- (IBAction)go:(id)sender {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"rsvps"]) {
        // first time RSVPing
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"rsvps"];
    } else {
        NSInteger q = [[NSUserDefaults standardUserDefaults] integerForKey:@"rsvps"];
        q++;
        [[NSUserDefaults standardUserDefaults] setInteger:q forKey:@"rsvps"];
    }

    [self.nameField resignFirstResponder];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:self.details[7]] == YES) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Heads up!" message:@"You've already RSVPed to this meeting." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Contact creator", nil];
        [alert show];
        return;
    }
    if (self.nameField.text.length < 4 || ([self.nameField.text rangeOfString:@" "].location == NSNotFound)) {
        [SVProgressHUD showErrorWithStatus:@"Full name, please!"];
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:self.nameField.text forKey:@"yourName"];

    // consult rsvp.php locally
    NSString *string = [NSString stringWithFormat:@"%@;%@;%@;%@;%@", self.details[5], self.nameField.text, self.boolLabel.text, self.details[0], self.details[1]];
    NSString *escapedString = [string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"http://campus.mbs.net/mbsnow/scripts/rsvp.php?query=%@", escapedString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];

    [request setHTTPMethod:@"GET"];

    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connection) [SVProgressHUD showWithStatus:@"Working"];

}

- (IBAction)switchDidChange:(id)sender {
    [self.nameField resignFirstResponder];
    self.boolLabel.text = (self.boolSwitch.on == YES) ? (@"yes") : (@"no");
}

// iPad only
- (IBAction)pushedDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)notify {
    if ([self.boolLabel.text isEqualToString:@"yes"]) {
        UILocalNotification *lcl = [[UILocalNotification alloc] init];

        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
        NSString *dateString = [NSString stringWithFormat:@"%@ %@", self.details[1], self.details[2]];
        NSDate *bar = [dateFormat dateFromString:dateString];

        NSComparisonResult result = [[NSDate date] compare:bar];
        if (result == NSOrderedAscending) {
            lcl.fireDate = [bar dateByAddingTimeInterval:(-5*60)];
            lcl.alertBody = [NSString stringWithFormat:@"%@ meeting in 5 minutes. Meet here: %@", self.details[0], self.details[4]];
            lcl.soundName = UILocalNotificationDefaultSoundName;
            lcl.alertAction = @"View";
            lcl.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
            lcl.timeZone = [NSTimeZone defaultTimeZone];

            [[UIApplication sharedApplication] scheduleLocalNotification:lcl];
            return YES;
        } else return NO;
    } else return NO;
}

- (IBAction)directContact:(id)sender {
    if ([MFMailComposeViewController canSendMail] == YES) {
        MFMailComposeViewController *composerView = [[MFMailComposeViewController alloc] init];
        composerView.mailComposeDelegate = self;
        [composerView setModalPresentationStyle:UIModalPresentationFormSheet];
        [composerView setSubject:[NSString stringWithFormat:@"%@ meeting", [self.details objectAtIndex:0]]];

        NSString *path = [[NSBundle mainBundle] pathForResource:@"contactme" ofType:@"html"];
        NSString *body = [[NSString stringWithContentsOfFile:path encoding:NSMacOSRomanStringEncoding error:nil] stringByAppendingString:[NSString stringWithFormat:@"\n\n%@ meeting on %@ at %@.</font></div></body></html>", self.details[0], self.details[1], self.details[2]]];

        [composerView setMessageBody:body isHTML:YES];

        [composerView setToRecipients:@[self.label]];
        [self presentViewController:composerView animated:YES completion:nil];
    } else {
        // can't send mail
        [[UIPasteboard generalPasteboard] setString:self.label];
        [SVProgressHUD showErrorWithStatus:@"Your device cannot send mail. The recipient's address has been copied."];
    }
}

#pragma mark Connection
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [SVProgressHUD dismiss];
    NSString *echo = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if ([echo isEqualToString:@"sent"]) {
        if ([self notify] == YES)
            [SVProgressHUD showSuccessWithStatus:@"RSVPed successfully. We'll also remind you 5 minutes before the meeting starts."];
        else [SVProgressHUD showSuccessWithStatus:@"RSVPed successfully"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:self.details[7]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else [SVProgressHUD showErrorWithStatus:@"Aw, snap! RSVPing failed; please try again."];
}
    
#pragma mark Alerts
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1)
        [self directContact:nil];
}

#pragma mark Mail
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    if (result == MFMailComposeResultSent)
        [SVProgressHUD showSuccessWithStatus:@"Queued for sending."];
    else if (result == MFMailComposeResultFailed)
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end