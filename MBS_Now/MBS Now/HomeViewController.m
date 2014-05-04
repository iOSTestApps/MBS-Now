//
//  HomeViewController.m
//  MBS Now
//
//  Created by Graham Dyer on 1/10/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import "HomeViewController.h"
#import "DataViewController.h"
#import "SettingsViewController.h"
#import "WebViewController.h"
#import "FormsViewerViewController.h"
#import "PhotoBrowser.h"
#import <AudioToolbox/AudioServices.h>

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@implementation HomeViewController
@synthesize receivedData;

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    NSInteger q = [[NSUserDefaults standardUserDefaults] integerForKey:@"dfl"];
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    versionLabel.text = [NSString stringWithFormat:@"You're running %@", [infoDict objectForKey:@"CFBundleShortVersionString"]];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        /*CHANGES WITH VERSIONS*/
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"361"] == NO) {
            PhotoBrowser *pb = [[PhotoBrowser alloc] init];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"361"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self presentViewController:pb animated:YES completion:nil];
            return;
        }
        /*CHANGES WITH VERSIONS*/
    }

    if (q == 1) {
        // first launch
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notifications" message:@"Notifications have changed. Would you like to receive alerts for formal dress days, A/B distinctions, and general announcements?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag = 11;
        [alert show];
        [[NSUserDefaults standardUserDefaults] setInteger:(q+1) forKey:@"dfl"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }

    if (q % AUTO == 0 && q != 0) {
        DataViewController *dvc = [[DataViewController alloc] init];
        NSString *escapedDataString = [[dvc generateData] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *urlString = [NSString stringWithFormat:@"http://campus.mbs.net/mbsnow/scripts/save.php?text_box=%@", escapedDataString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];

        [request setHTTPMethod:@"GET"];
        sendingData = [NSURLConnection connectionWithRequest:request delegate:self];
        if (sendingData)
            [SVProgressHUD showWithStatus:@"Sending data"];
        // even though this doesn't account for a failure to send, it's better to avoid a delay
        [[NSUserDefaults standardUserDefaults] setInteger:(q+1) forKey:@"dfl"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autoCheck"] == 0) {
        NSURL *myURL = [NSURL URLWithString:@"https://docs.google.com/spreadsheet/pub?key=0Ar9jhHUssWrpdGJSYTFjWWhDWndKQW0yckluTU5PX1E&output=csv"];
        NSURLRequest *request = [NSURLRequest requestWithURL:myURL
                                                 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                             timeoutInterval:20];
        meetingsConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }

    if ((q % 5 == 0) && q != 0) {
        NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/gdyer/MBS-Now/master/MBS_Now/MBS%20Now/MBS%20Now-Info.plist"];
        NSURLRequest *request = [NSURLRequest requestWithURL:url
                                                 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                             timeoutInterval:15];
        versionConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

- (void)viewDidLoad {
    // NOTE: content size for the scroll view is set in the storyboard file
    [super viewDidLoad];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad && ([UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeRight)) {
        _l1.textColor = [UIColor whiteColor];
    } else  {
        if (IS_IPHONE_5) {
            for (UILabel *chi in first)
                chi.textColor = [UIColor darkGrayColor];
        } else {for (UILabel *foo in first) foo.textColor = [UIColor whiteColor];}}

    NSString *foo;
    NSString *defaultColor = [[NSUserDefaults standardUserDefaults] objectForKey:@"buttonColor"];
    NSArray *array = [NSArray arrayWithObjects:@"black", @"grey", @"tan", nil];
    // This is set in SettingsVC
    foo = ([array containsObject:defaultColor]) ? defaultColor : @"grey";
    [self setUpButtonsWithColor:foo andButtons:buttons];
}

- (void)setUpButtonsWithColor:(NSString *)name andButtons:(NSArray *)buttonArray {
    
    UIImage *buttonImage = [[UIImage imageNamed:[NSString stringWithFormat:@"%@Button.png", name]]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:[NSString stringWithFormat:@"%@ButtonHighlight.png", name]]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];

    for (int x = 0; x < buttonArray.count; x++) {
        [[buttonArray objectAtIndex:x] setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [[buttonArray objectAtIndex:x] setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    }
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

- (void)countdown {
    NSString *startSchool = @"2013-09-03";
    NSString *endSchool = @"2014-05-31";
    NSDate *current = [NSDate date];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];

    NSDate *endDate = [formatter dateFromString:endSchool];
    NSDate *startDate = [formatter dateFromString:startSchool];

    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    if ([endDate compare:current] == NSOrderedDescending && [startDate compare:current] == NSOrderedAscending) {
        // school's in session
        components = [gregorianCalendar components:NSDayCalendarUnit fromDate:current toDate:endDate options:0];
        messagePart = @"ends";
    } else if ([startDate compare:current] == NSOrderedDescending) {
        // summer
        components = [gregorianCalendar components:NSDayCalendarUnit fromDate:current toDate:startDate options:0];
        messagePart = @"starts";
    } else if ([current compare:endDate] == NSOrderedDescending) {
        messagePart = @"UPDATE MBS NOW";
    }

    days = [components day];

    if ([messagePart isEqualToString:@"starts"]) {
        bImage = [UIImage imageNamed:@"sun@2x.png"];
    } else {
        bImage = [UIImage imageNamed:@"backpack@2x.png"];
    }
}

#pragma mark - Actions
- (IBAction)pushedCountdown:(id)sender {
    [self countdown];
    [SVProgressHUD showImage:bImage status:[NSString stringWithFormat:@"School %@ in %ld days", messagePart, (long)days]];
}

- (IBAction)pushedCredentials:(id)sender {
    [self performSegueWithIdentifier:@"credentials" sender:self];
}

- (IBAction)pushedLibrary:(id)sender {
    WebViewController *wvc = [[WebViewController alloc] initWithURL:[NSURL URLWithString:@"http://morristown-beard.mlasolutions.com/oasis/catalog/%28S%28xrjcvnndg0iq4k3du5xzob2c%29%29/Default.aspx?installation=Default"]];
    [self presentViewController:wvc animated:YES completion:nil];
}

- (IBAction)pushedSpecial:(id)sender {
    [SVProgressHUD showWithStatus:@"Checking"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://campus.mbs.net/mbsnow/home/forms/Special.pdf"] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:20];
    connection1 = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE];
    if (connection1) {
        receivedData = [NSMutableData data];
    }
}

- (IBAction)pushedNotify:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Instant Alert" message:@"Would you like to fire a notification with today's schedule?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes, Upper School", @"Yes, Middle School", nil];
    alert.tag = 12;
    [alert show];
}

#pragma mark Connections
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == sendingData) {
        [SVProgressHUD dismiss];
        NSString *echo = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if ([echo isEqualToString:@"Success"]) {
            [SVProgressHUD showSuccessWithStatus:@"Done; thanks!"];
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastSend"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection != meetingsConnection && connection != versionConnection) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == connection1) {
        if ([(NSHTTPURLResponse *)response statusCode] == 404) {
            [SVProgressHUD showImage:[UIImage imageNamed:@"clock@2x.png"] status:@"No special shedules this week"];
        } else {
            FormsViewerViewController *fvvc = [[FormsViewerViewController alloc] initWithStringForURL:@"Special"];
            fvvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:fvvc animated:YES completion:nil];
        }
    } else if (connection != meetingsConnection && connection != versionConnection) {
        [SVProgressHUD showSuccessWithStatus:@"Connected"];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == connection2) {
        NSURLResponse *response;
        NSError *error;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:connection.currentRequest returningResponse:&response error:&error];

        NSString *data;
        if (responseData) {
            [SVProgressHUD dismiss];
            [SVProgressHUD showSuccessWithStatus:@"Connected"];
            data = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        } else {
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:@"No data available. Please report a bug"];
            return;
        }

        if ([data isEqualToString:@""]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No schedule" message:@"There's no schedule available for today." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }

        data = [data stringByReplacingOccurrencesOfString:@"|Filler|Filler|" withString:@"|"];
        data = [data stringByReplacingOccurrencesOfString:@"Advisors|" withString:@""];
        data = [data stringByReplacingOccurrencesOfString:@"Advisory|" withString:@""];
        data = [data stringByReplacingOccurrencesOfString:@"Flex|" withString:@""];
        data = [data stringByReplacingOccurrencesOfString:@"|" withString:@" | "];
        NSDate *fireDate = [[NSDate date] dateByAddingTimeInterval:30];

        UILocalNotification *lcl = [[UILocalNotification alloc] init];
        lcl.fireDate = fireDate;
        lcl.alertBody = data;
        lcl.soundName = UILocalNotificationDefaultSoundName;
        lcl.alertAction = @"Open";
        lcl.timeZone = [NSTimeZone defaultTimeZone];

        [[UIApplication sharedApplication] scheduleLocalNotification:lcl];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Notification will fire in 30 seconds. Please lock your device and leave MBS Now to ensure it will be displayed on your lock screen." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alert show];

    } else if (connection == meetingsConnection) {
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
    } else if (connection == versionConnection) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL:connection.currentRequest.URL];
        NSInteger v = [[[dict objectForKey:@"CFBundleShortVersionString"] stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue];
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *f = [infoDict objectForKey:@"CFBundleShortVersionString"];
        if (v > [[f stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"An update is available" message:@"MBS Now just got better. Please update!" delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Update", nil];
            NSInteger q = [[NSUserDefaults standardUserDefaults] integerForKey:@"dfl"];
            [[NSUserDefaults standardUserDefaults] setInteger:(q+1) forKey:@"dfl"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            versionLabel.text = @"An update is available";
            alert.tag = 13;
            [alert show];
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

#pragma mark - Alert
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 11) {
        if (buttonIndex == 1) {
            SettingsViewController *svc = [[SettingsViewController alloc] init];
            // passing in 1 does not display an SVProgressHUD -- we'll handle that here
            // the actual defaults are saved in the SVC methods
            [svc setUpAB_Notifications:1];
            [svc setUpDressUpNotifications:1 withHour:@" 07 00"];
            [svc setUpGeneralNotifications:1];

            [SVProgressHUD showSuccessWithStatus:@"Select a receipt time (currently 7 AM) or modify your choice in Settings."];
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"dressUps"];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"abs"];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"general"];

            [SVProgressHUD showSuccessWithStatus:@"Alright. Modify your choice in Settings"];
        }

        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if (alertView.tag == 12 && buttonIndex != 0) {
        [SVProgressHUD showWithStatus:@"Working"];
        // instant schedule notification
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        [dateFormat setTimeZone:[NSTimeZone defaultTimeZone]];
        NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
        NSString *foo = (buttonIndex == 1) ? @"us" : @"ms";

        [self scheduleFromDate:dateString andDivison:foo];
    } else if (alertView.tag == 13 && buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/id617180145?mt=8"]];
    }
}

#pragma mark - Rotation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            _l1.textColor = [UIColor darkGrayColor];
            _l2.textColor = [UIColor darkGrayColor];
        } else {
            _l1.textColor = [UIColor whiteColor];
            _l2.textColor = [UIColor whiteColor];
        }
        if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            for (UILabel *label in first) {
                label.textColor = [UIColor darkGrayColor];
            }
            _l1.textColor = [UIColor darkGrayColor];
        } else {
            for (UILabel *label in first) {
                label.textColor = [UIColor whiteColor];
            }
            _l1.textColor = [UIColor whiteColor];
        }
    }

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        if(toInterfaceOrientation == UIDeviceOrientationPortrait) return YES;
        return NO;
    }
}

