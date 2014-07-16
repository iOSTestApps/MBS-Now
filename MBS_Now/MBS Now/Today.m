//
//  Today.m
//  MBS Now
//
//  Created by gdyer on 5/18/14.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "Today.h"
#import "FormsViewerViewController.h"
#import "UIView+Toast.h"
#import "XMLDictionary.h"
#import "HomeViewController.h"
#import "SVWebViewController.h"
#import "StandardTableViewCell.h"
#import "TodayCellTableViewCell.h"
#import "ScheduleTableViewCell.h"
#import "ArticleTableViewCell.h"
#import "EventTableViewCell.h"
#import "ShortEventTableViewCell.h"
#import "UIImageView+WebCache.h"

#define CONNECTION_FAILTURE 2
#define CONNECTION_LOADING 1
#define CONNECTION_SUCCESS 0
#define UPDATE_URL @"https://itunes.apple.com/us/app/mbs-now/id617180145?mt=8"

@implementation Today

- (void)viewDidLoad {
    [super viewDidLoad];

    preserve = NO;

    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 20)];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
    [self.tableView setContentInset:UIEdgeInsetsMake(20,0,0,0)];

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Happy %@. Building your day...", [self dayNameFromDate:[NSDate date]]]];
    [refresh addTarget:self action:@selector(update) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more-list-7-active.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(more)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"food-sign.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(lunch)];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    if (preserve) return;
    // stop all non-essential connections
    NSLog(@"killing connections");
    [versionConnection cancel];
    [meetingsConnection cancel];
    [rssConnection cancel];
    [communityServiceConnection cancel];
    [specialConnection cancel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    NSString *savedDivision = [[NSUserDefaults standardUserDefaults] objectForKey:@"division"];
    if (!savedDivision) {
        [self noSavedGrade:@"Enter between 6 and 12"];
        return;
    }

    if (!preserve) [self update];
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
    if (!self.refreshControl.refreshing) [SVProgressHUD showWithStatus:@"Building your day..."];
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

    if ([self getHourOfDay] > 18 || [[NSUserDefaults standardUserDefaults] boolForKey:@"alwaysTwoDay"]) {
        // in production, use commented tmrwText rather than unformatted string tmrwText (currently uncommented)
//        NSURLRequest *tmrwText = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://campus.mbs.net/mbs/widget/dayPeriodsForMBSNow.php?day=%@&div=us", [self stringFromFormatterDate:[self tomorrow]]]]];
        NSURLRequest *tmrwText = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://campus.mbs.net/mbs/widget/dayPeriodsForMBSNow.php?day=2014-1-17&div=us"]];
        tomorrowTextData = [NSMutableData data];
        tomorrowTextConnection = [[NSURLConnection alloc] initWithRequest:tmrwText delegate:self startImmediately:YES];
    }

    NSURLRequest *rssNews = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.mbs.net/rss.cfm?news=0"]];
    rssNewsData = [NSMutableData data];
    rssNewsConnection = [[NSURLConnection alloc] initWithRequest:rssNews delegate:self startImmediately:YES];

    NSURLRequest *serviceRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://docs.google.com/spreadsheet/pub?key=0AsW47GVmNrjDdHZEWEoxS0lDVVpMVEg5LUR1ZnBIUkE&output=csv"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
    communityServiceData = [NSMutableData data];
    communityServiceConnection = [[NSURLConnection alloc] initWithRequest:serviceRequest delegate:self];

    NSURLRequest *docRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://docs.google.com/spreadsheet/pub?key=0Ar9jhHUssWrpdGJSYTFjWWhDWndKQW0yckluTU5PX1E&output=csv"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
    meetingsData = [NSMutableData data];
    meetingsConnection = [[NSURLConnection alloc] initWithRequest:docRequest delegate:self];

    NSURLRequest *version = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/gdyer/MBS-Now/master/Resources/app-store-version.txt"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    versionData = [NSMutableData data];
    versionConnection = [[NSURLConnection alloc] initWithRequest:version delegate:self startImmediately:YES];

    NSURLRequest *special = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://campus.mbs.net/mbsnow/home/forms/Special.pdf"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    specialData = [NSMutableData data];
    specialConnection = [[NSURLConnection alloc] initWithRequest:special delegate:self startImmediately:YES];

    NSURLRequest *rss = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.mbs.net/data/calendar/rsscache/calendar_4486.rss"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    rssData = [NSMutableData data];
    rssConnection = [[NSURLConnection alloc] initWithRequest:rss delegate:self startImmediately:YES];
}

- (void)moveAlongWithNotif:(NSString *)title atTime:(NSDate *)fireDate {
    UILocalNotification *lcl = [[UILocalNotification alloc] init];
    lcl.fireDate = fireDate;
    lcl.alertBody = title;
    lcl.soundName = UILocalNotificationDefaultSoundName;
    lcl.alertAction = @"Open";
    lcl.timeZone = [NSTimeZone defaultTimeZone];
    [[UIApplication sharedApplication] scheduleLocalNotification:lcl];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"textScheduleNotifications"]) {
        // first time scheduling a text-based schedule notification
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"textScheduleNotifications"];
    } else {
        NSInteger q = [[NSUserDefaults standardUserDefaults] integerForKey:@"textScheduleNotifications"];
        [[NSUserDefaults standardUserDefaults] setInteger:(q+1) forKey:@"textScheduleNotifications"];
    }
}

