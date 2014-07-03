//
//  EAViewController.m
//  MBS Now
//
//  Created by gdyer on 9/23/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import "EAViewController.h"
#import "SimpleWebViewController.h"
@implementation EAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    distinctions = @[@"Tap the download button"];
    string = nil;

    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 20)];
    footer.backgroundColor = [UIColor clearColor];
    self.tblView.tableFooterView = footer;
    self.searchDisplayController.searchBar.userInteractionEnabled = NO;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"download-7-active.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(download)];
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

#pragma mark Actions
- (void)download {
    [SVProgressHUD showWithStatus:@"Generating distinctions"];
    NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/gdyer/MBS-Now/master/Resources/Data/distinctions.txt"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    firstConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    if (firstConnection) [SVProgressHUD showWithStatus:@"Generating distinctions"];
}

#pragma mark Connection
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
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
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Cannot fetch distinctions. %@",[error localizedDescription]]];
    distinctions = @[@"Connection failed"];
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

@end