//
//  DataViewController.m
//  MBS Now
//
//  Created by gdyer on 7/19/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "DataViewController.h"
#import "SVWebViewController.h"
#import "SimpleWebViewController.h"
@implementation DataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    q = [[NSUserDefaults standardUserDefaults] integerForKey:@"four-dfl"];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"Data" ofType:@"txt"];
    [textView setText:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil]];

    [self setUpButtons:@"grey" andButton:_1];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"book-7-active.png"] style:UIBarButtonItemStylePlain target:self action:@selector(history:)];
}

- (void)setUpButtons:(NSString *)name andButton:(UIButton *)button {
    UIImage *buttonImage = [[UIImage imageNamed:[NSString stringWithFormat:@"%@Button.png", name]]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:[NSString stringWithFormat:@"%@ButtonHighlight.png", name]]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
}

#pragma mark Generate data
- (NSString *)generateData {
    NSString *systemName = [[UIDevice currentDevice] systemName];
    NSString *deviceName = [[UIDevice currentDevice] name];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSString *model = [[UIDevice currentDevice] model];

    CGRect screen = [[UIScreen mainScreen] bounds];
    CGFloat screenW = screen.size.width;
    CGFloat screenH = screen.size.height;

    NSInteger forms = [[NSUserDefaults standardUserDefaults] integerForKey:@"formsTapped"];
    NSInteger offline = [[NSUserDefaults standardUserDefaults] integerForKey:@"schedulesTapped"];
    NSInteger contacts = [[NSUserDefaults standardUserDefaults] integerForKey:@"contactsTapped"];
    NSInteger rsvps = [[NSUserDefaults standardUserDefaults] integerForKey:@"rsvps"];

    BOOL sentBefore = [[NSUserDefaults standardUserDefaults] boolForKey:@"sent"];

    NSInteger ms = [[NSUserDefaults standardUserDefaults] integerForKey:@"msGrade"];

    NSString *color = [[NSUserDefaults standardUserDefaults] objectForKey:@"buttonColor"];

    BOOL formalNs = [[NSUserDefaults standardUserDefaults] boolForKey:@"dressUps"];
    BOOL abNs = [[NSUserDefaults standardUserDefaults] boolForKey:@"abs"];
    BOOL generalNs = [[NSUserDefaults standardUserDefaults] boolForKey:@"general"];

    NSInteger autoCheckClubs = ![[NSUserDefaults standardUserDefaults] integerForKey:@"autoCheck"];

    BOOL logsSaved = [[NSUserDefaults standardUserDefaults] integerForKey:@"loginsTapped"];

    NSInteger scheduleNotifs = [[NSUserDefaults standardUserDefaults] integerForKey:@"textScheduleNotifications"];
    NSInteger meetingsViewed = [[NSUserDefaults standardUserDefaults] integerForKey:@"meetingsViewed"];
    NSString *division = [[NSUserDefaults standardUserDefaults] objectForKey:@"division"];
    NSInteger selfDataExport = [[NSUserDefaults standardUserDefaults] integerForKey:@"selfDataExport"];
    NSInteger fullScheduleViewsFromTodayCell = [[NSUserDefaults standardUserDefaults] integerForKey:@"fullScheduleViewsFromTodayCell"];
    NSInteger serviceViews = [[NSUserDefaults standardUserDefaults] integerForKey:@"serviceViews"];
    NSInteger timeInPhotoBrowser = [[NSUserDefaults standardUserDefaults] integerForKey:@"timeInPhotoBrowser"];
    NSInteger lunchFromToday = [[NSUserDefaults standardUserDefaults] integerForKey:@"lunchFromToday"];

    NSString *dressTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"dressTime"];

    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    BOOL alwaysTwoDay = [[NSUserDefaults standardUserDefaults] boolForKey:@"alwaysTwoDay"];
    BOOL alwaysShowArticle = [[NSUserDefaults standardUserDefaults] boolForKey:@"alwaysShowArticle"];
    BOOL showTodayFirst = [[NSUserDefaults standardUserDefaults] boolForKey:@"showTodayFirst"];

    NSInteger todayReloads = [[NSUserDefaults standardUserDefaults] integerForKey:@"todayReloads"];
    NSInteger todayMoreTaps = [[NSUserDefaults standardUserDefaults] integerForKey:@"todayMoreViews"];
    NSString *string = [NSString stringWithFormat:@"\n\n\nSystem name %@, version %@, model %@, height %.2f, width %.2f, forms tapped %ld, offline tapped %ld, contacts tapped %ld, launches %ld, version %@, sent before %d, MS grade %ld, dress notifications %d, A/B notifications %d, General notifications %d, logins tapped %d, button color %@, club autocheck prefernce %ld, RSVP button taps %ld, text schedule notifications received %ld, club meetings viewed %ld, division %@, self-data exports %ld, full schedule views from Today image cell %ld, service postings viewed %ld, time spent in first what's new screen %ld, always show tomorrow's schedule in Today %d, lunch menu views from Today %ld, dress-up notification receipt time %@, always show news articles in Today %d, show Today as launch screen %d, Today reloads %ld, Today hamburger taps %ld, device name %@, recorded on %@",
        systemName, systemVersion, model, screenH, screenW, (long)forms, (long)offline, (long)contacts, (long)q, version, sentBefore, (long)ms, formalNs, abNs, generalNs, logsSaved, color, (long)autoCheckClubs, (long)rsvps, (long)scheduleNotifs, (long)meetingsViewed, division, (long)selfDataExport, (long)fullScheduleViewsFromTodayCell, (long)serviceViews, (long)timeInPhotoBrowser, alwaysTwoDay, (long)lunchFromToday, dressTime, alwaysShowArticle, showTodayFirst, (long)todayReloads, (long)todayMoreTaps, deviceName, [NSDate date]];

    return string;
}