#pragma mark Scroll View
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int q = scrollView.contentOffset.y;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if (IS_IPHONE_5) {
            if (q > 75) {
                for (UILabel *bar in second) {
                    bar.textColor = [UIColor darkGrayColor];
                }
                if (q > 186) {
                    for (UILabel *chi in third) {
                        chi.textColor = [UIColor darkGrayColor];
                    }
                    if (q > 314) {
                        for (UILabel *fox in fourth) {
                            fox.textColor = [UIColor darkGrayColor];
                        }
                    } else {
                        for (UILabel *fox in fourth) {
                            fox.textColor = [UIColor whiteColor];
                        }
                    }
                } else {
                    for (UILabel *chi in third) {
                        chi.textColor = [UIColor whiteColor];
                    }
                }
            } else {
                for (UILabel *bar in second) {
                    bar.textColor = [UIColor whiteColor];
                }
            }
        } else {
            if (q > 11) {
                for (UILabel *foo in first) {
                    foo.textColor = [UIColor darkGrayColor];
                }
                if (q > 119) {
                    for (UILabel *bar in second) {
                        bar.textColor = [UIColor darkGrayColor];
                    }
                    if (q > 232) {
                        for (UILabel *chi in third) {
                            chi.textColor = [UIColor darkGrayColor];
                        }
                        if (q > 362) {
                            for (UILabel *fox in fourth) {
                                fox.textColor = [UIColor darkGrayColor];
                            }
                        } else {
                            for (UILabel *fox in fourth) {
                                fox.textColor = [UIColor whiteColor];
                            }
                        }
                    } else {
                        for (UILabel *chi in third) {
                            chi.textColor = [UIColor whiteColor];
                        }
                    }
                } else {
                    for (UILabel *bar in second) {
                        bar.textColor = [UIColor whiteColor];
                    }
                }
            } else {
                for (UILabel *foo in first) {
                    foo.textColor = [UIColor whiteColor];
                }
            }
        }
    } else {
        // iPad
        if ([UIDevice currentDevice].orientation == UIInterfaceOrientationPortraitUpsideDown || ([UIDevice currentDevice].orientation == UIInterfaceOrientationPortrait)) {
            UIColor *foo = (q > 82) ? [UIColor darkGrayColor] : [UIColor whiteColor];
            for (UILabel *lbl in first) lbl.textColor = foo;
        } else {
            _l1.textColor = (q > 52) ? [UIColor darkGrayColor] : [UIColor whiteColor];
            UIColor *foo = (q > 170) ? [UIColor darkGrayColor] : [UIColor whiteColor];
            for (UILabel *lbl in first) lbl.textColor = foo;
            UIColor *bar = (q > 392) ? [UIColor darkGrayColor] : [UIColor whiteColor];
            for (UILabel *lbl in second) lbl.textColor = bar;
        }
    }
}

#pragma mark Schedule Notifcations
- (void)scheduleFromDate:(NSString *)formattedDate andDivison:(NSString *)division {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://campus.mbs.net/mbs/widget/dayPeriodsForMBSNow.php?day=%@&div=%@", formattedDate, division]]];
    connection2 = [NSURLConnection connectionWithRequest:request delegate:self];
    [request setHTTPMethod:@"GET"];
}

@end