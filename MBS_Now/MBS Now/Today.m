//
//  Today.m
//  MBS Now
//
//  Created by gdyer on 5/18/14.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import "Today.h"
#import "FormsViewerViewController.h"
#import "SVWebViewController.h"
#import "StandardTableViewCell.h"
#import "TodayCellTableViewCell.h"
#import "ScheduleTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "XMLDictionary.h"
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
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"clock-7-active.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(schedule)];
    self.navigationItem.backBarButtonItem.title = @"Today";
}

- (void)noSavedGrade:(NSString *)append {
    UIAlertView *d = [[UIAlertView alloc] initWithTitle:@"What grade are you in?" message:@"Faculty memebers: enter any grade within your division (MS or US)." delegate:self cancelButtonTitle:@"Go" otherButtonTitles:nil, nil];
    d.alertViewStyle = UIAlertViewStylePlainTextInput;
    [d textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [d textFieldAtIndex:0].placeholder = append;
    [d show];
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

- (void)schedule {
    SVWebViewController *wvc = [[SVWebViewController alloc] initWithAddress:@"http://campus.mbs.net/mbs/widget/daySched.php"];
    [self.navigationController pushViewController:wvc animated:YES];
}

- (void)update {
    _loadingMessage = @"Refreshing... just for you :)";
    [self.tableView reloadData];

    _feeds = [NSMutableDictionary dictionary];

    NSString *savedDivision = [[NSUserDefaults standardUserDefaults] objectForKey:@"division"];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM d, h:mm:ss a";
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated %@", [formatter stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];

    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"y-M-d"];

//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
//    NSInteger hour = [components hour];
//
//    if (hour < 16) {

    NSURLRequest *schedule = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://campus.mbs.net/mbs/widget/dayPeriodsForMBSNow.php?day=%@&div=%@", [form stringFromDate:[NSDate date]], savedDivision]]];
    scheduleData = [NSMutableData data];
    scheduleConnection = [[NSURLConnection alloc] initWithRequest:schedule delegate:self startImmediately:YES];

    NSURLRequest *todaySchedule = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://campus.mbs.net/mbs/widget/graphicURLForMBSNow.php?day=%@", [form stringFromDate:[NSDate date]]]]];
    todayScheduleData = [NSMutableData data];
    todayScheduleConnection = [[NSURLConnection alloc] initWithRequest:todaySchedule delegate:self startImmediately:YES];

    NSDateComponents *tomorrowComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:[NSDate date]];
    NSDate *compDate = [[NSCalendar currentCalendar] dateFromComponents:tomorrowComponents];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    offsetComponents.day = 1;
    _tomorrow = [[NSCalendar currentCalendar] dateByAddingComponents:offsetComponents toDate:compDate options:0];
    NSURLRequest *tomorrowSchedule = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://campus.mbs.net/mbs/widget/graphicURLForMBSNow.php?day=%@", [form stringFromDate:_tomorrow]]]];
    tomorrowScheduleData = [NSMutableData data];
    tomorrowScheduleConnection = [[NSURLConnection alloc] initWithRequest:tomorrowSchedule delegate:self startImmediately:YES];

//    NSURLRequest *rss = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.mbs.net/calendar/page_1424.rss"]];
//    rssData = [NSMutableData data];
//    rssConnection = [[NSURLConnection alloc] initWithRequest:rss delegate:self startImmediately:NO];
//
//    NSURLRequest *rssNews = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.mbs.net/rss.cfm?news=0"]];
//    rssNewsData = [NSMutableData data];
//    rssNewsConnection = [[NSURLConnection alloc] initWithRequest:rssNews delegate:self startImmediately:NO];

//    NSURLRequest *docRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://docs.google.com/spreadsheet/pub?key=0Ar9jhHUssWrpdGJSYTFjWWhDWndKQW0yckluTU5PX1E&output=csv"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
//    meetingsData = [NSMutableData data];
//    meetingsConnection = [[NSURLConnection alloc] initWithRequest:docRequest delegate:self];

//    NSURLRequest *version = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/gdyer/MBS-Now/master/Resources/app-store-version.txt"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
//    versionData = [NSMutableData data];
//    versionConnection = [[NSURLConnection alloc] initWithRequest:version delegate:self startImmediately:YES];
//
    NSURLRequest *special = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://campus.mbs.net/mbsnow/home/forms/ACTdates.pdf"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    specialData = [NSMutableData data];
    specialConnection = [[NSURLConnection alloc] initWithRequest:special delegate:self startImmediately:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
//    [versionConnection cancel];
//    [meetingsConnection cancel];
    [rssConnection cancel];
    [specialConnection cancel];
    [rssNewsConnection cancel];
}

- (void)saveFeedsWithObject:(id)object andKey:(NSString *)key{
    if (!object) {[SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Report a bug: 'null' object for key '%@'", key]]; return;}
    NSMutableArray *cur = ([_feeds[key] count] > 0) ? _feeds[key] : [NSMutableArray array];
    [cur addObject:object];
    [_feeds setObject:cur forKey:key];
}

#pragma mark Connection
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == rssConnection) [rssData appendData:data];
//    else if (connection == meetingsConnection) [meetingsData appendData:data];
//    else if (connection == versionConnection) [versionData appendData:data];
//    else if (connection == rssNewsConnection) [rssNewsData appendData:data];
//    else if (connection == scheduleConnection) [scheduleData appendData:data];
    else if (connection == todayScheduleConnection) [todayScheduleData appendData:data];
    else if (connection == tomorrowScheduleConnection) [tomorrowScheduleData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == specialConnection && [(NSHTTPURLResponse *)response statusCode] != 404) {
        [self saveFeedsWithObject:@"A special schedule is available." andKey:@"strings"];
        [self saveFeedsWithObject:[UIImage imageNamed:@"star-7.png"] andKey:@"images"];
        [self saveFeedsWithObject:[StandardTableViewCell class] andKey:@"class"];
        [self saveFeedsWithObject:@"ACTDates" andKey:@"urls"];
        [self.tableView reloadData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _feeds = [NSMutableDictionary dictionaryWithObjects:@[@"Oops! The connection failed.", [UIImage imageNamed:@"caution-7.png"], [StandardTableViewCell class], @""] forKeys:@[@"strings", @"images", @"class", @"urls"]];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    if (connection == meetingsConnection) {
//        NSString *separation = @"\n";
//        NSString *fileText = [[NSString alloc] initWithData:meetingsData encoding:NSUTF8StringEncoding];
//        NSArray *raw = [fileText componentsSeparatedByString:separation];
//        NSMutableArray *csv = [NSMutableArray array];
//        for (NSString *foo in raw) {
//            NSArray *dummy = [foo componentsSeparatedByString:@","];
//            [csv addObject:dummy];
//        }
//        [csv removeObjectAtIndex:0];
//    }

    if (connection == scheduleConnection) {
        [rssConnection start];
        NSString *schedule = [[NSString alloc] initWithData:scheduleData encoding:NSUTF8StringEncoding];
        if (![schedule isEqualToString:@""]) {
            NSString *sched = [NSString stringWithFormat:@"Today: %@", [[[schedule stringByReplacingOccurrencesOfString:@"|" withString:@", "] stringByReplacingOccurrencesOfString:@"Advisors, " withString:@""] stringByReplacingOccurrencesOfString:@"Advisory, " withString:@""]];
            [self saveFeedsWithObject:sched andKey:@"strings"];
            [self saveFeedsWithObject:[UIImage imageNamed:@"clock-7.png"] andKey:@"images"];
            [self saveFeedsWithObject:[TodayCellTableViewCell class] andKey:@"class"];
            [self saveFeedsWithObject:@"http://campus.mbs.net/mbs/widget/daySched.php" andKey:@"urls"];
        }
    }

    if (connection == todayScheduleConnection || connection == tomorrowScheduleConnection) {
        NSMutableData *d = (connection == todayScheduleConnection) ? todayScheduleData : tomorrowScheduleData;
        id object = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSString *savedDivision = [[NSUserDefaults standardUserDefaults] objectForKey:@"division"];
            [self saveFeedsWithObject:object[savedDivision] andKey:@"dayScheds"];
            if ([_feeds[@"class"] isKindOfClass:[NSMutableArray class]]) {
                if (![_feeds[@"class"] containsObject:[ScheduleTableViewCell class]]) {
                    [self saveFeedsWithObject:[ScheduleTableViewCell class] andKey:@"class"];
                    [self saveFeedsWithObject:@" " andKey:@"strings"];
                    [self saveFeedsWithObject:[UIImage imageNamed:@"clock-7.png"] andKey:@"images"];
                    [self saveFeedsWithObject:@" " andKey:@"urls"];
                }
            }
        }
    }

    _loadingMessage = (_feeds.allKeys.count == 0) ? @"No new messages here..." : nil;
//    if (connection == rssConnection) {
//        [rssNewsConnection start];
//        NSDictionary *events = [NSDictionary dictionaryWithXMLData:rssData];
//        NSMutableDictionary *cleanEvents = [NSMutableDictionary dictionary];
//        NSDateFormatter *format = [[NSDateFormatter alloc] init];
//        [format setTimeZone:[NSTimeZone localTimeZone]];
//        [format setDateFormat:@"EE, dd MMMM yyyy'"];
//        NSLog(@"%@", [format stringFromDate:[NSDate date]]);
//        for (NSDictionary *f in events[@"channel"][@"item"]) {
//            NSMutableArray *e = (cleanEvents[@"titles"]) ? cleanEvents[@"titles"] : [NSMutableArray array];
//            NSString *dateStr = [NSString stringWithFormat:@"%@", [[f[@"description"] componentsSeparatedByString:@": "][1] componentsSeparatedByString:@"<br />"][0]];
//            NSLog(@"%@", [format stringFromDate:_tomorrow]);
//            if ([dateStr isEqualToString:[format stringFromDate:[NSDate date]]] || [dateStr isEqualToString:[format stringFromDate:_tomorrow]]) {
//                [e addObject:dateStr];
//                [cleanEvents setObject:e forKey:@"titles"];
//            }
////            else break;
//        }
//
//        NSLog(@"%@", cleanEvents[@"titles"]);
//    }
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

#pragma mark Table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ([_feeds[@"class"] isKindOfClass:[NSMutableArray class]]) ? [_feeds[@"class"] count] : 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%@", _feeds);
    static NSString *iden = @"loading";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:iden];
    cell.textLabel.text = _loadingMessage;
    id cl = ([_feeds[@"class"] isKindOfClass:[NSMutableArray class]]) ? [_feeds[@"class"][indexPath.row] class]  : [UITableViewCell class];
    NSLog(@"%@", cl);
    if ([cl isSubclassOfClass:[StandardTableViewCell class]]) {
        static NSString *iden = @"standard";
        StandardTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
        cell.label.text = _feeds[@"strings"][indexPath.row];
        cell.img.image = _feeds[@"images"][indexPath.row];
        cell.url = _feeds[@"urls"][indexPath.row];
        if (cell == nil)
            cell = [[StandardTableViewCell alloc] initWithStyle:nil reuseIdentifier:iden];
        return cell;
    } else if ([cl isSubclassOfClass:[TodayCellTableViewCell class]]) {
        static NSString *iden = @"today";
        TodayCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
        cell.dateTag.text = self.refreshControl.attributedTitle.string;
        cell.messageBody.text = _feeds[@"strings"][indexPath.row];
        cell.img.image = _feeds[@"images"][indexPath.row];
        return cell;
    } else if ([cl isSubclassOfClass:[ScheduleTableViewCell class] ]) {

        static NSString *iden = @"schedule";
        ScheduleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
        if ([_feeds[@"dayScheds"] isKindOfClass:[NSMutableArray class]]) {
            if ([_feeds[@"dayScheds"] count] == 2) {
                [cell.today setImageWithURL:[NSURL URLWithString:_feeds[@"dayScheds"][0]] placeholderImage:[UIImage imageNamed:@"loading-schedule.png"]];
                [cell.tomorrow setImageWithURL:[NSURL URLWithString:_feeds[@"dayScheds"][1]] placeholderImage:[UIImage imageNamed:@"loading-schedule.png"]];
            }
        }
        return cell;
    }

    if (cell.textLabel.text) return cell;
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id cl = ([_feeds[@"class"] isKindOfClass:[NSMutableArray class]]) ? [_feeds[@"class"][indexPath.row] class] : [UITableViewCell class];
    if ([cl isSubclassOfClass:[StandardTableViewCell class]]) return 46.0f;
    else if ([cl isSubclassOfClass:[TodayCellTableViewCell class]]) return 106.0f;
    else if ([cl isSubclassOfClass:[ScheduleTableViewCell class]]) return 444.0f;
    else return 46.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[tableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString:@"schedule"]) {
        FormsViewerViewController *vc = [[FormsViewerViewController alloc] initWithFullURL:@"http://campus.mbs.net/mbs/widget/daySched.php"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    if ([[tableView cellForRowAtIndexPath:indexPath].reuseIdentifier isEqualToString:@"standard"]) {
        NSString *str = [(StandardTableViewCell *)([tableView cellForRowAtIndexPath:indexPath]) url];
        if (str) {
            FormsViewerViewController *vc;
            if ([str isEqualToString:@"ACTDates"])
                vc = [[FormsViewerViewController alloc] initWithStringForURL:str];
            else vc = [[FormsViewerViewController alloc] initWithStringForURL:str];
            [self.navigationController pushViewController:vc animated:YES];
        }
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
    NSMutableArray *poss = [NSMutableArray array];
    for (int x = 6; x < 13; x++)
        [poss addObject:[NSString stringWithFormat:@"%d", x]];
    NSString *grade = [alertView textFieldAtIndex:0].text;
    if ([poss containsObject:grade]) {
        [[NSUserDefaults standardUserDefaults] setObject:((grade.integerValue < 9) ? @"MS" : @"US") forKey:@"division"];
        [SVProgressHUD showSuccessWithStatus:@"Great! Now you'll get customized content :)"];
        [self update];
        return;
    }

    [self noSavedGrade:@"Whoops! Please try again."];
}

@end