- (NSString *)stringFromFormatterDate:(NSDate *)d {
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"y-M-d"];
    return [form stringFromDate:d];
}

- (NSString *)dayNameFromDate:(NSDate *)d {
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"EEEE"];
    return [form stringFromDate:d];
}

- (NSDate *)dateFromXmlFormatter:(NSString *)s {
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"EEE, dd MMM yyyy"];
    return [form dateFromString:s];
}

- (NSDate *)dateFromNewsXmlFormatter:(NSString *)s {
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss -0000"];
    return [form dateFromString:s];
}

- (int)getHourOfDay {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    return [components hour];
}

- (NSDate *)getDateForTomorrowAtHour:(int)h {
    NSDateComponents *tomorrowComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    NSDate *compDate = [[NSCalendar currentCalendar] dateFromComponents:tomorrowComponents];

    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    offsetComponents.timeZone = [NSTimeZone localTimeZone];
    offsetComponents.day = 1;
    offsetComponents.hour = h;
    offsetComponents.minute = 0;
    return [[NSCalendar currentCalendar] dateByAddingComponents:offsetComponents toDate:compDate options:0];
}

- (NSDate *)dateByDistanceFromToday:(int)d {
    NSDateComponents *tomorrowComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    NSDate *compDate = [[NSCalendar currentCalendar] dateFromComponents:tomorrowComponents];

    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    offsetComponents.day = d;
    return [[NSCalendar currentCalendar] dateByAddingComponents:offsetComponents toDate:compDate options:0];
}

- (void)saveFeedsWithObject:(id)object andKey:(NSString *)key{
    if (!object) {[SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Report a bug: 'null object for key '%@'", key]]; return;}
    NSMutableArray *cur = ([_feeds[key] count] > 0) ? _feeds[key] : [NSMutableArray array];
    [cur addObject:object];
    [_feeds setObject:cur forKey:key];
}

- (id)shadowCell:(UITableViewCell *)cell {
    cell.layer.shadowOffset = CGSizeMake(1, 0);
    cell.layer.shadowColor = [[UIColor blackColor] CGColor];
    cell.layer.shadowRadius = 1;
    cell.layer.shadowOpacity = .25;
    CGRect shadowFrame = cell.layer.bounds;
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
    cell.layer.shadowPath = shadowPath;
    return cell;
}

- (void)lunch {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"lunchFromToday"]) {
        // first time accessing a menu
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"lunchFromToday"];
    } else {
        NSInteger q = [[NSUserDefaults standardUserDefaults] integerForKey:@"lunchFromToday"];
        [[NSUserDefaults standardUserDefaults] setInteger:(q+1) forKey:@"lunchFromToday"];
    }

    BOOL late = ([self getHourOfDay] > 15) ? YES : NO;
    FormsViewerViewController *fvvc = [[FormsViewerViewController alloc] initWithLunchDay:(late) ? [self dayNameFromDate:[self dateByDistanceFromToday:1]] : [self dayNameFromDate:[NSDate date]]  showingTomorrow:late];
    [self.navigationController pushViewController:fvvc animated:YES];
}

