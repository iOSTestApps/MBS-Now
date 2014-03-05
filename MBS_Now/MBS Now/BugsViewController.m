//
//  BugsViewController.m
//  MBS Now
//
//  Created by gdyer on 10/11/13.
//  Copyright (c) 2013 DevelopMBS. All rights reserved.
//

#import "BugsViewController.h"
#import "SimpleWebViewController.h"

@implementation BugsViewController
BOOL unique = YES;
- (void)viewDidLoad {
    [super viewDidLoad];
    navBar.topItem.title = [NSString stringWithFormat:@"Confirmed Bugs (%@)", VERSION_NUMBER];
    self.bug = [NSArray arrayWithObject:@"Tap here to refresh"];
    self.description = [NSArray arrayWithObject:@"Connection is required"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    if (unique == YES) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Refresh Needed" message:@"Bugs must be refreshed." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Go", nil];
        [alert show];
    }
}

#pragma mark Table View
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *identifier = @"ReuseCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }

    cell.detailTextLabel.text = [self.description objectAtIndex:indexPath.row];
    cell.textLabel.text = [self.bug objectAtIndex:indexPath.row];

	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bug.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[tableView cellForRowAtIndexPath:indexPath].textLabel.text rangeOfString:@"Tap"].location != NSNotFound) {
        // text label contains 'Tap'
        [self pushedDownload];
    }
}

#pragma mark Connection
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (([(NSHTTPURLResponse *)response statusCode] == 404) && connection == connect) {
        [SVProgressHUD dismiss];
        [connect cancel];
        self.bug = [NSArray arrayWithObjects:@"Tap to check again", @"No confirmed bugs", nil];
        self.description = [NSArray arrayWithObjects:@"Connection required", @"New reports are checked very frequently", nil];
        [self.tableView reloadData];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [SVProgressHUD dismiss];
    if (connection == versionConnection) {
        NSString *fileText = [NSString stringWithContentsOfURL:connection.currentRequest.URL encoding:NSMacOSRomanStringEncoding error:nil];
        fileText = [fileText stringByReplacingOccurrencesOfString:@" " withString:@""];
        fileText = [fileText stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        if (![fileText isEqualToString:VERSION_NUMBER]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update MBS Now" message:@"You're not running the current version. Bugs have likely been fixed already." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Update", nil];
            alert.tag = 2;
            [alert show];
        } else {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://fo.gdyer.de/bugs/bugs.plist"]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            connect = [NSURLConnection connectionWithRequest:request delegate:self];
            if (connect) {
                [SVProgressHUD showWithStatus:@"Updating"];
            }
        }
    } else if (connection == connect) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL:connection.currentRequest.URL];
        self.bug = [dict allValues];
        self.description = [dict allKeys];
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Cannot fetch confirmed bugs. %@",[error localizedDescription]]];
    self.bug = [NSArray arrayWithObject:@"Connection failed"];
    self.description = [NSArray arrayWithObject:@"Tap here to try again"];
    [self.tableView reloadData];
}

#pragma mark -
- (void)pushedDownload {
    [SVProgressHUD showWithStatus:@"Updating"];
    self.description = self.bug = nil;

    NSURL *myURL = [NSURL URLWithString:@"http://fo.gdyer.de/version.txt"];
    NSURLRequest *request = [NSURLRequest requestWithURL:myURL
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:15];
    versionConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark Actions
- (IBAction)pushedAdd:(id)sender {
    unique = NO;
    SimpleWebViewController *swvc = [[SimpleWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://gdyer.de/report.html"]];
    swvc.specifier = @"bug";
    [self presentViewController:swvc animated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    [SVProgressHUD dismiss];
    unique = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Alert view
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 2 && buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/id617180145?mt=8"]];
    } else { // asking to refresh
        if (buttonIndex == 1) {
            if (alertView.tag == 2) {
                [self pushedAdd:nil];
            } else {
                [self pushedDownload];
            }
        }
    }
}


@end
