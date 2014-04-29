//
//  LunchViewController.m
//  MBS Now
//
//  Created by Graham Dyer on 1/10/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import "LunchViewController.h"

@implementation LunchViewController
@synthesize _webView, receivedData;

- (void)viewDidLoad {

    [super viewDidLoad];

    [_webView setDelegate:self];
    // get today's name
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE"];
    weekDay = [formatter stringFromDate:[NSDate date]];

    NSDateComponents *tomorrowComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];

    NSDate *compDate = [[NSCalendar currentCalendar] dateFromComponents:tomorrowComponents];

    // create a component to add one to today's components
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    offsetComponents.day = 1;
    NSDate *tomorrow = [[NSCalendar currentCalendar] dateByAddingComponents:offsetComponents toDate:compDate options:0];

    nextWeekDay = [formatter stringFromDate:tomorrow];

    // create a URL for tomorrow's menu
    nextLunchURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://campus.mbs.net/mbsnow/home/forms/lunch/%@.pdf", nextWeekDay]];

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        NSString *datePart = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
        days = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@ - %@", weekDay, datePart], nextWeekDay, @"Month", nil];
        // Lunch.pdf is the monthly calendar
        lunchURL = [NSURL URLWithString:@"http://campus.mbs.net/mbsnow/home/forms/lunch/Lunch.pdf"];
    } else {
        // iPhone
        days = [NSArray arrayWithObjects:weekDay, nextWeekDay, nil];
        // create a URL for today's menu
        lunchURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://campus.mbs.net/mbsnow/home/forms/lunch/%@.pdf", weekDay]];
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:lunchURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:25];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE];

    if (connection) receivedData = [NSMutableData data];
    
    [_webView loadRequest:request];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    [_webView stopLoading];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self pushedRefresh:self];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autoCheck"] == 0) {
        NSURL *myURL = [NSURL URLWithString:@"https://docs.google.com/spreadsheet/pub?key=0Ar9jhHUssWrpdGJSYTFjWWhDWndKQW0yckluTU5PX1E&output=csv"];
        NSURLRequest *request = [NSURLRequest requestWithURL:myURL
                                                 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                             timeoutInterval:20];
        meetingsConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

#pragma mark Actions
- (IBAction)pushedStop:(id)sender {
    [SVProgressHUD dismiss];
    [_webView stopLoading];
}

- (IBAction)pushedRefresh:(id)sender {
    [_webView reload];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE"];
    weekDay = [formatter stringFromDate:[NSDate date]];

    NSDateComponents *tomorrowComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];

    NSDate *compDate = [[NSCalendar currentCalendar] dateFromComponents:tomorrowComponents];

    // create a component to add one to today's components
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    offsetComponents.day = 1;
    NSDate *tomorrow = [[NSCalendar currentCalendar] dateByAddingComponents:offsetComponents toDate:compDate options:0];

    nextWeekDay = [formatter stringFromDate:tomorrow];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        NSString *datePart = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
        days = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@ — %@", weekDay, datePart], nextWeekDay, @"Month", nil];
    } else {
        // iPhone
        days = [NSArray arrayWithObjects:weekDay, nextWeekDay, nil];
    }

    [tblView reloadData];
}

#pragma mark Connection
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == meetingsConnection) {
        NSString *separation = @"\n";
        NSString *fileText = [NSString stringWithContentsOfURL:connection.currentRequest.URL encoding:NSMacOSRomanStringEncoding error:nil];
        NSArray *raw = [fileText componentsSeparatedByString:separation];
        NSMutableArray *csv = [[NSMutableArray alloc] init];
        for (NSString *foo in raw) {
            NSArray *dummy = [foo componentsSeparatedByString:@","];
            [csv addObject:dummy];
        }
        [csv removeObjectAtIndex:0];

        NSArray *clubNames = [[NSUserDefaults standardUserDefaults] objectForKey:@"meetingLog"];
        if ([self compareArrays:csv and:clubNames] == NO) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Meetings have changed" message:@"A meeting has been modified or added since your last refresh. Tap the 'Clubs' tab to learn more." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
            [alert show];
            [[NSUserDefaults standardUserDefaults] setObject:csv forKey:@"meetingLog"];
        }
    }
}

- (BOOL)compareArrays:(NSArray *)array1 and:(NSArray *)array2 {
    for (NSString *name in array1) {
        if (![array2 containsObject:name]) {
            return NO;
            break;
        }
    }

    for (NSString *name in array2) {
        if (![array1 containsObject:name]) {
            return NO;
            break;
        }
    }

    return YES; // they're the same
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [SVProgressHUD showWithStatus:@"Loading"];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [SVProgressHUD dismiss];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [SVProgressHUD dismiss];
    [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([(NSHTTPURLResponse *)response statusCode] == 404) {
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"404 Error" message:@"Menu not found. Please standby" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark Table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	return [days count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"MyIdentifier";
	
	// Try to retrieve from the table view a now-unused cell with the given identifier.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
	// If no cell is available, create a new one using the given identifier.
	if (cell == nil) {
		// Use the default cell style.
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
	}
    cell.textLabel.textColor = [UIColor darkGrayColor];
	// Set up the cell.
	NSString *daysCell = [days objectAtIndex:indexPath.row];
	cell.textLabel.text = daysCell;
    
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath;
}

- (void)loadFromTable:(NSURL *)urlToLoad {

    NSURLRequest *requestFromTable = [NSURLRequest requestWithURL:urlToLoad];
    [_webView loadRequest:requestFromTable];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:requestFromTable delegate:self startImmediately:TRUE];

    if (connection) {
        receivedData = [NSMutableData data];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"menusTapped"]) {
        // first time accessing a form
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"menusTapped"];
    } else {
        NSInteger q = [[NSUserDefaults standardUserDefaults] integerForKey:@"menusTapped"];
        q++;
        [[NSUserDefaults standardUserDefaults] setInteger:q forKey:@"menusTapped"];
    }

    switch (indexPath.row) {
        case 0:
            [self loadFromTable:[NSURL URLWithString:[NSString stringWithFormat:@"http://campus.mbs.net/mbsnow/home/forms/lunch/%@.pdf", weekDay]]];
            break;
        case 1:
            [self loadFromTable:[NSURL URLWithString:[NSString stringWithFormat:@"http://campus.mbs.net/mbsnow/home/forms/lunch/%@.pdf", nextWeekDay]]];
            break;
        case 2:
            [self loadFromTable:[NSURL URLWithString:@"http://campus.mbs.net/mbsnow/home/forms/lunch/Lunch.pdf"]]; // Lunch.pdf is the monthly calendar (iPad only)
            break;
        default:
            break;
    }
}

- (void)tableView: (UITableView*)tableView willDisplayCell: (UITableViewCell*)cell forRowAtIndexPath: (NSIndexPath*)indexPath {
    cell.backgroundColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor whiteColor];
}

#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        if(toInterfaceOrientation == UIDeviceOrientationPortrait) return YES;
        return NO;
    }
}

@end
