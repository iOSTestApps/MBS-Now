//
//  BugsViewController.m
//  MBS Now
//
//  Created by gdyer on 10/11/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import "BugsViewController.h"
#import "SimpleWebViewController.h"

@implementation BugsViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    [self pushedDownload];

    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    self.navigationItem.title = [NSString stringWithFormat:@"Confirmed Bugs (%@)", [infoDict objectForKey:@"CFBundleShortVersionString"]];
    self.bug = @[@"Tap to refresh"];
    self.description = @[@"Connection is required"];

    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 20)];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
    [self.tableView setContentInset:UIEdgeInsetsMake(20,0,0,0)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
}

#pragma mark Table View
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *iden = @"iden";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];

    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:iden];

    cell.detailTextLabel.text = _description[indexPath.row];
    cell.textLabel.text = _bug[indexPath.row];

	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bug.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[tableView cellForRowAtIndexPath:indexPath].textLabel.text rangeOfString:@"Tap"].location != NSNotFound)
        [self pushedDownload];
}

#pragma mark Connection
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (([(NSHTTPURLResponse *)response statusCode] == 404) && connection == connect) {
        [SVProgressHUD dismiss];
        [connect cancel];
        self.bug = @[@"Tap to check again", @"No confirmed bugs"];
        self.description = @[@"Connection required", @"New reports are checked immediately"];
        [self.tableView reloadData];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [SVProgressHUD dismiss];
    if (connection == versionConnection) {
        NSInteger remoteVersion = [[[[[NSString stringWithContentsOfURL:connection.currentRequest.URL encoding:NSUTF8StringEncoding error:nil] stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"" withString:@""] integerValue];
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *f = [infoDict objectForKey:@"CFBundleShortVersionString"];
        if (remoteVersion > [[f stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update MBS Now" message:@"You're not running the current version. Bugs have likely been fixed already." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Update", nil];
            alert.tag = 2;
            [alert show];
        } else {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://raw.githubusercontent.com/gdyer/MBS-Now/master/Resources/bugs.plist"]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            connect = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
            if (connect) [SVProgressHUD showWithStatus:@"Updating"];
        }
    } else if (connection == connect) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL:connect.currentRequest.URL];
        self.bug = [dict allValues];
        self.description = [dict allKeys];
        [SVProgressHUD dismiss];
        [self.tableView reloadData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Cannot fetch confirmed bugs. %@",[error localizedDescription]]];
    self.bug = @[@"Connection failed"];
    self.description = @[@"Tap here to try again"];
    [self.tableView reloadData];
}

#pragma mark -
- (void)pushedDownload {
    [SVProgressHUD showWithStatus:@"Updating..."];
    self.description = self.bug = nil;

    NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/gdyer/MBS-Now/master/Resources/app-store-version.txt"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:15];
    versionConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

#pragma mark Actions
- (void)add {
    SimpleWebViewController *swvc = [[SimpleWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://campus.mbs.net/mbsnow/home/report.html"]];
    swvc.specifier = @"bug";
    [self presentViewController:swvc animated:YES completion:nil];
}

#pragma mark Alert view
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 2) {
        if (buttonIndex == 1) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/id617180145?mt=8"]];
        else [self dismissViewControllerAnimated:YES completion:nil];
    } else { // asking to refresh
        if (buttonIndex == 1) {
            if (alertView.tag == 2) [self add];
            else [self pushedDownload];
        }
    }
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) return YES;
    return (toInterfaceOrientation == UIDeviceOrientationPortrait) ? YES : NO;
}

@end