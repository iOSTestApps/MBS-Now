//
//  ClubsViewController.m
//  MBS Now
//
//  Created by gdyer on 10/31/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import "ClubsViewController.h"
#import "SimpleWebViewController.h"
#import "DetailViewController.h"

@implementation ClubsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.csv = [NSMutableArray arrayWithObject:@[@"Hang tight... updating", @"You can pull to refresh", @"...? Fetching"]];
    self.descriptions = @[@"Please refresh meetings", @"Return to previous screen"];
    self.tableView.userInteractionEnabled = NO;

    [self refreshData];

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Fetching... just for you ;)"];
    [refresh addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [self.tableView addSubview:self.refreshControl];

    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 20)];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;

    [self.tableView setContentInset:UIEdgeInsetsMake(20,0,0,0)];

    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)moveAlongWithCreation {
    SimpleWebViewController *swvc = [[SimpleWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://campus.mbs.net/mbsnow/home/meeting.html"]];
    swvc.specifier = @"rem";
    [self presentViewController:swvc animated:YES completion:nil];
}

#pragma mark Connection
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([(NSHTTPURLResponse *)response statusCode] == 404) {
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"404 Error" message:@"Meetings cannot update. If this persists, please report a bug." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Report", nil];
        alert.tag = 1;
        [alert show];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [SVProgressHUD dismiss];
    [self.refreshControl endRefreshing];
    self.tableView.userInteractionEnabled = YES;

    NSString *separation = @"\n";
    NSString *fileText = [NSString stringWithContentsOfURL:connection.currentRequest.URL encoding:NSMacOSRomanStringEncoding error:nil];
    NSArray *raw = [fileText componentsSeparatedByString:separation];
    self.csv = [[NSMutableArray alloc] init];
    for (NSString *foo in raw) {
        NSArray *dummy = [foo componentsSeparatedByString:@","];
        [self.csv addObject:dummy];
    }

    self.descriptions = [self.csv objectAtIndex:0];
    [self.csv removeObjectAtIndex:0];
    [self.tableView reloadData];

    [[NSUserDefaults standardUserDefaults] setObject:self.csv forKey:@"meetingLog"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.refreshControl endRefreshing];
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Cannot fetch meetings. %@",[error localizedDescription]]];
    self.csv = [NSMutableArray arrayWithObjects:[NSArray arrayWithObjects:@"Connection failed", @"Connection failed", @"...? Tap refresh to try again", nil], nil];
    [self.tableView reloadData];
}

- (void)refreshData {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM d, h:mm:ss a";
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated %@", [formatter stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];

    NSURL *url = [NSURL URLWithString:@"https://docs.google.com/spreadsheet/pub?key=0Ar9jhHUssWrpdGJSYTFjWWhDWndKQW0yckluTU5PX1E&output=csv"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection && !self.refreshControl.refreshing)
        [SVProgressHUD showWithStatus:@"Updating..."];
}

#pragma mark Actions
- (IBAction)pushedRefresh:(id)sender {
    [self refreshData];
}

- (IBAction)pushedAdd:(id)sender {
    [self moveAlongWithCreation];
}

#pragma mark UIAlertView delegate methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1 && alertView.tag == 1) {
        SimpleWebViewController *swvc = [[SimpleWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://campus.mbs.net/mbsnow/home/meeting.html"]];
        [self presentViewController:swvc animated:YES completion:nil];
    }
}

#pragma mark Table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *iden = @"ReuseCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];

    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:iden];
    
    cell.textLabel.text = [[self.csv objectAtIndex:indexPath.row] objectAtIndex:1];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Meeting on %@", [[self.csv objectAtIndex:indexPath.row] objectAtIndex:2]];

    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.csv.count;
}

#pragma mark Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSMutableArray *mod = [NSMutableArray arrayWithArray:self.descriptions];
        [mod removeObjectAtIndex:0];
        [mod insertObject:@"Creation date" atIndex:0];
        [segue.destinationViewController setDescriptions:mod];

        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [segue.destinationViewController setDetails:[self.csv objectAtIndex:indexPath.row]];
    }
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) return YES;
    return (toInterfaceOrientation == UIDeviceOrientationPortrait) ? YES : NO;
}

@end