//
//  CalViewController.m
//  MBS Now
//
//  Created by gdyer on 1/10/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "CalViewController.h"
#import <AudioToolbox/AudioServices.h>

@implementation CalViewController
@synthesize _webView;

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView.delegate = self;

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"msGrade"]) [self loadWithDefaults];
    else [self controlChange:self];

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        _navBar.topItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mutiply-sign.png"] style:UIBarButtonItemStylePlain target:self action:@selector(stop)];
        return;
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mutiply-sign.png"] style:UIBarButtonItemStylePlain target:self action:@selector(stop)];
}

- (void)loadWithDefaults {
    NSInteger q = [[NSUserDefaults standardUserDefaults] integerForKey:@"msGrade"];
    NSString *foo = [NSString stringWithFormat:@"http://mbshomework.wikispaces.com/%ldth+Grade", (long)q];
    urlToLoad = [NSURL URLWithString:foo];
    _control.selectedSegmentIndex = 1;

    NSURLRequest *request = [NSURLRequest requestWithURL:urlToLoad cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0f];

    [_webView loadRequest:request];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE];

    if (connection) self.receivedData = [NSMutableData data];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
    [_webView stopLoading];
}

#pragma mark Connection
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

#pragma mark Actions
- (IBAction)pushedReload:(id)sender {
    [_webView reload];
}

- (void)stop {
    [SVProgressHUD dismiss];
    [_webView stopLoading];
}

- (IBAction)controlChange:(id)sender {
    [_webView stopLoading];
    switch (_control.selectedSegmentIndex) {
        case 0:
            urlToLoad = [NSURL URLWithString:@"http://www.mbs.net/pagecalpop.cfm?p=1424&calview=grid&period=week"];
            break;
        case 1:
            urlToLoad = [NSURL URLWithString:@"http://mbs.net/groups.cfm"];
            break;
        case 2:
            urlToLoad = [NSURL URLWithString:@"http://www.mbs.net/pagecalpop.cfm?p=541&calview=grid&period=week"];
            break;
        case 3:
            urlToLoad = [NSURL URLWithString:@"http://www.nwjerseyac.com/g5-bin/client.cgi?G5genie=235&school_id=22"];
            break;
        default:
            break;
    }

    if (_control.selectedSegmentIndex == 1) {
        
           }

    NSURLRequest *request = [NSURLRequest requestWithURL:urlToLoad cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:30.0f];

    [_webView loadRequest:request];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE];

    if (connection) self.receivedData = [NSMutableData data];
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) return YES;
    return toInterfaceOrientation == UIDeviceOrientationPortrait;
}

#pragma mark Alert view
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {

    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"msGrade"]) {
        if (alertView.tag == 1) {
            // middle school alert
            if (buttonIndex == 1) {
                // save grade
                NSInteger q = [alertView textFieldAtIndex:0].text.integerValue;
                NSNumber *grade = [NSNumber numberWithInteger:q];
                NSArray *grades = @[[NSNumber numberWithInt:6], [NSNumber numberWithInt:7], [NSNumber numberWithInt:8]];
                if ([grades containsObject:grade]) {
                    [[NSUserDefaults standardUserDefaults] setInteger:q forKey:@"msGrade"];
                    [self loadWithDefaults];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You can change your grade in Settings. Just tap the gear icon from the Home tab." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                    [alert show];
                } else {
                    [SVProgressHUD showErrorWithStatus:@"Not an MS grade. Tap 'Public' and then 'HW' to try again"];
                }
            }
        } 
    }
}

@end