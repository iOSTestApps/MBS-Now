//
//  FormsViewController.m
//  MBS Now
//
//  Created by Graham Dyer on 3/20/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import "FormsViewController.h"
#import "FormsViewerViewController.h"
#import "SimpleWebViewController.h"
@implementation FormsViewController
@synthesize receivedData;

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 20)];
    footer.backgroundColor = [UIColor clearColor];
    tblView.tableFooterView = footer;

    _searchBar.showsCancelButton = NO;
    self.dataArray = @[@"Tap the refresh button", @"Wireless connection required"];
    tblView.userInteractionEnabled = NO;
    self.searchDisplayController.searchBar.userInteractionEnabled = NO;

    [tblView setContentInset:UIEdgeInsetsMake(20,0,0,0)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [tblView reloadData];
}

- (void)refresh {
    [SVProgressHUD showWithStatus:@"Updating"];
    NSURL *url = [NSURL URLWithString:@"http://campus.mbs.net/mbsnow/scripts/formTitles.txt"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection *connect = [NSURLConnection connectionWithRequest:request delegate:self];
    if (connect)
        [SVProgressHUD showWithStatus:@"Fetching forms"];
}

#pragma mark Table View
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"formsTapped"]) {
        // first time accessing a form
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"formsTapped"];
    } else {
        NSInteger q = [[NSUserDefaults standardUserDefaults] integerForKey:@"formsTapped"];
        q++;
        [[NSUserDefaults standardUserDefaults] setInteger:q forKey:@"formsTapped"];
    }

    // slashes (/) and spaces will not be in the URL
    NSString *foo = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    NSString *bar = [foo stringByReplacingOccurrencesOfString:@"/" withString:@""];
    urlString = [bar stringByReplacingOccurrencesOfString:@" " withString:@""];
    // domain name will be added in FormsViewerVC
    FormsViewerViewController *fvvc = [[FormsViewerViewController alloc] initWithStringForURL:urlString];
    fvvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:fvvc animated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *iden = @"ReuseCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:iden];
    cell.textLabel.text = (tableView == self.searchDisplayController.searchResultsTableView) ? self.searchResults[indexPath.row] : self.dataArray[indexPath.row];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (tableView == self.searchDisplayController.searchResultsTableView) ? self.searchResults.count : self.dataArray.count;
}

#pragma mark Connection
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [SVProgressHUD dismiss];
    NSString *fileText = [NSString stringWithContentsOfURL:connection.currentRequest.URL encoding:NSMacOSRomanStringEncoding error:nil];
    self.dataArray = [[NSArray alloc] initWithArray:[fileText componentsSeparatedByString:@"\n"]];
    self.dataArray = [self.dataArray sortedArrayUsingSelector: @selector(localizedCaseInsensitiveCompare:)];
    tblView.userInteractionEnabled = YES;
    self.searchDisplayController.searchBar.userInteractionEnabled = YES;
    [tblView reloadData];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([(NSHTTPURLResponse *)response statusCode] == 404) {
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dagnabbit!" message:@"Form titles can't update. Try again in a minute, then let us know." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Tell us", nil];
        [alert show];
    } else {
        [SVProgressHUD dismiss];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Cannot fetch forms. %@", [error localizedDescription]]];
    self.dataArray = @[@"Connection failed", @"Tap refresh to try again"];
    [tblView reloadData];
}

#pragma mark Actions
- (IBAction)refresh:(id)sender {
    [self refresh];
}
- (IBAction)howto:(id)sender {
    [SVProgressHUD showImage:[UIImage imageNamed:@"paper-clip@2x.png"] status:@"Visit campus.mbs.net/mbsnow, and upload your PDF"];
}

#pragma mark Search
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchText];

    self.searchResults = [self.dataArray filteredArrayUsingPredicate:resultPredicate];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        return YES;
    else {
        if(toInterfaceOrientation == UIDeviceOrientationPortrait) return YES;
        return NO;
    }
}

#pragma mark Alert
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        SimpleWebViewController *swvc = [[SimpleWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://campus.mbs.net/mbsnow/home/report.html"]];
        swvc.specifier = @"bug";
        [self presentViewController:swvc animated:YES completion:nil];
    }
}

@end