#pragma mark Actions
- (IBAction)history:(id)sender {
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSend"];
    NSString *string;
    if (date) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd, HH:mm"];
        string = [NSString stringWithFormat:@"Last collected on %@. Next collection in %ld launches.", [formatter stringFromDate:date],
                  (AUTO - (q % AUTO))];
    } else
        string = [NSString stringWithFormat:@"Never collected before. First collection in %ld launch(es)", (AUTO - (q % AUTO))];
    [SVProgressHUD showImage:[UIImage imageNamed:@"book-7-active@2x.png"] status:string];
}
- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)pushedSend:(id)sender {
    if ([MFMailComposeViewController canSendMail] == YES) {
        MFMailComposeViewController *composerView = [[MFMailComposeViewController alloc] init];
        composerView.mailComposeDelegate = self;
        [composerView setModalPresentationStyle:UIModalPresentationFormSheet];
        [composerView setSubject:@"Your sample data"];

        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *version = [infoDict objectForKey:@"CFBundleShortVersionString"];

        [composerView addAttachmentData:[[self generateData] dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/rtf" fileName:[NSString stringWithFormat:@"Data_%@.txt", version]];

        [composerView setMessageBody:@"You'll be able to view the attachment on any computer. Devices with iOS 7 and later can natively view it. We only see the attachment data upon automatic uploads — nothing else." isHTML:NO];

        [self presentViewController:composerView animated:YES completion:nil];
    } else {
        UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"No email" message:@"This device cannot send email." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Copy to clipboard", nil];
        [a show];
    }
}

- (IBAction)pushedQuestion:(id)sender {
    NSString *s = @"http://campus.mbs.net/mbsnow/home/meta/privacy.php";
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        SVModalWebViewController *wvc = [[SVModalWebViewController alloc] initWithAddress:s];
        [self presentViewController:wvc animated:YES completion:nil];
        return;
    }
    
    SimpleWebViewController *wvc = [[SimpleWebViewController alloc] initWithURL:[NSURL URLWithString:s]];
    [self presentViewController:wvc animated:YES completion:nil];
}

#pragma mark Mail
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    // dismiss MFMailVC (cancelled or saved)
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"selfDataExport"]) {
        // first time copying credentials
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"selfDataExport"];
    } else {
        NSInteger f = [[NSUserDefaults standardUserDefaults] integerForKey:@"selfDataExport"];
        [[NSUserDefaults standardUserDefaults] setInteger:(f+1) forKey:@"selfDataExport"];
    }

    [self dismissViewControllerAnimated:YES completion:nil];

    if (result == MFMailComposeResultSent) [SVProgressHUD showSuccessWithStatus:@"Sent"];
    else if (result == MFMailComposeResultFailed) [SVProgressHUD showErrorWithStatus:@"Failed to send"];
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) return YES;
    return (toInterfaceOrientation == UIDeviceOrientationPortrait) ? YES : NO;
}

#pragma mark Alert view
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[UIPasteboard generalPasteboard] setString:[self generateData]];
        [SVProgressHUD showSuccessWithStatus:@"Copied. Tap and hold in any text field to paste."];
    }
}

@end