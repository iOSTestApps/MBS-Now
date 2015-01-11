//
//  CSDetailViewController.m
//  MBS Now
//
//  Created by Lucas Fagan on 5/15/14.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "CSDetailViewController.h"
#import "FullPurposeViewController.h"
@implementation CSDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@",self.descriptions);
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"M/d/yyyy h:m:ss"];
    if ([format dateFromString:self.details[0]]) {
        NSString *rem = self.details[0];
        NSString *remDesc = self.descriptions[0];
        [self.details removeObjectAtIndex:0];
        [self.descriptions removeObjectAtIndex:0];
        [self.details addObject:rem];
        [self.descriptions addObject:remDesc];
    }

    self.navigationItem.title = self.details[0];
    self.tableView.showsVerticalScrollIndicator = NO;

    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 20)];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;

    [self.tableView setContentInset:UIEdgeInsetsMake(20,0,0,0)];

    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(output)];
}

#pragma mark Table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *iden = @"ReuseCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:iden];

    NSString *info = _details[indexPath.row];
    if ([info isEqualToString:@""]) {
        cell.textLabel.text = @"Not provided";
        cell.textLabel.textColor = [UIColor lightGrayColor];
    } else
        cell.textLabel.text = info;
    cell.accessoryType = (indexPath.row == 5 || (info.length > 26 && [[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    cell.detailTextLabel.text = _descriptions[indexPath.row];
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.details.count;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 5) {
        if ([_details[indexPath.row] rangeOfString:@"@"].location == NSNotFound) [SVProgressHUD showErrorWithStatus:@"Invalid address!"];
        else [self setUpMailWithTo:_details[indexPath.row] andSubject:_details[0] andBody:@""];
    }
    else if ([tableView cellForRowAtIndexPath:indexPath].accessoryType != UITableViewCellAccessoryNone) [self performSegueWithIdentifier:@"more" sender:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)genBody {
    NSString *ret = @"";
    for (int x = 0; x<_details.count; x++)
        ret = [ret stringByAppendingString:[NSString stringWithFormat:@"%@: %@\n", _descriptions[x], _details[x]]];
    return ret;
}

#pragma mark Action sheet
- (void)output {
    if (sheet) {
        [sheet dismissWithClickedButtonIndex:-1 animated:YES];
        sheet = nil;
        return;
    }

    sheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"\"%@\" service opportunity", self.details[0]] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Flag for review" otherButtonTitles:@"Email this post", nil];

    [sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: {
            [self flag];
            break;
        }
        case 1: {
            [self emailMeeting];
            break;
        }
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
        NSString *body = [[NSString stringWithContentsOfFile:path encoding:NSMacOSRomanStringEncoding error:nil] stringByAppendingString:[NSString stringWithFormat:@"<i>Request to delete: service post called \"%@\" created on %@.</i></font></div></body></html>", _details[0], _details[_details.count-1]]];

        [composerView setMessageBody:body isHTML:YES];
        [composerView setToRecipients:@[@"lucasfagan@verizon.net"]];
        [self presentViewController:composerView animated:YES completion:nil];

    } else {
        [SVProgressHUD showErrorWithStatus:@"Your device can't send mail. Use FirstClass."];
    }

}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    if (result == MFMailComposeResultSent)
        [SVProgressHUD showSuccessWithStatus:@"Queued for sending."];
    else if (result == MFMailComposeResultFailed)
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setUpMailWithTo:(NSString *)foo andSubject:(NSString *)bar andBody:(NSString *)body {
    if ([MFMailComposeViewController canSendMail] == YES) {
        MFMailComposeViewController *composerView = [[MFMailComposeViewController alloc] init];
        composerView.mailComposeDelegate = self;
        [composerView setModalPresentationStyle:UIModalPresentationFormSheet];
        [composerView setToRecipients:@[foo]];
        [composerView setSubject:bar];
        [composerView setMessageBody:body isHTML:NO];
        [self presentViewController:composerView animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Aw, snap!" message:[NSString stringWithFormat:@"Your device can't send mail."]  delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)emailMeeting {
    [self setUpMailWithTo:@"" andSubject:@"Service opportunity from MBS Now" andBody:[self genBody]];
}

#pragma mark Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"more"]) {
        [segue.destinationViewController setNavTitle:_details[0]];
        [segue.destinationViewController setFullPurpose:_details[[self.tableView indexPathForSelectedRow].row]];
    }
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) return YES;
    return toInterfaceOrientation == UIDeviceOrientationPortrait;
}

#pragma mark Alerts
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        if (alertView.tag == 1) {
            pb.string = [NSString stringWithFormat:@"[send message to lucasfagan@verizon.net]\nRequest to delete %@ created at %@", _details[0], _details[_details.count-1]];
        } else if (alertView.tag == 2) {
            [UIPasteboard generalPasteboard].string = [[self genBody] stringByAppendingString:@"\n\nOpen MBS Now Service for more information."];
            [SVProgressHUD showSuccessWithStatus:@"Copied!"];
        }
    }
}

@end