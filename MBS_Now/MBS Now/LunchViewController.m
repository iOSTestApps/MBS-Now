//
//  LunchViewController.m
//  MBS Now
//
//  Created by gdyer on 1/10/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

// THIS VC IS IPAD ONLY

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

    NSDateComponents *tomorrowComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];

    NSDate *compDate = [[NSCalendar currentCalendar] dateFromComponents:tomorrowComponents];

    // create a component to add one to today's components
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    offsetComponents.day = 1;
    NSDate *tomorrow = [[NSCalendar currentCalendar] dateByAddingComponents:offsetComponents toDate:compDate options:0];

    nextWeekDay = [formatter stringFromDate:tomorrow];

    // create a URL for tomorrow's menu
    nextLunchURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/gdyer/MBS-Now/raw/master/Resources/Lunch/%@.pdf", nextWeekDay]];

    NSString *datePart = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    days = @[[NSString stringWithFormat:@"%@ - %@", weekDay, datePart], nextWeekDay, @"Month"];
    lunchURL = [NSURL URLWithString:@"https://github.com/gdyer/MBS-Now/raw/master/Resources/Lunch/Month.pdf"];

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

    NSDateComponents *tomorrowComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];

    NSDate *compDate = [[NSCalendar currentCalendar] dateFromComponents:tomorrowComponents];

    // create a component to add one to today's components
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    offsetComponents.day = 1;
    NSDate *tomorrow = [[NSCalendar currentCalendar] dateByAddingComponents:offsetComponents toDate:compDate options:0];

    nextWeekDay = [formatter stringFromDate:tomorrow];

    NSString *datePart = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
    days = @[[NSString stringWithFormat:@"%@ — %@", weekDay, datePart], nextWeekDay, @"Month"];

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
    if (connection == notificationUpdates) {
        NSString *remotePack = [[NSString alloc] initWithData:notificationData encoding:NSUTF8StringEncoding];
        NSString *localPack = [[NSUserDefaults standardUserDefaults] objectForKey:@"notificationPack"];
        if (![localPack isEqualToString:remotePack]) {
            [self genFromPrefs:remotePack];
            [[NSUserDefaults standardUserDefaults] setObject:remotePack forKey:@"notificationPack"];
        }
    }
}
- (void)fireNotificationAtTime:(NSDate *)t withMessage:(NSString *)m {
    UILocalNotification *lcl = [[UILocalNotification alloc] init];
    lcl.fireDate = t;
    lcl.alertBody = m;
    lcl.soundName = UILocalNotificationDefaultSoundName;
    lcl.alertAction = @"View";
    lcl.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
    lcl.timeZone = [NSTimeZone timeZoneWithName:@"America/New_York"];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:lcl];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == notificationUpdates) [notificationData appendData:data];

}
- (void)generateNotifications:(NSString *)category andCalculateTime:(BOOL)c {
    NSString *hour = @"";
    if (c) {
        NSString *dressTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"dressTime"];
        if (dressTime) {
            // determine number of chars that represent time
            hour =  ([dressTime rangeOfString:@":"].location == NSNotFound) ? [NSString stringWithFormat:@"0%@ 00", [dressTime substringToIndex:1]] : [NSString stringWithFormat:@"0%@ %@", [dressTime substringToIndex:1], [dressTime substringWithRange:NSMakeRange(2, 2)]];
        }
    }
    
    for (NSString *f in [category componentsSeparatedByString:@"\n"]) {
        NSArray *s = [f componentsSeparatedByString:@" | "];
        if (s.count < 2) continue;
        NSDate *fireTime = [self dateFromNotificationString:[s[0] stringByReplacingOccurrencesOfString:@"$" withString:hour]];
        NSComparisonResult result = [[NSDate date] compare:fireTime];
        if (result == NSOrderedAscending || result == NSOrderedSame) {
            [self fireNotificationAtTime:fireTime withMessage:s[1]];
        }
    }
}

- (void)genFromPrefs:(NSString *)pack {
    NSLog(@"generating from prefs");
    NSArray *lists = [pack componentsSeparatedByString:@"^"];
    
    // bad part here is that any club reminders will be cancelled too
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    // 8 possibilities encapsulated here
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"abs"])
        [self generateNotifications:lists[1] andCalculateTime:NO];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"general"])
        [self generateNotifications:lists[2] andCalculateTime:NO];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"dressUps"])
        [self generateNotifications:lists[0] andCalculateTime:YES];
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
- (NSDate *)dateFromNotificationString:(NSString *)s {
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"MM/dd/yyyy HH mm"];
    [form setTimeZone:[NSTimeZone timeZoneWithName:@"America/New_York"]];
    return [form dateFromString:s];
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

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([(NSHTTPURLResponse *)response statusCode] == 404) {
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"404 Error" message:@"Menu not found. Please standby!" delegate:self cancelButtonTitle:@"Got it" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark Table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return days.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *iden = @"iden";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];

	if (cell == nil)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:iden];
    cell.textLabel.textColor = [UIColor darkGrayColor];
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

    if (connection)
        receivedData = [NSMutableData data];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"menusTapped"]) {
        // first time accessing a menu
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"menusTapped"];
    } else {
        NSInteger q = [[NSUserDefaults standardUserDefaults] integerForKey:@"menusTapped"];
        q++;
        [[NSUserDefaults standardUserDefaults] setInteger:q forKey:@"menusTapped"];
    }

    switch (indexPath.row) {
        case 0:
            [self loadFromTable:[NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/gdyer/MBS-Now/raw/master/Resources/Lunch/%@.pdf", weekDay]]];
            break;
        case 1:
            [self loadFromTable:[NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/gdyer/MBS-Now/raw/master/Resources/Lunch/%@.pdf", nextWeekDay]]];
            break;
        case 2:
            [self loadFromTable:[NSURL URLWithString:@"https://github.com/gdyer/MBS-Now/raw/master/Resources/Lunch/Month.pdf"]]; //iPad only
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
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) return YES;
    return (toInterfaceOrientation == UIDeviceOrientationPortrait) ? YES : NO;
}

@end
