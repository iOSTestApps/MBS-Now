//
//  Today.m
//  MBS Now
//
//  Created by gdyer on 5/18/14.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import "Today.h"
#import "FormsViewerViewController.h"
#import "HomeViewController.h"
#import "SVWebViewController.h"
#import "StandardTableViewCell.h"
#import "TodayCellTableViewCell.h"
#import "ScheduleTableViewCell.h"
#import "UIImageView+WebCache.h"

#define CONNECTION_FAILTURE 2
#define CONNECTION_LOADING 1
#define CONNECTION_SUCCESS 0
#define UPDATE_URL @"https://itunes.apple.com/us/app/mbs-now/id617180145?mt=8"

@implementation Today

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 20)];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
    [self.tableView setContentInset:UIEdgeInsetsMake(20,0,0,0)];

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating... just for you"];
    [refresh addTarget:self action:@selector(update) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(update)];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    [versionConnection cancel];
    [meetingsConnection cancel];
    //    [rssConnection cancel];
    [specialConnection cancel];
    //    [rssNewsConnection cancel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    NSString *savedDivision = [[NSUserDefaults standardUserDefaults] objectForKey:@"division"];
    if (!savedDivision) {
        [self noSavedGrade:@"Enter between 6 and 12"];
        return;
    }

    [self update];
}

