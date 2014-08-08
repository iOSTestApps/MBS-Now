//
//  BugsViewController.m
//  MBS Now
//
//  Created by gdyer on 10/11/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "BugsViewController.h"
#import "SimpleWebViewController.h"

@implementation BugsViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    [self pushedDownload];

    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    self.navigationItem.title = [NSString stringWithFormat:@"Confirmed Bugs (%@)", [infoDict objectForKey:@"CFBundleShortVersionString"]];
    self.bug = [@[@"Tap to refresh"] mutableCopy];
    self.mainTitle = [@[@"Connection is required"] mutableCopy];

    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 20)];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
    [self.tableView setContentInset:UIEdgeInsetsMake(20,0,0,0)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)showNoBugs {
    [connect cancel];
    connectionData = nil;
    self.bug = [@[@"Tap to check again", @"No confirmed bugs"] mutableCopy];
    self.mainTitle = [@[@"Connection required", @"New reports are checked immediately"] mutableCopy];

    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark Table View
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *iden = @"iden";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];

    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:iden];

    cell.detailTextLabel.text = _mainTitle[indexPath.row];
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
    else [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Connection
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == connect) [connectionData appendData:data];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (([(NSHTTPURLResponse *)response statusCode] == 404) && connection == connect) {
        [SVProgressHUD dismiss];
        [self showNoBugs];
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
            self.navigationItem.rightBarButtonItem.enabled = YES;
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://raw.githubusercontent.com/mbsdev/MBS-Now/master/Resources/bugs.txt"]];
            NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10.0f];
            connect = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
            if (connect) [SVProgressHUD showWithStatus:@"Downloading..."];
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        }
    } else if (connection == connect) {
        self.bug = [NSMutableArray array];
        self.mainTitle = [NSMutableArray array];
        NSString *bugString = [[NSString alloc] initWithData:connectionData encoding:NSUTF8StringEncoding];
        if ([bugString isEqualToString:@"\n"] || [bugString isEqualToString:@""]) {[self showNoBugs]; return;}
        for (NSString *foo in [bugString componentsSeparatedByString:@"\n"]) {
            NSArray *bar = [foo componentsSeparatedByString:@" | "];
            if (bar.count == 2) {
                [_mainTitle addObject:bar[1]];
                [_bug addObject:bar[0]];
            }
        }
        [self.tableView reloadData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Cannot fetch confirmed bugs. %@",[error localizedDescription]]];
    self.bug = [@[@"Connection failed. Tap to retry"] mutableCopy];
    self.mainTitle = [@[@"Tap here to try again"] mutableCopy];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark -
- (void)pushedDownload {
    [SVProgressHUD showWithStatus:@"Updating..."];
    self.mainTitle= self.bug = nil;

    connectionData = [NSMutableData data];
    NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/gdyer/MBS-Now/master/Resources/app-store-version.txt"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15];
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