//
//  ClubsViewController.m
//  MBS Now
//
//  Created by gdyer on 10/31/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "ClubsViewController.h"
#import "AddItemViewController.h"
#import "DetailViewController.h"
@implementation ClubsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.csv = [NSMutableArray arrayWithObject:@[@"Hang tight... updating", @"Hang tight... updating!", @"...? Fetching!"]];
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
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"book-7-active.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(toggleHistory)];
    else
        self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"book-7-active.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(toggleHistory)], [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshData)]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(moveAlongWithCreation)];
}

- (void)toggleHistory {
    _showHistory=!_showHistory;
    UIColor *c = (_showHistory) ? [UIColor grayColor] : nil;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) self.navigationItem.leftBarButtonItem.tintColor = c;
    else [self.navigationItem.leftBarButtonItems[0] setTintColor:c];
    [self refreshData];
}

- (void)moveAlongWithCreation {
    [self performSegueWithIdentifier:@"add" sender:self];
}

#pragma mark Some useful date stuff
- (NSDate *)dateByDistanceFromToday:(NSInteger)d {
    NSDateComponents *tomorrowComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSDate *compDate = [[NSCalendar currentCalendar] dateFromComponents:tomorrowComponents];
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    offsetComponents.day = d;
    return [[NSCalendar currentCalendar] dateByAddingComponents:offsetComponents toDate:compDate options:0];
}

- (NSDate *)dateFromEventString:(NSString *)s {
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"M/d/y"];
    return [form dateFromString:s];
}

- (BOOL)thisDateIsInTheFutureOrToday:(NSDate *)one {
    if ([one compare:[self dateWithoutTime:[NSDate date]]] != NSOrderedAscending) return 1;
    else return 0;
}

- (NSDate *)dateWithoutTime:(NSDate *)i {
    if (i == nil )
        i = [NSDate date];
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:i];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
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
    self.tableView.userInteractionEnabled = YES;

    NSString *separation = @"\n";
    NSString *fileText = [NSString stringWithContentsOfURL:connection.currentRequest.URL encoding:NSMacOSRomanStringEncoding error:nil];
    NSArray *raw = [fileText componentsSeparatedByString:separation];
    self.csv = [NSMutableArray array];
    NSMutableArray *toSave = [NSMutableArray array];
    for (NSString *foo in raw) {
        NSArray *dummy = [foo componentsSeparatedByString:@","];
        [toSave addObject:dummy];
        if ([self thisDateIsInTheFutureOrToday:[self dateFromEventString:dummy[2]]] || _showHistory)
            [self.csv addObject:dummy];
    }
    
    self.descriptions = self.csv[0];
    [self.csv removeObjectAtIndex:0];
    [toSave removeObjectAtIndex:0];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];

    [[NSUserDefaults standardUserDefaults] setObject:toSave forKey:@"meetingLog"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [SVProgressHUD dismiss];
    [self.refreshControl endRefreshing];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.refreshControl endRefreshing];
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Cannot fetch meetings. %@",[error localizedDescription]]];
    self.csv = [NSMutableArray arrayWithObjects:@[@"Connection failed", @"Connection failed", @"...? Tap refresh to try again"], nil];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark UIAlertView delegate methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1 && alertView.tag == 1) {
        [self moveAlongWithCreation];
    }
}

#pragma mark Table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *iden = @"ReuseCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:iden];
    
    BOOL future = [self thisDateIsInTheFutureOrToday:[self dateFromEventString:self.csv[indexPath.row][2]]];
    cell.textLabel.text = self.csv[indexPath.row][1];
    if (_showHistory)
        cell.textLabel.textColor = (future) ? [UIColor blackColor] : [UIColor lightGrayColor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ on %@", (future) ? @"Meeting" : @"Met", [[self.csv objectAtIndex:indexPath.row] objectAtIndex:2]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _csv.count;
}

#pragma mark Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"add"]) {
        [segue.destinationViewController setNameInit:@"club event"];
        [segue.destinationViewController setAddressInit:@"https://mbsdev.github.io/meeting.html"];
    }

    else if ([segue.identifier isEqualToString:@"showDetail"]) {
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"meetingsViewed"]) {
            // first time viewing a meeting
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"meetingsViewed"];
        } else {
            NSInteger q = [[NSUserDefaults standardUserDefaults] integerForKey:@"meetingsViewed"];
            q++;
            [[NSUserDefaults standardUserDefaults] setInteger:q forKey:@"meetingsViewed"];
        }
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