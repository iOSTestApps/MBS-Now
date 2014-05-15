//
//  WebViewController.m
//  MBS Now
//
//  Created by Graham Dyer on 3/2/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import "WebViewController.h"
#import <AudioToolbox/AudioServices.h>

@implementation WebViewController
@synthesize _webView, receivedData;

- (void)viewDidLoad {
    [_webView setDelegate:self];
    [super viewDidLoad];

    NSURLRequest *request = [NSURLRequest requestWithURL:urlToLoad  cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0f];
    [_webView loadRequest:request];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE];
    if (connection) receivedData = [NSMutableData data];
}

- (id)initWithURL:(NSURL *)url {
    urlToLoad = url;
    return (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) ? [super initWithNibName:@"WebViewController_7"  bundle:nil] : [super initWithNibName:@"WebViewController_6"  bundle:nil];
}

- (id)init {
    NSURL *standard = [NSURL URLWithString:@"http://campus.mbs.net/mbsnow/home/"];
    urlToLoad = standard;
    NSLog(@"Call initWithURL:, not init. MBS Now home will display by default");
    return (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) ? [super initWithNibName:@"WebViewController_7"  bundle:nil] : [super initWithNibName:@"WebViewController_6"  bundle:nil];
}

#pragma mark Connections
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

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([(NSHTTPURLResponse *)response statusCode] == 404) {
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"404 Error" message:@"If you're on campus.mbs.net, please report this bug from the Home tab." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark Actions
- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [_webView stopLoading];
    [SVProgressHUD dismiss];
    urlToLoad = nil;
}

- (IBAction)pushedBack:(id)sender {
    if ([_webView canGoBack] == NO) {
        [SVProgressHUD showErrorWithStatus:@"Can't go back"];
    } else {
        [_webView goBack];
    }
}

- (IBAction)reload:(id)sender {
    [_webView reload];
}

- (IBAction)pushedForward:(id)sender {
    if ([_webView canGoForward] == NO) {
        [SVProgressHUD showErrorWithStatus:@"Can't go forward"];
    } else {
        [_webView goForward];
    }
}

- (IBAction)pushedStop:(id)sender {
    [SVProgressHUD dismiss];
    [_webView stopLoading];
}

#pragma mark Action button
- (IBAction)output:(id)sender {
    if (sheet) {
        [sheet dismissWithClickedButtonIndex:-1 animated:YES];
        sheet = nil;
        return;
    }
    sheet = [[UIActionSheet alloc] initWithTitle:@"Output options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Safari", @"Copy URL text", nil];

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [sheet showFromBarButtonItem:output animated:YES];
    } else {
        [sheet showInView:_webView];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    NSURL *currentURL = [[_webView request] URL];

    switch (buttonIndex) {
        case 0: {
            [_webView stopLoading];
            [[UIApplication sharedApplication] openURL:currentURL];
            break;
        }
        case 1: {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:[urlToLoad absoluteString]];
            [SVProgressHUD showSuccessWithStatus:@"Copied"];
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            break;
        }
        default:
            break;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    sheet = nil;
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? YES : NO;
}

- (BOOL)shouldAutorotate {
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? YES : NO;
}

@end
