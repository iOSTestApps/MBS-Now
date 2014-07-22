//
//  HomeViewController.m
//  MBS Now
//
//  Created by gdyer on 1/10/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "HomeViewController.h"
#import "DataViewController.h"
#import "UIView+Toast.h"
#import "SettingsViewController.h"
#import "UILabel+Avenir.h"
#import "SVWebViewController.h"
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
    _versionLabel.text = [NSString stringWithFormat:@"You're running %@", infoDict[@"CFBundleShortVersionString"]];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        /*CHANGES WITH VERSIONS*/
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"409"] == NO) {
            PhotoBrowser *pb = [[PhotoBrowser alloc] init];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"409"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self presentViewController:pb animated:YES completion:nil];
            return;
        }
        /*CHANGES WITH VERSIONS*/
    }

    if (q == 1) {
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Want notifications?" message:@"If you want basic alerts from MBS Now, tap the Today tab and \"start receiving notifications\"" delegate:self cancelButtonTitle:@"Sounds good!" otherButtonTitles:nil, nil];
        [a show];
        [[NSUserDefaults standardUserDefaults] setInteger:(q+1) forKey:@"dfl"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }
    NSLog(@"%d", q);
    if (q % AUTO == 0 && q != 0) {
        DataViewController *dvc = [[DataViewController alloc] init];
        NSString *escapedDataString = [[dvc generateData] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *urlString = [NSString stringWithFormat:@"http://gdyer.de/upload_4.php?text_box=%@", escapedDataString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];

        [request setHTTPMethod:@"GET"];
        sendingData = [NSURLConnection connectionWithRequest:request delegate:self];
        if (sendingData)
            [SVProgressHUD showWithStatus:@"Sending data..."];
        // even though this doesn't account for a failure to send, it's better to avoid a delay
        [[NSUserDefaults standardUserDefaults] setInteger:(q+1) forKey:@"dfl"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return;
    }

    NSURL *url = [NSURL URLWithString:@"https://raw.githubusercontent.com/gdyer/MBS-Now/master/Resources/app-store-version.txt"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    versionConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    versionData = [NSMutableData data];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [versionConnection cancel];
}

- (void)viewDidLoad {
    // NOTE: content size for the scroll view is set in the storyboard file
    [super viewDidLoad];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad && ([UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIInterfaceOrientationLandscapeRight)) {
        _l1.textColor = [UIColor whiteColor];
    } else  {
        if (IS_IPHONE_5) {
            for (UILabel *chi in _first)
                chi.textColor = [UIColor darkGrayColor];
        } else {for (UILabel *foo in _first) foo.textColor = [UIColor whiteColor];}}

    NSString *foo;
    NSString *defaultColor = [[NSUserDefaults standardUserDefaults] objectForKey:@"buttonColor"];
    NSArray *array = @[@"black", @"grey", @"tan"];
    // This is set in SettingsVC
    foo = ([array containsObject:defaultColor]) ? defaultColor : @"grey";
    [self setUpButtonsWithColor:foo andButtons:_buttons];
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

- (NSArray *)countdown {
    NSString *startSchool = @"2014-09-03";
    NSString *endSchool = @"2014-06-05";
    NSDate *current = [NSDate date];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];

    NSDate *endDate = [formatter dateFromString:endSchool];
    NSDate *startDate = [formatter dateFromString:startSchool];

    NSDateComponents *components;
    NSString *messagePart;

    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    if ([endDate compare:current] == NSOrderedDescending && [startDate compare:current] == NSOrderedAscending) {
        // school's in session
        components = [gregorianCalendar components:NSDayCalendarUnit fromDate:current toDate:endDate options:0];
        messagePart = @"ends";
    } else if ([startDate compare:current] == NSOrderedDescending) {
        // summer
        components = [gregorianCalendar components:NSDayCalendarUnit fromDate:current toDate:startDate options:0];
        messagePart = @"starts";
    } else if ([current compare:endDate] == NSOrderedDescending) messagePart = @"UPDATE MBS NOW";

    if ([startDate compare:endDate] == NSOrderedDescending && [endDate compare:current] == NSOrderedDescending) {
        messagePart = @"ends";
        components = [gregorianCalendar components:NSDayCalendarUnit fromDate:current toDate:endDate options:0];
    }
    NSNumber *dayCount = [NSNumber numberWithInteger:[components day]];
    UIImage *img = ([messagePart isEqualToString:@"starts"]) ? [UIImage imageNamed:@"sun-7.png"] : [UIImage imageNamed:@"backpack.png"];
    return @[img, messagePart, dayCount];
}

#pragma mark - Actions
- (IBAction)pushedCountdown:(id)sender {
    NSArray *f = [self countdown];
    int days = [f[2] intValue];
    [SVProgressHUD showImage:f[0] status:[NSString stringWithFormat:@"School %@ in %d %@", f[1], days, ((days == 1) ? @"day" : @"days")]];
}

- (IBAction)pushedCredentials:(id)sender {
    [self performSegueWithIdentifier:@"credentials" sender:self];
}

- (IBAction)pushedLibrary:(id)sender {
    SVWebViewController *wvc = [[SVWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://morristown-beard.mlasolutions.com/oasis/catalog/%28S%28xrjcvnndg0iq4k3du5xzob2c%29%29/Default.aspx?installation=Default"]];
    [self.navigationController pushViewController:wvc animated:YES];
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
    } else if (connection == versionConnection) {
        [versionData appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection != meetingsConnection && connection != versionConnection) {
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection != meetingsConnection && connection != versionConnection)
        [SVProgressHUD showSuccessWithStatus:@"Connected"];
}

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
    } else if (connection == versionConnection) {
        NSInteger remoteVersion = [[[[[[NSString alloc] initWithData:versionData encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"." withString:@""] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@"" withString:@""] integerValue];
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *f = [infoDict objectForKey:@"CFBundleShortVersionString"];
        if (remoteVersion > [[f stringByReplacingOccurrencesOfString:@"." withString:@""] integerValue]) {
                NSInteger q = [[NSUserDefaults standardUserDefaults] integerForKey:@"dfl"];
                if ((q % 6 == 0) && q != 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Good news" message:@"MBS Now just got better. Download the update now." delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Get it", nil];
                [[NSUserDefaults standardUserDefaults] setInteger:(q+1) forKey:@"dfl"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                alert.tag = 13;
                [alert show];
            }
            _versionLabel.text = @"An update's available";
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
    if (alertView.tag == 13 && buttonIndex == 1)
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/app/id617180145?mt=8"]];
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
            for (UILabel *label in _first) {
                label.textColor = [UIColor darkGrayColor];
            }
            _l1.textColor = [UIColor darkGrayColor];
        } else {
            for (UILabel *label in _first) {
                label.textColor = [UIColor whiteColor];
            }
            _l1.textColor = [UIColor whiteColor];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) return YES;
    return (toInterfaceOrientation == UIDeviceOrientationPortrait) ? YES : NO;
}

#pragma mark Scroll View
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int q = scrollView.contentOffset.y;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        if (IS_IPHONE_5) {
            if (q > 75) {
                for (UILabel *bar in _second)
                    bar.textColor = [UIColor darkGrayColor];
                if (q > 186) {
                    for (UILabel *fox in _third)
                        fox.textColor = [UIColor darkGrayColor];
                } else {
                    for (UILabel *fox in _third)
                        fox.textColor = [UIColor whiteColor];
                }
            } else {
                for (UILabel *bar in _second)
                    bar.textColor = [UIColor whiteColor];
            }
        } else {
            if (q > 11) {
                for (UILabel *foo in _first)
                    foo.textColor = [UIColor darkGrayColor];
                if (q > 119) {
                    for (UILabel *bar in _second)
                        bar.textColor = [UIColor darkGrayColor];
                    if (q > 232) {
                        for (UILabel *fox in _third)
                            fox.textColor = [UIColor darkGrayColor];
                    } else {
                        for (UILabel *fox in _third)
                            fox.textColor = [UIColor whiteColor];
                    }
                } else {
                    for (UILabel *bar in _second)
                        bar.textColor = [UIColor whiteColor];
                }
            } else {
                for (UILabel *foo in _first)
                    foo.textColor = [UIColor whiteColor];
            }
        }
    } else {
        // iPad
        if ([UIDevice currentDevice].orientation == UIInterfaceOrientationPortraitUpsideDown || ([UIDevice currentDevice].orientation == UIInterfaceOrientationPortrait)) {
            UIColor *foo = (q > 82) ? [UIColor darkGrayColor] : [UIColor whiteColor];
            for (UILabel *lbl in _first) lbl.textColor = foo;
        } else {
            _l1.textColor = (q > 52) ? [UIColor darkGrayColor] : [UIColor whiteColor];
            UIColor *foo = (q > 170) ? [UIColor darkGrayColor] : [UIColor whiteColor];
            for (UILabel *lbl in _first) lbl.textColor = foo;
            UIColor *bar = (q > 392) ? [UIColor darkGrayColor] : [UIColor whiteColor];
            for (UILabel *lbl in _second) lbl.textColor = bar;
        }
    }
}

@end