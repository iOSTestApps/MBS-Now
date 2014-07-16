//
//  FormsViewerViewController.m
//  MBS Now
//
//  Created by gdyer on 3/20/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "FormsViewerViewController.h"
#import "UIView+Toast.h"
#import <AudioToolbox/AudioServices.h>
#define LUNCH_ROOT @"https://github.com/gdyer/MBS-Now/raw/master/Resources/Lunch/"
@implementation FormsViewerViewController
@synthesize _webView, receivedData;

- (id)initWithStringForURL:(NSString *)stringForURL {
    extensionName = stringForURL;
    return [super initWithNibName:@"FormsViewerViewController_7"  bundle:nil];
}

- (id)initWithFullURL:(NSString *)full {
    finalURL = [NSURL URLWithString:full];
    return [super initWithNibName:@"FormsViewerViewController_7" bundle:nil];
}

- (id)initWithLunchDay:(NSString *)day showingTomorrow:(BOOL)late {
    dayName = day;
    showingTomorrow = late;
    return [super initWithNibName:@"FormsViewerViewController_7" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_webView setDelegate:self];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)];

    NSURLConnection *connection;
    if (!dayName) {
        finalURL = (finalURL) ? finalURL : [NSURL URLWithString:[NSString stringWithFormat:@"http://campus.mbs.net/mbsnow/home/forms/%@.pdf", extensionName]];
        connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:finalURL] delegate:self startImmediately:TRUE];
    } else {
        finalURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.pdf", LUNCH_ROOT, dayName]];
        connection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:finalURL] delegate:self startImmediately:TRUE];
    }

    if (connection) receivedData = [NSMutableData data];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:finalURL]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    showingTomorrow = NO;
    dayName = nil;
    [SVProgressHUD dismiss];
}

- (NSString *)dayNameFromDate:(NSDate *)d {
    NSDateFormatter *form = [[NSDateFormatter alloc] init];
    [form setDateFormat:@"EEEE"];
    return [form stringFromDate:d];
}


#pragma mark Connection
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [SVProgressHUD showWithStatus:@"Loading..."];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [SVProgressHUD dismiss];
    if (showingTomorrow && ![dayName isEqualToString:@""])
        [self.view makeToast:@"This is tomorrow's lunch. Shake your phone for today's." duration:3.0 position:@"bottom"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [SVProgressHUD dismiss];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [SVProgressHUD dismiss];
    [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([(NSHTTPURLResponse *)response statusCode] == 404) {
        if (![dayName isEqualToString:@""]) {
            [SVProgressHUD showErrorWithStatus:@"No menu this day!"];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"404 Error" message:@"We couldn't find the doc you selected. Please report this bug." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Report", nil];
        [alert show];
    }
}

#pragma mark Action button
- (void)share {
    if (sheet) {
        [sheet dismissWithClickedButtonIndex:-1 animated:YES];
        sheet = nil;
        return;
    }
    
    sheet = [[UIActionSheet alloc] initWithTitle:@"Share this doc" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Safari", @"Generate link", @"Email link", @"Print", nil];

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) [sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
    else [sheet showInView:_webView];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSURL *currentURL = [[_webView request] URL];

    switch (buttonIndex) {
        case 0:
            [_webView stopLoading];
            [[UIApplication sharedApplication] openURL:currentURL];
            break;
        case 1: {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:[finalURL absoluteString]];
            [SVProgressHUD showSuccessWithStatus:@"Copied"];
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            break;
        }
        case 2:
            [self mailLink];
            break;
        case 3: [self printWebPage:self];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    sheet = nil;
}

#pragma mark Mail
- (void)mailLink {
    if ([MFMailComposeViewController canSendMail] == YES) {
        MFMailComposeViewController *composerView = [[MFMailComposeViewController alloc] init];
        composerView.mailComposeDelegate = self;
        [composerView setModalPresentationStyle:UIModalPresentationFormSheet];
        [composerView setSubject:@"MBS Document"];

        [composerView setMessageBody:[NSString stringWithFormat:@"Here's a link to a document concerning Morristown-Beard School:\n%@", finalURL] isHTML:NO];
        [self presentViewController:composerView animated:YES completion:nil];

    } else [SVProgressHUD showErrorWithStatus:@"Device cannot send mail"];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    if (result == MFMailComposeResultSent)
        [SVProgressHUD showSuccessWithStatus:@"Queued for sending"];
    else if (result == MFMailComposeResultFailed)
        [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Printing
- (void)printWebPage:(id)sender {
    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if(!completed && error){
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Error in domain %@ with error code %ld", error.domain, (long)error.code]];
        }
    };
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = [finalURL absoluteString];
    printInfo.duplex = UIPrintInfoDuplexLongEdge;
    controller.printInfo = printInfo;
    controller.showsPageRange = YES;

    UIViewPrintFormatter *viewFormatter = [self._webView viewPrintFormatter];
    viewFormatter.startPage = 0;
    controller.printFormatter = viewFormatter;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) [controller presentFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES completionHandler:completionHandler];
    else [controller presentAnimated:YES completionHandler:completionHandler];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://campus.mbs.net/mbsnow/home/report.html"]]];
    else [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Shake
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake && showingTomorrow) {
        [self._webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@.pdf", LUNCH_ROOT, [self dayNameFromDate:[NSDate date]]]]]];
        showingTomorrow = NO;
    }
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) return YES;
    return (toInterfaceOrientation == UIDeviceOrientationPortrait) ? YES : NO;
}

- (BOOL)shouldAutorotate {
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? YES : NO;
}
             
@end