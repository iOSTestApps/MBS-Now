//
//  CSDetailViewController.m
//  Community Service
//
//  Created by Lucas Fagan on 6/10/14.
//  Copyright (c) 2014 Lucas Fagan. All rights reserved.
//

#import "CSDetailViewController.h"

@implementation CSDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.array[7]  isEqualToString: @"Ongoing"]) {
        self.array[2] = @"No Date Specified";
        self.array[3] = @"No Start Time Specified";
        self.array[4] = @"No End Time Specified";
    }
    if ([self.array[2] isEqualToString:@""]) {
        self.array[2] = @"No Date Specified";
    }
    if ([self.array[3] isEqualToString:@""]) {
        self.array[3] = @"No Start Time Specified";
    }
    if ([self.array[4] isEqualToString:@""]) {
        self.array[4] = @"No End Time Specified";
    }
    if ([self.array[5] isEqualToString:@""]) {
        self.array[5] = @"No Details Specified";
    }
    NSString *stringg = self.array[6];
    if ([stringg rangeOfString:@"@"].location == NSNotFound) {
        self.array[6] = @"Invalid Email Address";
        self.emailButton.enabled = NO;
    } 
   
    self.emailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;

    self.navigationItem.title = self.array[1];
    self.dateLabel.text = self.array[2];
    self.startTimeLabel.text = self.array[3];
    self.endTimeLabel.text = self.array[4];
    self.detailsView.text = self.array[5];
    NSString *lowerCase = [self.array[6] lowercaseString];
    [self.emailButton setTitle:lowerCase forState:UIControlStateNormal];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];

    if (result == MFMailComposeResultSent) [SVProgressHUD showSuccessWithStatus:@"Sent!"];
    else if (result == MFMailComposeResultFailed) [SVProgressHUD showErrorWithStatus:@"Failed to send!"];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 44 && buttonIndex == 0) {
        NSArray *objectsToShare = @[];

        if ([self.array[7] isEqualToString:@"Ongoing"]) {
            NSString *stringg = [NSString stringWithFormat:@"%@ is an ongoing community service opportunity", self.array[1]];
            objectsToShare = @[stringg];
        } else {
            //one time event
        if (![self.array[2] isEqualToString:@"No Date Specified"] && ![self.array[3] isEqualToString:@"No Start Time Specified"] && ![self.array[4] isEqualToString:@"No End Time Specified"]) {
            //everything provided
            NSString *strngg = [NSString stringWithFormat:@"%@ is on %@ from %@ to %@.",self.array[1], self.array[2], self.array[3], self.array[4]];
            objectsToShare = @[strngg];
        } else if (![self.array[2] isEqualToString:@"No Date Specified"] && ![self.array[3] isEqualToString:@"No Start Time Specified"]) {
            //everything but an end time
            NSString *strng  = [NSString stringWithFormat:@"%@ is on %@ starting at %@.",self.array[1], self.array[2], self.array[3]];
            objectsToShare = @[strng];
        } else if (![self.array[2] isEqualToString:@"No Date Specified"]) {
            NSString *strng = [NSString stringWithFormat:@"%@ is on %@.",self.array[1],self.array[2]];
            objectsToShare = @[strng];
        } else {
            NSString *string = [NSString stringWithFormat:@"%@ is an ongoing community service oppurtunity.",self.array[1]];
            objectsToShare = @[string];
            }
        }
       
        
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
        
        // Exclude all activities except AirDrop.
        NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                        UIActivityTypePostToWeibo,
                                        UIActivityTypePrint,
                                        UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                        UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                        UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
        controller.excludedActivityTypes = excludedActivities;
        
        // Present the controller
        [self presentViewController:controller animated:YES completion:nil];
        return;
    } else if (actionSheet.tag == 44 && buttonIndex == 1) {
        if ([self.array[2] isEqualToString:@"No Date Specified"]) {
            [SVProgressHUD showErrorWithStatus:@"Sorry, but there's no date associated with this event!"];
        } else {
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"h:mm a MM/dd/yy"];
            [format setTimeZone:[NSTimeZone localTimeZone]];
            NSString *dateString = [NSString stringWithFormat:@"%@ %@",self.array[3],self.array[2]];
            NSDate *datee = [format dateFromString:dateString];
            if ([[NSDate date] compare:datee] == NSOrderedAscending) {
                //theres a date
                if ([self.array[3] isEqualToString:@"No Start Time Specified"]) {
                    NSDateFormatter *format = [[NSDateFormatter alloc] init];
                    [format setDateFormat:@"HH:mm MM/dd/yy"];
                    [format setTimeZone:[NSTimeZone localTimeZone]];
                    NSString *dateString = [NSString stringWithFormat:@"08:00 %@",self.array[2]];
                    NSDate *date = [format dateFromString:dateString];
                    UILocalNotification *lnf = [[UILocalNotification alloc] init];
                    lnf.fireDate = date;
                    lnf.alertBody = [NSString stringWithFormat:@"%@ is today",self.navigationItem.title];
                    lnf.timeZone = [NSTimeZone defaultTimeZone];
                    [[UIApplication sharedApplication] scheduleLocalNotification:lnf];
                    // NSString *striing = [NSString stringWithFormat:@"%@",lnf];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert Created" message:@"Alert created for 8:00 AM on the day of the event." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                    [alert show];
                    
                } else {
        
                    UILocalNotification *lnf = [[UILocalNotification alloc] init];
                    lnf.fireDate = [datee dateByAddingTimeInterval:-60*30]; //30 min before
                    lnf.alertBody = [NSString stringWithFormat:@"%@ is today",self.navigationItem.title];
                    lnf.timeZone = [NSTimeZone defaultTimeZone];
                    [[UIApplication sharedApplication] scheduleLocalNotification:lnf];
                    // NSString *striing = [NSString stringWithFormat:@"%@",lnf];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert Created" message:@"Alert created for 30 minutes before start time" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                    [alert show];
                    
                }
            } else {
                //event has already happened
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Event Has Passed" message:@"Sorry, but is seems like this event has already happened." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
                [alert show];
            }
         
            
        }
    }
    
   /* if ((actionSheet.tag == 2 && buttonIndex == 4)||(actionSheet.tag == 1 && buttonIndex == 0)||(actionSheet.tag == 3 && buttonIndex == 5)) {
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        CGSize pickerSize = [datePicker sizeThatFits:CGSizeZero];
        datePicker.frame = CGRectMake(0, 356, pickerSize.width, pickerSize.height);
        datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        self.detailsTitle.hidden = YES;
        self.detailsView.hidden = YES;
        [self.view addSubview:datePicker];
    } else if ((actionSheet.tag == 2 && buttonIndex == 0)||(actionSheet.tag == 3 && buttonIndex == 1)) {
        [self scheduleNotificationAtTime:@"08:00 AM" isToday:YES];
    } else if ((actionSheet.tag == 2 && buttonIndex == 1)||(actionSheet.tag == 3 && buttonIndex == 2)) {
        [self scheduleNotificationAtTime:@"12:00 PM" isToday:YES];
    } else if ((actionSheet.tag == 2 && buttonIndex == 2)||(actionSheet.tag == 3 && buttonIndex == 3)) {
        [self scheduleNotificationAtTime:@"08:00 AM" isToday:NO];
    } else if ((actionSheet.tag == 2 && buttonIndex == 3)||(actionSheet.tag == 3 && buttonIndex == 4)){
        [self scheduleNotificationAtTime:@"12:00 PM" isToday:NO];
    } else {
        //must be an alert for start time, so tag = 3 and buttonIndex = 0
        [self scheduleNotificationAtTime:self.array[3] isToday:YES];
    } */
}
/*-(void)scheduleNotificationAtTime:(NSString *)time isToday:(BOOL)today {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"HH:mm a MM/dd/yy";
    NSString *dateString = [NSString stringWithFormat:@"%@ %@",time,self.array[2]];
    NSDate *date = [format dateFromString:dateString];
    UILocalNotification *lnf = [[UILocalNotification alloc] init];
    lnf.fireDate = date;
    if (today == YES) {
        lnf.alertBody = [NSString stringWithFormat:@"%@ is today",self.navigationItem.title];
        lnf.timeZone = [NSTimeZone defaultTimeZone];

    } else {
        lnf.alertBody = [NSString stringWithFormat:@"%@ is tomorrow",self.navigationItem.title];
        lnf.timeZone = [NSTimeZone defaultTimeZone];
    }

    [[UIApplication sharedApplication] scheduleLocalNotification:lnf];
}*/


