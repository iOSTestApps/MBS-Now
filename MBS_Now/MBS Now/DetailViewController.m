//
//  DetailViewController.m
//  MBS Now
//
//  Created by gdyer on 11/1/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "DetailViewController.h"
#import "InfoViewController.h"
#import "RSVPViewController.h"
#import "FullPurposeViewController.h"
#import "ExploreViewController.h"
#import <EventKit/EventKit.h>

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSMutableArray *newDescriptions = [NSMutableArray arrayWithArray:self.descriptions];
    [newDescriptions insertObject:newDescriptions[0] atIndex:newDescriptions.count];
    [newDescriptions removeObjectAtIndex:0];
    [newDescriptions insertObject:@"View the clubs & meetings help page" atIndex:newDescriptions.count];
    self.descriptions = [NSArray arrayWithArray:newDescriptions];

    NSMutableArray *newDetails = [NSMutableArray arrayWithArray:self.details];
    [newDetails insertObject:newDetails[0] atIndex:newDetails.count];
    [newDetails removeObjectAtIndex:0];
    [newDetails insertObject:@"Questions?" atIndex:newDetails.count];

    NSString *newEmail = newDetails[5];
    newEmail = [@"RSVP: " stringByAppendingString:newEmail];
    [newDetails removeObjectAtIndex:5];
    [newDetails insertObject:newEmail atIndex:5];

    self.details = [NSArray arrayWithArray:newDetails];

    self.navigationItem.title = self.details[0];

    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 20)];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;

    [self.tableView setContentInset:UIEdgeInsetsMake(20,0,0,0)];

    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

#pragma mark Table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *simpleTableIdentifier = @"ReuseCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    cell.textLabel.text = [self.details objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [self.descriptions objectAtIndex:indexPath.row];
    if (indexPath.row > 3 && indexPath.row != 7) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if ((indexPath.row == 4) && ([[self.details objectAtIndex:4] length] > 26)) {
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        } else if (indexPath.row == 6 && ([[self.details objectAtIndex:6] length] < 26)) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
	return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showFullLocation" sender:self];
    self.detailIndexPath = indexPath.row;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.descriptions.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 4: {
            [self performSegueWithIdentifier:@"showExplore" sender:self];
            break;
        }
        case 5:
            // find email
            if ([[tableView cellForRowAtIndexPath:indexPath].textLabel.text rangeOfString:@"@"].location == NSNotFound) {
                [SVProgressHUD showErrorWithStatus:@"Cannot RSVP. No email address detected."];
                return;
            }
            [self performSegueWithIdentifier:@"showRSVP" sender:self];
             break;
        case 6:
            if ([[self.details objectAtIndex:6] length] > 26) {
                [self performSegueWithIdentifier:@"showPurpose" sender:self];
            }
            break;
        case 8:
            [self performSegueWithIdentifier:@"showHelp" sender:self];
            break;
        default:
            break;
    }
}

#pragma mark Action sheet
- (IBAction)output:(id)sender {
    if (sheet) {
        [sheet dismissWithClickedButtonIndex:-1 animated:YES];
        sheet = nil;
        return;
    }
    sheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@ meeting", [self.details objectAtIndex:0]] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Flag for review" otherButtonTitles:@"Create reminder notification", @"Email this meeting", nil];

    [sheet showFromBarButtonItem:output animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            [self flag];
            break;
        }
        case 1: {
            [self setUpNotification];
            break;
        }
        case 2: {
            [self emailMeeting];
            break;
        }
        default:
            break;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    sheet = nil;
}

