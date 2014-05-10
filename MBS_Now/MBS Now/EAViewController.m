//
//  EAViewController.m
//  MBS Now
//
//  Created by Graham Dyer on 9/23/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import "EAViewController.h"
#import "SimpleWebViewController.h"
@implementation EAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __searchBar.showsCancelButton = NO;
    distinctions = [NSArray arrayWithObjects:@"Tap the download button", nil];
    string = nil;

    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 20)];
    footer.backgroundColor = [UIColor clearColor];
    self.tblView.tableFooterView = footer;
}

#pragma mark Table View
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"ReuseCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }

    cell.detailTextLabel.text = string;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [searchResults objectAtIndex:indexPath.row];
    } else
        cell.textLabel.text = [distinctions objectAtIndex:indexPath.row];
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return searchResults.count;
    } else {
        return distinctions.count;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return  (string) ? @"Lunch first if class not here" : nil;
}

#pragma mark Actions
- (IBAction)pushedDownload:(id)sender {
    [SVProgressHUD showWithStatus:@"Generating distinctions"];
    NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/gdyer/MBS-Now/master/Resources/Data/distinctions.txt"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    firstConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (firstConnection) {
        [SVProgressHUD showWithStatus:@"Generating distinctions"];
    }
}

- (IBAction)done:(id)sender {
    [SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Connection
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *separation = @"\n";
    if (connection == firstConnection) {
        [SVProgressHUD showImage:[UIImage imageNamed:@"info-7-active.png"] status:@"Go to lunch first if your class is NOT here"];
        NSString *fileText = [NSString stringWithContentsOfURL:connection.currentRequest.URL encoding:NSMacOSRomanStringEncoding error:nil];
        distinctions = [[NSArray alloc] initWithArray:[fileText componentsSeparatedByString:separation]];
        if (distinctions.count == 0) {
            [self connection:connection didFailWithError:[NSError errorWithDomain:@"Connection has failed" code:nil userInfo:nil]];
        }
        string = @"Go to class first";
    } else [SVProgressHUD dismiss];
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
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Cannot fetch distinctions. %@",[error localizedDescription]]];
    distinctions = [NSArray arrayWithObject:@"Connection failed"];
    string = error.localizedDescription;
    string=nil;
    [_tblView reloadData];
}

#pragma mark Search
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF contains[cd] %@",
                                    searchText];

    searchResults = [distinctions filteredArrayUsingPredicate:resultPredicate];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {

    [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

#pragma mark Alert
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        SimpleWebViewController *swvc = [[SimpleWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://campus.mbs.net/mbsnow/home/report.html"]];
        [self presentViewController:swvc animated:YES completion:nil];
    }
}


@end