#pragma mark More
- (void)more {
    if (sheet) {
        [sheet dismissWithClickedButtonIndex:-1 animated:YES];
        sheet = nil;
        return;
    }

    BOOL d = [[NSUserDefaults standardUserDefaults] boolForKey:@"alwaysTwoDay"];
    BOOL h = [[NSUserDefaults standardUserDefaults] boolForKey:@"showTodayFirst"];
    BOOL n = [[NSUserDefaults standardUserDefaults] boolForKey:@"alwaysShowArticle"];
    sheet = [[UIActionSheet alloc] initWithTitle:@"Customize your Today feed" delegate:self cancelButtonTitle:@"Dismiss" destructiveButtonTitle:nil otherButtonTitles:(showAllEvents) ? @"Only show some calendar events" : @"Show all calendar events", (n) ? @"Only show latest news" : @"Show all recent news", (d) ? @"Show tomorrow's text schedule after 3" : @"Always show tomorrow's text schedule", (h) ? @"Make Home the launch screen" : @"Make Today the launch screen", nil];

    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 2:
            // show 2 days
            [[NSUserDefaults standardUserDefaults] setBool:!([[NSUserDefaults standardUserDefaults] boolForKey:@"alwaysTwoDay"]) forKey:@"alwaysTwoDay"];
            [self update];
            break;
        case 0:
            // events
            showAllEvents = !showAllEvents;
            [self update];
            break;
        case 1:
            // news
            [[NSUserDefaults standardUserDefaults] setBool:![[NSUserDefaults standardUserDefaults] boolForKey:@"alwaysShowArticle"] forKey:@"alwaysShowArticle"];
            [self update];
            break;
        case 3:
            // make today initial VC
            [[NSUserDefaults standardUserDefaults] setBool:![[NSUserDefaults standardUserDefaults] boolForKey:@"showTodayFirst"] forKey:@"showTodayFirst"];
            [SVProgressHUD showSuccessWithStatus:@"Set first screen to appear!"];
            break;
        default:
            break;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    sheet = nil;
}

