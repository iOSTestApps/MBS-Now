//
//  Today.m
//  MBS Now
//
//  Created by Graham Dyer on 5/18/14.
//  Copyright (c) 2014 MBS Now. All rights reserved.
//

#import "Today.h"
#import "FormsViewerViewController.h"
#import "SVWebViewController.h"
#import "StandardTableViewCell.h"
#import "TodayCellTableViewCell.h"
@implementation Today

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 20)];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
    [self.tableView setContentInset:UIEdgeInsetsMake(20,0,0,0)];

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating... just for you."];
    [refresh addTarget:self action:@selector(update) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(update)];
}

- (void)noSavedGrade {
    UIAlertView *d = [[UIAlertView alloc] initWithTitle:@"What grade are you in?" message:@"Faculty memebers: enter any grade within your division (MS or US)." delegate:self cancelButtonTitle:@"Go" otherButtonTitles:nil, nil];
    d.alertViewStyle = UIAlertViewStylePlainTextInput;
    [d textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [d textFieldAtIndex:0].placeholder = @"From 6 to 12";
    [d show];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    NSString *savedDivision = [[NSUserDefaults standardUserDefaults] objectForKey:@"division"];
    if (!savedDivision) {
        [self noSavedGrade];
        return;
    }

    [self update];
}

- (void)update {
    _feeds = [NSMutableDictionary dictionary];

    NSString *savedDivision = [[NSUserDefaults standardUserDefaults] objectForKey:@"division"];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM d, h:mm:ss a";
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated %@", [formatter stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];

    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"y-M-d"];

    NSLog(@"%@", [form stringFromDate:[NSDate date]]);
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
//    NSInteger hour = [components hour];
//
//    if (hour < 16) {
    NSURLRequest *schedule = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://campus.mbs.net/mbs/widget/dayPeriodsForMBSNow.php?day=%@&div=%@", [form stringFromDate:[NSDate date]], savedDivision]]];
    NSLog(@"%@", schedule);
    scheduleData = [NSMutableData data];
    scheduleConnection = [[NSURLConnection alloc] initWithRequest:schedule delegate:self startImmediately:YES];

    NSURLRequest *rss = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.mbs.net/data/calendar/rsscache/calendar_4486.rss"]];
    rssData = [NSMutableData data];
    rssConnection = [[NSURLConnection alloc] initWithRequest:rss delegate:self startImmediately:YES];

    NSURLRequest *rssNews = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.mbs.net/rss.cfm?news=0"]];
    rssNewsData = [NSMutableData data];
    rssNewsConnection = [[NSURLConnection alloc] initWithRequest:rssNews delegate:self startImmediately:YES];

    NSURLRequest *docRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://docs.google.com/spreadsheet/pub?key=0Ar9jhHUssWrpdGJSYTFjWWhDWndKQW0yckluTU5PX1E&output=csv"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
    meetingsData = [NSMutableData data];
    meetingsConnection = [[NSURLConnection alloc] initWithRequest:docRequest delegate:self];

    NSURLRequest *version = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/gdyer/MBS-Now/master/Resources/app-store-version.txt"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    versionData = [NSMutableData data];
    versionConnection = [[NSURLConnection alloc] initWithRequest:version delegate:self startImmediately:YES];

    NSURLRequest *special = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://campus.mbs.net/mbsnow/home/forms/ACTdates.pdf"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    specialData = [NSMutableData data];
    specialConnection = [[NSURLConnection alloc] initWithRequest:special delegate:self startImmediately:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    [versionConnection cancel];
    [meetingsConnection cancel];
    [rssConnection cancel];
    [specialConnection cancel];
    [rssNewsConnection cancel];
}

- (void)saveFeedsWithObject:(id)object andKey:(NSString *)key{
    NSMutableArray *cur = ([_feeds[key] length] > 0) ? _feeds[key] : [NSMutableArray array];
    [cur addObject:object];
    NSLog(@"%@, %@", cur, key);
    [_feeds setObject:cur forKey:key];
}

#pragma mark Connection
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == rssConnection) [rssData appendData:data];
    else if (connection == meetingsConnection) [meetingsData appendData:data];
    else if (connection == versionConnection) [versionData appendData:data];
    else if (connection == rssNewsConnection) [rssNewsData appendData:data];
    else if (connection == scheduleConnection) [scheduleData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == specialConnection && [(NSHTTPURLResponse *)response statusCode] != 404) {
        [self saveFeedsWithObject:@"A special schedule is available." andKey:@"strings"];
        [self saveFeedsWithObject:[UIImage imageNamed:@"star-7.png"] andKey:@"images"];
        [self saveFeedsWithObject:[NSNumber numberWithBool:YES] andKey:@"class"];
        [self.tableView reloadData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.refreshControl endRefreshing];
    _feeds = [NSMutableDictionary dictionaryWithObjects:@[@"Oops! The connection failed.", [UIImage imageNamed:@"caution-7.png"], @"class"] forKeys:@[@"strings", @"images", @"class"]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == meetingsConnection) {
        NSString *separation = @"\n";
        NSString *fileText = [[NSString alloc] initWithData:meetingsData encoding:NSUTF8StringEncoding];
        NSArray *raw = [fileText componentsSeparatedByString:separation];
        NSMutableArray *csv = [NSMutableArray array];
        for (NSString *foo in raw) {
            NSArray *dummy = [foo componentsSeparatedByString:@","];
            [csv addObject:dummy];
        }
        [csv removeObjectAtIndex:0];
    }

    if (connection == scheduleConnection) {
        NSString *schedule = [[NSString alloc] initWithData:scheduleData encoding:NSUTF8StringEncoding];
        if (schedule) {
            NSString *sched = [NSString stringWithFormat:@"Today: %@", [[[schedule stringByReplacingOccurrencesOfString:@"|" withString:@", "] stringByReplacingOccurrencesOfString:@"Advisors, " withString:@""] stringByReplacingOccurrencesOfString:@"Advisory, " withString:@""]];
            [self saveFeedsWithObject:sched andKey:@"strings"];
            [self saveFeedsWithObject:[UIImage imageNamed:@"clock-7.png"] andKey:@"images"];
            [self saveFeedsWithObject:[NSNumber numberWithBool:YES] andKey:@"class"];
        }
    }

    [self.refreshControl endRefreshing];
}

#pragma mark Table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_feeds[@"strings"] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *iden = @"standard";
    StandardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
    if (cell == nil)
        cell = [[StandardTableViewCell alloc] initWithStyle:nil reuseIdentifier:iden];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ([_feeds[@"class"][indexPath.row] boolValue]) ? 46.0f : 56.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[tableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString:@"standard"]) {
        NSString *url = [(StandardTableViewCell *)([tableView cellForRowAtIndexPath:indexPath]) url];
        if (url) {
            FormsViewerViewController *vc = [[FormsViewerViewController alloc] initWithStringForURL:url];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSMutableArray *poss = [NSMutableArray array];
    for (int x = 6; x < 13; x++)
        [poss addObject:[NSString stringWithFormat:@"%d", x]];
    NSString *grade = [alertView textFieldAtIndex:0].text;
    if ([poss containsObject:grade]) {
        [[NSUserDefaults standardUserDefaults] setObject:((grade.integerValue < 9) ? @"MS" : @"US") forKey:@"division"];
        [SVProgressHUD showSuccessWithStatus:@"Thanks. That's editable in Settings."];
        [self update];
        return;
    }

    [self noSavedGrade];
}

@end