- (void)noSavedGrade:(NSString *)append {
    UIAlertView *d = [[UIAlertView alloc] initWithTitle:@"What grade are you in?" message:@"Faculty memebers: enter any grade within your division (MS or US)." delegate:self cancelButtonTitle:@"Go" otherButtonTitles:nil, nil];
    d.tag = 2;
    d.alertViewStyle = UIAlertViewStylePlainTextInput;
    [d textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [d textFieldAtIndex:0].placeholder = append;
    [d show];
}

- (void)addTextScheduleFeed:(NSString *)raw withDayIndex:(BOOL)i {
    NSString *sched = [NSString stringWithFormat:@"%@: %@", ((i == 0) ? @"Today" : @"Tomorrow"), [[[raw stringByReplacingOccurrencesOfString:@"|" withString:@", "] stringByReplacingOccurrencesOfString:@"Advisors, " withString:@""] stringByReplacingOccurrencesOfString:@"Advisory, " withString:@""]];
    [self saveFeedsWithObject:sched andKey:@"strings"];
    [self saveFeedsWithObject:[UIImage imageNamed:@"clock-7.png"] andKey:@"images"];
    [self saveFeedsWithObject:[TodayCellTableViewCell class] andKey:@"class"];
    [self saveFeedsWithObject:@"" andKey:@"urls"];
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

- (void)update {
    _ret = CONNECTION_LOADING;
    [SVProgressHUD showWithStatus:@"Gathering feeds..."];
    [self.tableView reloadData];

    _feeds = [NSMutableDictionary dictionary];

    HomeViewController *hvc = [[HomeViewController alloc] init];
    NSArray *f = [hvc countdown];
    int days = [f[2] intValue];
    if ([f[1] isEqualToString:@"starts"] || days < 15) {
        // only show countdown here if it's the summer or there are 15 days left in school
        NSString *message = [NSString stringWithFormat:@"School %@ in %d %@.", f[1], days, ((days == 1) ? @"day" : @"days")];
        [self saveFeedsWithObject:message andKey:@"strings"];
        [self saveFeedsWithObject:f[0] andKey:@"images"];
        [self saveFeedsWithObject:[StandardTableViewCell class] andKey:@"class"];
        [self saveFeedsWithObject:@"" andKey:@"urls"];
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM d, h:mm:ss a";
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated %@", [formatter stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];

    // start connection for TEXT-BASED today schedule
    //    NSString *savedDivision = [[NSUserDefaults standardUserDefaults] objectForKey:@"division"];
    //    NSURLRequest *schedule = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://campus.mbs.net/mbs/widget/dayPeriodsForMBSNow.php?day=%@&div=%@", [form stringFromDate:[NSDate date]], savedDivision]]];
    NSURLRequest *schedule = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://campus.mbs.net/mbs/widget/dayPeriodsForMBSNow.php?day=2014-1-16&div=us"]];
    scheduleData = [NSMutableData data];
    scheduleConnection = [[NSURLConnection alloc] initWithRequest:schedule delegate:self startImmediately:YES];

    // start connection for IMAGE-BASED today schedule
    NSURLRequest *todaySchedule = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://campus.mbs.net/mbs/widget/graphicURLForMBSNow.php?day=%@", [self stringFromFormatterDate:[NSDate date]]]]];
    todayScheduleData = [NSMutableData data];
    todayScheduleConnection = [[NSURLConnection alloc] initWithRequest:todaySchedule delegate:self startImmediately:YES];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    NSInteger hour = [components hour];
    if (hour > 16) {
        // start connection for TEXT-BASED tomorrow schedule only if it's AFTER 8 PM
//        NSURLRequest *tmrwText = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://campus.mbs.net/mbs/widget/dayPeriodsForMBSNow.php?day=%@&div=us", [self stringFromFormatterDate:[self tomorrow]]]]];
        NSURLRequest *tmrwText = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://campus.mbs.net/mbs/widget/dayPeriodsForMBSNow.php?day=2014-1-17&div=us"]];
        tomorrowTextData = [NSMutableData data];
        tomorrowTextConnection = [[NSURLConnection alloc] initWithRequest:tmrwText delegate:self startImmediately:YES];
    }
//    NSURLRequest *rss = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.mbs.net/data/calendar/rsscache/calendar_4486.rss"]];
//    rssData = [NSMutableData data];
//    rssConnection = [[NSURLConnection alloc] initWithRequest:rss delegate:self startImmediately:YES];

//    NSURLRequest *rssNews = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.mbs.net/rss.cfm?news=0"]];
//    rssNewsData = [NSMutableData data];
//    rssNewsConnection = [[NSURLConnection alloc] initWithRequest:rssNews delegate:self startImmediately:YES];

    NSURLRequest *docRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://docs.google.com/spreadsheet/pub?key=0Ar9jhHUssWrpdGJSYTFjWWhDWndKQW0yckluTU5PX1E&output=csv"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
    meetingsData = [NSMutableData data];
    meetingsConnection = [[NSURLConnection alloc] initWithRequest:docRequest delegate:self];

    NSURLRequest *version = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/gdyer/MBS-Now/master/Resources/app-store-version.txt"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    versionData = [NSMutableData data];
    versionConnection = [[NSURLConnection alloc] initWithRequest:version delegate:self startImmediately:YES];

    NSURLRequest *special = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://campus.mbs.net/mbsnow/home/forms/Special.pdf"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    specialData = [NSMutableData data];
    specialConnection = [[NSURLConnection alloc] initWithRequest:special delegate:self startImmediately:YES];
}

- (NSString *)stringFromFormatterDate:(NSDate *)d {
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"y-M-d"];
    return [form stringFromDate:d];
}

- (NSDate *)tomorrow {
    NSDateComponents *tomorrowComponents = [[NSCalendar currentCalendar]
                                            components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit
                                            fromDate:[NSDate date]];

    NSDate *compDate = [[NSCalendar currentCalendar] dateFromComponents:tomorrowComponents];

    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    offsetComponents.day = 1;
    return [[NSCalendar currentCalendar] dateByAddingComponents:offsetComponents toDate:compDate options:0];

}

- (void)saveFeedsWithObject:(id)object andKey:(NSString *)key{
    if (!object) {[SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Report a bug: 'null object for key '%@'", key]]; return;}
    NSMutableArray *cur = ([_feeds[key] count] > 0) ? _feeds[key] : [NSMutableArray array];
    [cur addObject:object];
    [_feeds setObject:cur forKey:key];
}

#pragma mark Connection
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    if (connection == rssConnection) [rssData appendData:data];
    if (connection == meetingsConnection) [meetingsData appendData:data];
    else if (connection == versionConnection) [versionData appendData:data];
//    else if (connection == rssNewsConnection) [rssNewsData appendData:data];
    else if (connection == scheduleConnection) [scheduleData appendData:data];
    else if (connection == tomorrowTextConnection) [tomorrowTextData appendData:data];
    else if (connection == todayScheduleConnection) [todayScheduleData appendData:data];
    else if (connection == tomorrowScheduleConnection) [tomorrowScheduleData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == specialConnection && [(NSHTTPURLResponse *)response statusCode] != 404) {
        [self saveFeedsWithObject:@"A special schedule is available." andKey:@"strings"];
        [self saveFeedsWithObject:[UIImage imageNamed:@"star-7.png"] andKey:@"images"];
        [self saveFeedsWithObject:[StandardTableViewCell class] andKey:@"class"];
        [self saveFeedsWithObject:@"Special" andKey:@"urls"];
        [self.tableView reloadData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.refreshControl endRefreshing];
    _ret = CONNECTION_FAILTURE;
//    _feeds = [NSMutableDictionary dictionaryWithObjects:@[@"Oops! The connection failed.", [UIImage imageNamed:@"caution-7.png"], [NSNumber numberWithBool:YES], @""] forKeys:@[@"strings", @"images", @"class", @"urls"]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [SVProgressHUD dismiss];
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
        if ([self compareArrays:csv and:[[NSUserDefaults standardUserDefaults] objectForKey:@"meetingLog"]] == NO) {
            [self saveFeedsWithObject:@"A club event has changed—view it" andKey:@"strings"];
            [self saveFeedsWithObject:[UIImage imageNamed:@"man-three-7.png"] andKey:@"images"];
            [self saveFeedsWithObject:[StandardTableViewCell class] andKey:@"class"];
            [self saveFeedsWithObject:@"Clubs" andKey:@"urls"];
        }
    }

    // TEXT-BASED schedules
    else if (connection == scheduleConnection || connection == tomorrowTextConnection) {
        NSString *schedule = [[NSString alloc] initWithData:((connection == tomorrowTextConnection) ? tomorrowTextData : scheduleData) encoding:NSUTF8StringEncoding];
        if (![schedule isEqualToString:@""]) [self addTextScheduleFeed:schedule withDayIndex:((connection == tomorrowTextConnection) ? 1 : 0)];
    }

    // IMAGE-BASED schedules
    else if (connection == todayScheduleConnection || connection == tomorrowScheduleConnection) {
        NSMutableData *d = (connection == todayScheduleConnection) ? todayScheduleData : tomorrowScheduleData;
        id object = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSString *savedDivision = [[NSUserDefaults standardUserDefaults] objectForKey:@"division"];
            [self saveFeedsWithObject:object[savedDivision] andKey:@"dayScheds"];
            if (![_feeds[@"class"] containsObject:[ScheduleTableViewCell class]]) {
                [self saveFeedsWithObject:[ScheduleTableViewCell class] andKey:@"class"];
                [self saveFeedsWithObject:@" " andKey:@"strings"];
                [self saveFeedsWithObject:[UIImage imageNamed:@"clock-7.png"] andKey:@"images"];
                [self saveFeedsWithObject:@" " andKey:@"urls"];
            }
        }

        if (connection == todayScheduleConnection) {
            // start connection for IMAGE-BASED tomorrow schedule
            NSURLRequest *tomorrowSchedule = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://campus.mbs.net/mbs/widget/graphicURLForMBSNow.php?day=%@", [self stringFromFormatterDate:[self tomorrow]]]]];
            tomorrowScheduleData = [NSMutableData data];
            tomorrowScheduleConnection = [[NSURLConnection alloc] initWithRequest:tomorrowSchedule delegate:self startImmediately:YES];
        }
    }

    else if (connection == versionConnection) {
        NSString *fileText = [[NSString alloc] initWithData:versionData encoding:NSUTF8StringEncoding];
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        if (![fileText isEqualToString:infoDict[@"CFBundleShortVersionString"]]) {
            [self saveFeedsWithObject:[StandardTableViewCell class] andKey:@"class"];
            [self saveFeedsWithObject:@"Update available! Tap to download." andKey:@"strings"];
            [self saveFeedsWithObject:[UIImage imageNamed:@"download-7.png"] andKey:@"images"];
            [self saveFeedsWithObject:UPDATE_URL andKey:@"urls"];
        }
    }
    _ret = CONNECTION_SUCCESS;
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

#pragma mark Table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (_ret > 0) ? 1 : [_feeds[@"class"] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_ret > 0) {
        static NSString *iden = @"retCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
        switch (_ret) {
            case CONNECTION_LOADING:
                cell.imageView.image = [UIImage imageNamed:@"cloud-download-7.png"];
                cell.textLabel.text = @"Hang tight... refreshing";
                break;
            case CONNECTION_FAILTURE:
                cell.imageView.image = [UIImage imageNamed:@"caution-7.png"];
                cell.textLabel.text = @"Aw, snap; the connection failed!";
                break;
        }
        return cell;
    }
    id cl = _feeds[@"class"][indexPath.row];
    if (cl == [StandardTableViewCell class]) {
        static NSString *iden = @"standard";
        StandardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
        cell.label.text = _feeds[@"strings"][indexPath.row];
        cell.img.image = _feeds[@"images"][indexPath.row];
        cell.url = _feeds[@"urls"][indexPath.row];
        if (cell == nil)
            cell = [[StandardTableViewCell alloc] initWithStyle:nil reuseIdentifier:iden];
        return cell;
    } else if (cl == [TodayCellTableViewCell class]) {
        static NSString *iden = @"today";
        TodayCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MMM d, h:mm:ss a";
        cell.dateTag.text = [NSString stringWithFormat:@"Updated %@", [formatter stringFromDate:[NSDate date]]];
        cell.messageBody.text = _feeds[@"strings"][indexPath.row];
        cell.img.image = _feeds[@"images"][indexPath.row];
        return cell;
    } else if (cl == [ScheduleTableViewCell class]) {
        static NSString *iden = @"schedule";
        ScheduleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
        [cell.today setImageWithURL:[NSURL URLWithString:_feeds[@"dayScheds"][0]] placeholderImage:[UIImage imageNamed:@"loading-schedule.png"]];
        if ([_feeds[@"dayScheds"] count] > 1) [cell.tomorrow setImageWithURL:[NSURL URLWithString:_feeds[@"dayScheds"][1]] placeholderImage:[UIImage imageNamed:@"loading-schedule.png"]];
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_ret > 0) return 46.0f;
    id cl = _feeds[@"class"][indexPath.row];
    if (cl == [StandardTableViewCell class]) return 46.0f;
    else if (cl == [TodayCellTableViewCell class]) return 154.0f;
    else return 444.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *iden = [tableView cellForRowAtIndexPath:indexPath].reuseIdentifier;
    if ([iden isEqualToString:@"schedule"]) {
        FormsViewerViewController *vc = [[FormsViewerViewController alloc] initWithFullURL:@"http://campus.mbs.net/mbs/widget/daySched.php"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([iden isEqualToString:@"standard"]) {
        NSString *str = [(StandardTableViewCell *)([tableView cellForRowAtIndexPath:indexPath]) url];
        if (![str isEqualToString:@""]) {
            if ([str isEqualToString:@"Clubs"]) {
                self.tabBarController.selectedIndex = 2;
                return;
            }
            FormsViewerViewController *vc;
            if ([str isEqualToString:UPDATE_URL]) {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                return;
            }
            else vc = [[FormsViewerViewController alloc] initWithStringForURL:str];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if (_feeds[@"class"][indexPath.row] == [TodayCellTableViewCell class]) {
        NSString *alertTitle = [((TodayCellTableViewCell *)[tableView cellForRowAtIndexPath:indexPath]) messageBody].text;
        NSDate *fireDate = [[NSDate date] dateByAddingTimeInterval:20];
        UILocalNotification *lcl = [[UILocalNotification alloc] init];
        lcl.fireDate = fireDate;
        lcl.alertBody = alertTitle;
        lcl.soundName = UILocalNotificationDefaultSoundName;
        lcl.alertAction = @"Open";
        lcl.timeZone = [NSTimeZone defaultTimeZone];

        [[UIApplication sharedApplication] scheduleLocalNotification:lcl];
        [SVProgressHUD showSuccessWithStatus:@"Showing notification in 20 seconds. Lock your device to have it show on the lock-screen."];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        return YES;
    else {
        if (toInterfaceOrientation == UIDeviceOrientationPortrait) return YES;
        return NO;
    }
}

#pragma mark Alert
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag != 2) return;
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
    
    [self noSavedGrade:@"Whoops! Try again."];
}

@end