#pragma mark Connection
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == rssConnection) [rssData appendData:data];
    else if (connection == meetingsConnection) [meetingsData appendData:data];
    else if (connection == versionConnection) [versionData appendData:data];
    else if (connection == rssNewsConnection) [rssNewsData appendData:data];
    else if (connection == scheduleConnection) [scheduleData appendData:data];
    else if (connection == tomorrowTextConnection) [tomorrowTextData appendData:data];
    else if (connection == todayScheduleConnection) [todayScheduleData appendData:data];
    else if (connection == tomorrowScheduleConnection) [tomorrowScheduleData appendData:data];
    else if (connection == communityServiceConnection) [communityServiceData appendData:data];
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
    [SVProgressHUD dismiss];
    [self.tableView reloadData];
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

    if (connection == communityServiceConnection) {
        NSString *separation = @"\n";
        NSString *fileText = [[NSString alloc] initWithData:communityServiceData encoding:NSUTF8StringEncoding];
        NSArray *raw = [fileText componentsSeparatedByString:separation];
        NSMutableArray *csv = [NSMutableArray array];
        for (NSString *foo in raw) {
            NSArray *dummy = [foo componentsSeparatedByString:@","];
            [csv addObject:dummy];
        }
        [csv removeObjectAtIndex:0];
        if (csv.count > [[[NSUserDefaults standardUserDefaults] objectForKey:@"serviceLog"] count]) {
            [self saveFeedsWithObject:@"Service opportunity added—view it" andKey:@"strings"];
            [self saveFeedsWithObject:[UIImage imageNamed:@"throw-rubbish.png"] andKey:@"images"];
            [self saveFeedsWithObject:[StandardTableViewCell class] andKey:@"class"];
            [self saveFeedsWithObject:@"Service" andKey:@"urls"];
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
            NSURLRequest *tomorrowSchedule = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://campus.mbs.net/mbs/widget/graphicURLForMBSNow.php?day=%@", [self stringFromFormatterDate:[self dateByDistanceFromToday:1]]]]];
            tomorrowScheduleData = [NSMutableData data];
            tomorrowScheduleConnection = [[NSURLConnection alloc] initWithRequest:tomorrowSchedule delegate:self startImmediately:YES];
        }
    }

    else if (connection == rssConnection) {
        NSArray *events = [NSDictionary dictionaryWithXMLData:rssData][@"channel"][@"item"];
        int evCount = 0;
        for (NSDictionary *foo in events) {
            NSString *dateStr = [[foo[@"description"] componentsSeparatedByString:@"Date: "][1] componentsSeparatedByString:@"<br />"][0];
            if ([[self dateFromXmlFormatter:dateStr] compare:[NSDate date]] == NSOrderedSame) {
                evCount++;
                NSString *str = foo[@"description"];
                [self saveFeedsWithObject:([str rangeOfString:@"Location"].location == NSNotFound) ? [ShortEventTableViewCell class] : [EventTableViewCell class] andKey:@"class"];
                [self saveFeedsWithObject:foo[@"description"] andKey:@"strings"];
                [self saveFeedsWithObject:[UIImage imageNamed:@"calendar.png"] andKey:@"images"];
                [self saveFeedsWithObject:foo[@"pubDate"] andKey:@"urls"];
            } else break;
        }

        // because we always want some events to appear, even if they're not happening today
        while (evCount < ((showAllEvents) ? (events.count-1) : 2)) {
            evCount++;
            NSString *str = events[evCount][@"description"];
            [self saveFeedsWithObject:([str rangeOfString:@"Location"].location == NSNotFound) ? [ShortEventTableViewCell class] : [EventTableViewCell class] andKey:@"class"];
            [self saveFeedsWithObject:events[evCount][@"title"] andKey:@"strings"];
            [self saveFeedsWithObject:[UIImage imageNamed:@"calendar.png"] andKey:@"images"];
            [self saveFeedsWithObject:str andKey:@"urls"];
        }
    }

    else if (connection == versionConnection) {
        NSString *fileText = [[NSString alloc] initWithData:versionData encoding:NSUTF8StringEncoding];
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        // in production, use commented condition below instead of string comparison
//        if ([fileText stringByReplacingOccurrencesOfString:@"." withString:@""].intValue > [infoDict[@"CFBundleShortVersionString"] stringByReplacingOccurrencesOfString:@"." withString:@""].intValue)
        if (![fileText isEqualToString:infoDict[@"CFBundleShortVersionString"]]) {
            [self saveFeedsWithObject:[StandardTableViewCell class] andKey:@"class"];
            [self saveFeedsWithObject:@"Update available! Tap to download." andKey:@"strings"];
            [self saveFeedsWithObject:[UIImage imageNamed:@"download-7.png"] andKey:@"images"];
            [self saveFeedsWithObject:UPDATE_URL andKey:@"urls"];
        }
    }

    else if (connection == rssNewsConnection) {
        NSArray *events = [NSDictionary dictionaryWithXMLData:rssNewsData][@"channel"][@"item"];
        BOOL n = [[NSUserDefaults standardUserDefaults] boolForKey:@"alwaysShowArticle"];
        for (NSDictionary *d in events) {
            NSDate *pub = [self dateFromNewsXmlFormatter:d[@"pubDate"]];
            NSLog(@"%@", pub);
            if ([pub compare:[NSDate date]] == NSOrderedSame || [pub compare:[self dateByDistanceFromToday:-1]] == NSOrderedSame || n) {
                // either a story from yesterday or today
                [self saveFeedsWithObject:[ArticleTableViewCell class] andKey:@"class"];
                [self saveFeedsWithObject:d[@"title"] andKey:@"strings"];
                [self saveFeedsWithObject:d[@"pubDate"] andKey:@"images"];
                [self saveFeedsWithObject:d[@"link"] andKey:@"urls"];
            }
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
                cell.textLabel.text = [NSString stringWithFormat:@"Happy %@. Updating...", [self dayNameFromDate:[NSDate date]]];
                cell.detailTextLabel.text = @"Taking a while? Swipe down to restart.";
                break;
            case CONNECTION_FAILTURE:
                cell.imageView.image = [UIImage imageNamed:@"caution-7.png"];
                cell.textLabel.text = @"Nuts; the connection failed!";
                cell.detailTextLabel.text = @"Tap for offline use or pull ↓ to reload";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell = [self shadowCell:cell];
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
        cell = [self shadowCell:cell];
        return cell;
    } else if (cl == [ScheduleTableViewCell class]) {
        static NSString *iden = @"schedule";
        ScheduleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
        [cell.today setImageWithURL:[NSURL URLWithString:_feeds[@"dayScheds"][0]] placeholderImage:[UIImage imageNamed:@"loading-schedule.png"]];
        if ([_feeds[@"dayScheds"] count] > 1) [cell.tomorrow setImageWithURL:[NSURL URLWithString:_feeds[@"dayScheds"][1]] placeholderImage:[UIImage imageNamed:@"loading-schedule.png"]];
        cell = [self shadowCell:cell];
        return cell;
    } else if (cl == [EventTableViewCell class]) {
        static NSString *iden = @"event";
        EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
        if (cell == nil)
            cell = [[EventTableViewCell alloc] initWithStyle:nil reuseIdentifier:iden];
        cell.eventBody.text = _feeds[@"strings"][indexPath.row];
        NSMutableArray *full = [[_feeds[@"urls"][indexPath.row] componentsSeparatedByString:@"<br />"] mutableCopy];
        [full removeLastObject];
        if (full.count > 1) { // potentially dangerous assumption here is that if an event has a time, it must have a location and vice-versa
            cell.dateTag.text = [NSString stringWithFormat:@"%@ at %@", [full[0] componentsSeparatedByString:@": "][1], [full[1] componentsSeparatedByString:@": "][1]];
            cell.locTag.text = [full[2] componentsSeparatedByString:@": "][1];
        }
        cell = [self shadowCell:cell];
        return cell;
    }
    else if (cl == [ShortEventTableViewCell class]) {
        static NSString *iden = @"shortEvent";
        ShortEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
        if (cell == nil)
            cell = [[ShortEventTableViewCell alloc] initWithStyle:nil reuseIdentifier:iden];
        cell.eventBody.text = _feeds[@"strings"][indexPath.row];
        NSMutableArray *full = [[_feeds[@"urls"][indexPath.row] componentsSeparatedByString:@"<br />"] mutableCopy];
        [full removeLastObject];
        if (full.count > 1) cell.dateTag.text = [NSString stringWithFormat:@"%@ at %@", [full[0] componentsSeparatedByString:@": "][1], [full[1] componentsSeparatedByString:@": "][1]];
        cell = [self shadowCell:cell];
        return cell;
    }

    else if (cl == [ArticleTableViewCell class]) {
        static NSString *iden = @"article";
        ArticleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
        if (cell == nil)
            cell = [[ArticleTableViewCell alloc] initWithStyle:nil reuseIdentifier:iden];
        cell.articleBody.text = [NSString stringWithFormat:@"%@ (tap to read)", _feeds[@"strings"][indexPath.row]];
        cell.dateTag.text = [NSString stringWithFormat:@"Posted on %@", [_feeds[@"images"][indexPath.row] stringByReplacingOccurrencesOfString:@":00 -0000" withString:@""]];
        cell = [self shadowCell:cell];
        return cell;
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_ret > 0) return 46.0f;
    id cl = _feeds[@"class"][indexPath.row];
    if (cl == [StandardTableViewCell class]) return 46.0f;
    else if (cl == [TodayCellTableViewCell class]) return 154.0f;
    else if (cl == [EventTableViewCell class]) return 106.0f;
    else if (cl == [ShortEventTableViewCell class]) return 66.0f;
    else if (cl == [ArticleTableViewCell class]) return 71.0f;
    else return 444.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    preserve = NO;
    if (_ret == CONNECTION_FAILTURE) {
        [self performSegueWithIdentifier:@"offline" sender:self];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }

    NSString *iden = [tableView cellForRowAtIndexPath:indexPath].reuseIdentifier;
    if ([iden isEqualToString:@"article"]) {
        preserve = YES;
        NSString *s = [_feeds[@"urls"][indexPath.row] componentsSeparatedByString:@"newsid="][1];
        FormsViewerViewController *fvvc = [[FormsViewerViewController alloc] initWithFullURL:[NSString stringWithFormat:@"http://www.mbs.net/cf_news/view.cfm?newsid=%@", s]];
        [self.navigationController pushViewController:fvvc animated:YES];
        return;
    }

    if ([iden isEqualToString:@"event"]) {[tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;}
    if ([iden isEqualToString:@"schedule"]) {
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"fullScheduleViewsFromTodayCell"]) {
            // first time scheduling a text-based schedule notification
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"fullScheduleViewsFromTodayCell"];
        } else {
            NSInteger q = [[NSUserDefaults standardUserDefaults] integerForKey:@"fullScheduleViewsFromTodayCell"];
            q++;
            [[NSUserDefaults standardUserDefaults] setInteger:q forKey:@"fullScheduleViewsFromTodayCell"];
        }

        FormsViewerViewController *vc = [[FormsViewerViewController alloc] initWithFullURL:@"http://campus.mbs.net/mbs/widget/daySched.php"];
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    else if ([iden isEqualToString:@"standard"]) {
        NSString *str = [(StandardTableViewCell *)([tableView cellForRowAtIndexPath:indexPath]) url];
        if (![str isEqualToString:@""]) {
            if ([str isEqualToString:@"Clubs"]) {
                self.tabBarController.selectedIndex = 2;
                return;
            }
            if ([str isEqualToString:@"Service"]) {
                self.tabBarController.selectedIndex = 3;
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
        if ([alertTitle rangeOfString:@"Tomorrow"].location != NSNotFound /*&& [self getHourOfDay] > 15*/) {
            // scheduling an alert when it's the day before
            UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Is tomorrow better?" message:@"Would you like to schedule this notification for tomorrow instead?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes, at 8 AM", @"Yes, at 7 AM", @"No, now", nil];
            a.tag = 1;
            a.restorationIdentifier = alertTitle;
            [a show];
            return;
        }

        [SVProgressHUD showSuccessWithStatus:@"Showing notification in 20 seconds. Lock your device to have it show on the lock-screen."];
        [self moveAlongWithNotif:alertTitle atTime:[[NSDate date] dateByAddingTimeInterval:20]];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) return YES;
    return (toInterfaceOrientation == UIDeviceOrientationPortrait) ? YES : NO;
}

#pragma mark Alert
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        switch (buttonIndex) {
            case 1:
                // 8 AM tmrw
                [self moveAlongWithNotif:alertView.restorationIdentifier atTime:[self getDateForTomorrowAtHour:4]];
                [SVProgressHUD showSuccessWithStatus:@"Scheduled for 8 AM"];
                break;
            case 2:
                // 7 AM tmrw
                [self moveAlongWithNotif:alertView.restorationIdentifier atTime:[self getDateForTomorrowAtHour:3]];
                [SVProgressHUD showSuccessWithStatus:@"Scheduled for 7 AM"];
                break;
            case 3:
                // in 20 seconds
                [SVProgressHUD showSuccessWithStatus:@"Showing notification in 20 seconds. Lock your device to have it show on the lock-screen."];
                [self moveAlongWithNotif:alertView.restorationIdentifier atTime:[[NSDate date] dateByAddingTimeInterval:20]];
                break;
            default:
                break;
        }
        return;
    }
    if (alertView.tag != 2) return;
    NSMutableArray *poss = [NSMutableArray array];
    for (int x = 6; x < 13; x++)
        [poss addObject:[NSString stringWithFormat:@"%d", x]];
    NSString *grade = [alertView textFieldAtIndex:0].text;
    if ([poss containsObject:grade]) {
        [[NSUserDefaults standardUserDefaults] setObject:((grade.integerValue < 9) ? @"MS" : @"US") forKey:@"division"];
        [self.view makeToast:@"Thanks. That's editable in Settings." duration:2.0f position:@"top"];
        [self update];
        return;
    }
    
    [self noSavedGrade:@"Whoops! Try again."];
}

@end