- (void)flag {
    if ([MFMailComposeViewController canSendMail] == YES) {
        MFMailComposeViewController *composerView = [[MFMailComposeViewController alloc] init];
        composerView.mailComposeDelegate = self;
        [composerView setModalPresentationStyle:UIModalPresentationFormSheet];
        [composerView setSubject:@"Flag meeting"];

        NSString *path = [[NSBundle mainBundle] pathForResource:@"delete" ofType:@"html"];
        NSString *body = [[NSString stringWithContentsOfFile:path encoding:NSMacOSRomanStringEncoding error:nil] stringByAppendingString:[NSString stringWithFormat:@"<i>Request to delete: %@ meeting on %@, created on %@.</i></font></div></body></html>", [self.details objectAtIndex:0], [self.details objectAtIndex:1], [self.details objectAtIndex:7]]];

        [composerView setMessageBody:body isHTML:YES];
        [composerView setToRecipients:@[@"lucasfagan@verizon.net"]];
        [self presentViewController:composerView animated:YES completion:nil];

    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Device cannot send mail" message:@"Your device cannot send mail. Would you like to copy the recipient address and meeting details?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag = 1;
        [alert show];
    }

}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    if (result == MFMailComposeResultSent)
        [SVProgressHUD showSuccessWithStatus:@"Queued for sending."];
    else if (result == MFMailComposeResultFailed)
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setUpNotification {
    UILocalNotification *lcl = [[UILocalNotification alloc] init];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    NSString *dateString = [NSString stringWithFormat:@"%@ %@", [self.details objectAtIndex:1], [self.details objectAtIndex:2]];
    NSDate *bar = [dateFormat dateFromString:dateString];

    NSComparisonResult result = [[NSDate date] compare:bar];
   if (result == -1) {
        lcl.fireDate = [bar dateByAddingTimeInterval:(-5*60)];
        lcl.alertBody = [NSString stringWithFormat:@"%@ meeting in 5 minutes. Meet here: %@", [self.details objectAtIndex:0], [self.details objectAtIndex:4]];
        lcl.soundName = UILocalNotificationDefaultSoundName;
        lcl.alertAction = @"View";
        lcl.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
        lcl.timeZone = [NSTimeZone defaultTimeZone];
        NSLog(@"%@",lcl);

        [SVProgressHUD showSuccessWithStatus:@"We'll remind you 5 minutes before."];

        [[UIApplication sharedApplication] scheduleLocalNotification:lcl];
   } else
    [SVProgressHUD showErrorWithStatus:@"Oops! This meeting already happened or has an unrecognizable date."];
}

- (void)emailMeeting {
    if ([MFMailComposeViewController canSendMail] == YES) {
        MFMailComposeViewController *composerView = [[MFMailComposeViewController alloc] init];
        composerView.mailComposeDelegate = self;
        [composerView setModalPresentationStyle:UIModalPresentationFormSheet];
        [composerView setSubject:[NSString stringWithFormat:@"%@ meeting", [self.details objectAtIndex:0]]];

        [composerView setMessageBody:[NSString stringWithFormat:@"<html><body><li><strong>%@</strong> is meeting on <strong>%@ at %@</strong> here: %@.</li><li>This meeting was created on %@.</li>Open MBS Now to view more details.</body></html>", [self.details objectAtIndex:0], [self.details objectAtIndex:1], [self.details objectAtIndex:2], [self.details objectAtIndex:4], [self.details objectAtIndex:7]] isHTML:YES];
        [self presentViewController:composerView animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Device cannot send mail" message:@"Your device cannot send mail. Would you like to copy the meeting data to your clipboard?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag = 2;
        [alert show];
    }
}

#pragma mark Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showHelp"])
        [segue.destinationViewController setSegueIndex:2];
    else if ([segue.identifier isEqualToString:@"showRSVP"]) {
        NSString *labelText = [self.details objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        [segue.destinationViewController setLabel:labelText];
        [segue.destinationViewController setDetails:self.details];
    } else if ([segue.identifier isEqualToString:@"showPurpose"]) {
        NSString *labelText = [self.details objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        [segue.destinationViewController setFullPurpose:labelText];
        [segue.destinationViewController setNavTitle:@"Purpose or Agenda"];
        [segue.destinationViewController setHideNavBar:YES];
    } else if ([segue.identifier isEqualToString:@"showFullLocation"]) {
        NSString *labelText = [self.details objectAtIndex:4];
        [segue.destinationViewController setFullPurpose:labelText];
        [segue.destinationViewController setNavTitle:@"Location"];
        [segue.destinationViewController setHideNavBar:YES];
    }
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) return YES;
    return (toInterfaceOrientation == UIDeviceOrientationPortrait) ? YES : NO;
}

#pragma mark Alerts
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        if (alertView.tag == 1) {
            // copy address -- no mail set up
            pb.string = [NSString stringWithFormat:@"[send message to lucasfagan@verizon.net]\nRequest to delete: %@ meeting on %@, created on %@.", [self.details objectAtIndex:1], [self.details objectAtIndex:2], [self.details objectAtIndex:0]];
        } else if (alertView.tag == 2) {
            pb.string = [NSString stringWithFormat:@"%@ is meeting on %@ at %@ at this location: %@. This meeting was created on %@. Open MBS Now to view more details.", [self.details objectAtIndex:1], [self.details objectAtIndex:2], [self.details objectAtIndex:3], [self.details objectAtIndex:5], [self.details objectAtIndex:0]];
        }
        [SVProgressHUD showSuccessWithStatus:@"Copied"];
    }
}

@end
