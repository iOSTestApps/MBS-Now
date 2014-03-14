//
//  ClubsViewController.m
//  MBS Now
//
//  Created by Graham Dyer on 10/31/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import "ClubsViewController.h"
#import "SimpleWebViewController.h"
#import "DetailViewController.h"

@implementation ClubsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.csv = [NSMutableArray arrayWithObjects:[NSArray arrayWithObjects:@"Please tap refresh", @"Please tap refresh", @"...? Data must be updated", nil], nil];
    self.descriptions = [NSArray arrayWithObjects:@"Please refresh meetings", @"Return to previous screen", nil];
    self.tblView.userInteractionEnabled = NO;
    firstTime = YES;

    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 20)];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;

    [self.tblView setContentInset:UIEdgeInsetsMake(20,0,0,0)];

    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    else self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    if (firstTime == YES) {
        [SVProgressHUD showImage:[UIImage imageNamed:@"finger-touch.png"] status:@"Please tap refresh"];
        firstTime = NO;
    }
}

- (void)moveAlongWithCreation {
    SimpleWebViewController *swvc = [[SimpleWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://gdyer.de/meeting.html"]];
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
    self.tblView.userInteractionEnabled = YES;

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
    [self.tblView reloadData];

    [[NSUserDefaults standardUserDefaults] setObject:self.csv forKey:@"meetingLog"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Cannot fetch meetings. %@",[error localizedDescription]]];
    self.csv = [NSMutableArray arrayWithObjects:[NSArray arrayWithObjects:@"Connection failed", @"Connection failed", @"...? Tap refresh to try again", nil], nil];
    [self.tblView reloadData];
}

- (void)refreshData {
    [SVProgressHUD showWithStatus:@"Fetching meetings"];
    NSURL *url = [NSURL URLWithString:@"https://docs.google.com/spreadsheet/pub?key=0Ar9jhHUssWrpdGJSYTFjWWhDWndKQW0yckluTU5PX1E&output=csv"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (connection) {
        [SVProgressHUD showWithStatus:@"Fetching meetings"];
    }
}

#pragma mark Actions
- (IBAction)pushedRefresh:(id)sender {
    [self refreshData];
}

- (IBAction)pushedAdd:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"cred"] == YES) {
        [self moveAlongWithCreation];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"For Security" message:@"What's our school's nickname?" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Go", nil];
        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        [alert textFieldAtIndex:0].placeholder = @"Password";
        [alert textFieldAtIndex:0].returnKeyType = UIReturnKeyDone;
        alert.tag = 2;
        [alert show];
    }
}

#pragma mark UIAlertView delegate methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1 && alertView.tag == 2) {
        if ([[alertView textFieldAtIndex:0].text isEqualToString:@"mobeard"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You'll never have to do that again. You can also access database credentials now." delegate:self cancelButtonTitle:@"Yay!" otherButtonTitles:nil, nil];
            [alert show];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"cred"];
            [self moveAlongWithCreation];
        } else {
            [SVProgressHUD showErrorWithStatus:@"That wasn't correct; please try again."];
        }
    }
    else if (buttonIndex == 1 && alertView.tag == 1) {
        SimpleWebViewController *swvc = [[SimpleWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://gdyer.de/report.html"]];
        [self presentViewController:swvc animated:YES completion:nil];
    }
}

#pragma mark Table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *simpleTableIdentifier = @"ReuseCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }

    cell.textLabel.text = [[self.csv objectAtIndex:indexPath.row] objectAtIndex:1];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Meeting on %@", [[self.csv objectAtIndex:indexPath.row] objectAtIndex:2]];

    // show the arrow at the end of a cell
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"showDetail" sender:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.csv count];
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
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        if(toInterfaceOrientation == UIDeviceOrientationPortrait) return YES;
        return NO;
    }
}

@end
