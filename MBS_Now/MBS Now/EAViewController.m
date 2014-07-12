//
//  EAViewController.m
//  MBS Now
//
//  Created by gdyer on 9/23/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "EAViewController.h"
#import "SimpleWebViewController.h"
@implementation EAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self download];
    distinctions = @[@"Hang tight... refreshing"];
    string = nil;

    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 20)];
    footer.backgroundColor = [UIColor clearColor];
    self.tblView.tableFooterView = footer;
    self.searchDisplayController.searchBar.userInteractionEnabled = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(download)];

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Fetching... just for you ;)"];
    [refresh addTarget:self action:@selector(download) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [self.tblView addSubview:self.refreshControl];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
    [firstConnection cancel];
}

#pragma mark Table View
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *iden = @"iden";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];

    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:iden];

    cell.detailTextLabel.text = string;
    cell.textLabel.text = distinctions[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return distinctions.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return  (string) ? @"Go to lunch FIRST if your class is NOT here" : nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Actions
- (void)download {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM d, h:mm:ss a";
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated %@", [formatter stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];

    if (!_refreshControl.refreshing) [SVProgressHUD showWithStatus:@"Updating..."];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/gdyer/MBS-Now/master/Resources/Data/distinctions.txt"]];
    firstConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark Connection
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.refreshControl endRefreshing];
    [SVProgressHUD dismiss];
    NSString *separation = @"\n";
    if (connection == firstConnection) {
        NSString *fileText = [NSString stringWithContentsOfURL:connection.currentRequest.URL encoding:NSMacOSRomanStringEncoding error:nil];
        distinctions = [[NSArray alloc] initWithArray:[fileText componentsSeparatedByString:separation]];
        if (distinctions.count == 0) {
            [self connection:connection didFailWithError:[NSError errorWithDomain:@"Connection has failed" code:nil userInfo:nil]];
        }
        string = @"Go to class first";
    }
    self.searchDisplayController.searchBar.userInteractionEnabled = YES;
    [_tblView reloadData];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([(NSHTTPURLResponse *)response statusCode] == 404) {
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Distinctions cannot update. Please report this bug." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Report", nil];
        [alert show];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.refreshControl endRefreshing];
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Cannot fetch distinctions. %@",[error localizedDescription]]];
    distinctions = @[@"Nuts; the connection failed!"];
    string = error.localizedDescription;
    string=nil;
    [_tblView reloadData];
}

#pragma mark Alert
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        SimpleWebViewController *swvc = [[SimpleWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://campus.mbs.net/mbsnow/home/report.html"]];
        [self presentViewController:swvc animated:YES completion:nil];
    }
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) return YES;
    return (toInterfaceOrientation == UIDeviceOrientationPortrait) ? YES : NO;
}

@end