#pragma mark Actions
- (IBAction)emailButtonPushed:(id)sender {
    if ([MFMailComposeViewController canSendMail] == YES) {
        MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;
        [picker setSubject:@"I'm Interested"];
        NSArray *toRecipients = @[self.emailButton.titleLabel.text];
        [picker setToRecipients:toRecipients];
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot Send Mail" message:@"This device cannot send mail. Make sure you have an internet connection and an email account set up in settings." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)exportButton:(id)sender {
    UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share",@"Set up alert", nil];
    as.tag = 44;
    [as showFromBarButtonItem:_exportButton animated:YES];
}
/* - (IBAction)exportButton:(id)sender {
 
 NSString *a = [NSString stringWithFormat:@"Set up reminder for %@",self.navigationItem.title];
 UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:a delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Custom alert", nil];
 sheet.tag = 1;
 if ([self.array[7] isEqualToString:@"Ongoing"]) {
 [sheet showFromBarButtonItem:self.exportButton animated:YES];
 } else {
 if ([self.array[2] isEqualToString:@"No Date Specified"]) {
 [sheet showFromBarButtonItem:self.exportButton animated:YES];
 }
 else if ([self.array[3] isEqualToString:@"No Start Time Specified"] && !([self.array[2] isEqualToString:@"No Date Specified"])) {
 UIActionSheet *sheet2 = [[UIActionSheet alloc] initWithTitle:a delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"8:00 AM on day of event",@"12:00 PM on day of event",@"8:00 AM on day before event",@"12:00 PM on day before event", @"Custom alert",nil];
 sheet2.tag = 2;
 [sheet2 showFromBarButtonItem:self.exportButton animated:YES];
 } else {
 UIActionSheet *sheet3 = [[UIActionSheet alloc] initWithTitle:a delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Start time on day of event",@"8:00 AM on day of event",@"12:00 PM on day of event",@"8:00 AM on day before event",@"12:00 PM on day before event", @"Custom alert",nil];
 [sheet3 showFromBarButtonItem:self.exportButton animated:YES];
 sheet3.tag = 3;
 }
 }
 } */
@end