//
//  SimpleWebViewController.m
//  MBS Now
//
//  Created by Graham Dyer on 10/31/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import "SimpleWebViewController.h"
#import <AudioToolbox/AudioServices.h>

@implementation SimpleWebViewController
@synthesize _webView, receivedData;

BOOL edit;

- (void)viewDidLoad
{
    [_webView setDelegate:self];
    _webView.multipleTouchEnabled = NO;
    [super viewDidLoad];

    NSURLRequest *request = [NSURLRequest requestWithURL:urlToLoad  cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0f];
    [_webView loadRequest:request];

    // create a connection from the request to get data asynchronously
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE];
    if (connection) {
        receivedData = [NSMutableData data];
    }
}

- (id)initWithURL:(NSURL *)url {
    urlToLoad = url;
    return (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) ? [super initWithNibName:@"SimpleWebViewController_7"  bundle:nil] : [super initWithNibName:@"SimpleWebViewController_6"  bundle:nil];
}

- (id)init {
    return [self initWithURL:[NSURL URLWithString:@"http://mbs.net"]];
}


#pragma mark Connections
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [SVProgressHUD showWithStatus:@"Loading"];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([webView.request.URL.absoluteString isEqualToString:@"http://campus.mbs.net/mbsnow/home/report.html"]) {
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        [SVProgressHUD showImage:[UIImage imageNamed:@"bug.png"] status:[NSString stringWithFormat:@"FYI: you're running %@ on iOS %@", [infoDict objectForKey:@"CFBundleShortVersionString"], [UIDevice currentDevice].systemVersion]];
    } else if ([webView.request.URL.host isEqualToString:@"docs.google.com"] && [self.specifier isEqualToString:@"rem"]) {
        // they just came from creating a meeting; ask to edit later.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Meeting created!" message:@"Would you like to add the ability to edit this meeting later? Note: it will take up to 5 minutes for it to go live." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag = 2;
        [alert show];
    } else if (edit == YES) {
        // are on the edit page
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Next step" message:@"We need to send you a link to this page. How would you like us to do that?" delegate:self cancelButtonTitle:@"Never mind" otherButtonTitles:@"Copy to clipboard", @"Send in email", nil];
        alert.tag = 3;
        [alert show];
    } else if ([webView.request.URL.host isEqualToString:@"docs.google.com"] && [self.specifier isEqualToString:@"bug"]) {
        // bug has been reported
        [self dismissViewControllerAnimated:YES completion:nil];
        [SVProgressHUD showSuccessWithStatus:@"Bug reported. Thanks for supporting MBS Now!"];
    } else
        [SVProgressHUD dismiss];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [SVProgressHUD dismiss];
    [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([(NSHTTPURLResponse *)response statusCode] == 404) {
        [SVProgressHUD dismiss];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"404 Error" message:@"What you're looking for can't be found. Report this bug!" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Report", nil];
        alert.tag = 4;
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

- (IBAction)reload:(id)sender {
    [_webView reload];
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        return YES;
    else {
        if(toInterfaceOrientation == UIDeviceOrientationPortrait) return YES;
        return NO;
    }
}

- (BOOL)shouldAutorotate {
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? YES : NO;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            [SVProgressHUD showImage:[UIImage imageNamed:@"finger-touch.png"] status:@"Tap 'Edit your response' on this page (zoom in if necessary)."];
            edit = YES;
            self.specifier = nil;
        } else
            [self dismissViewControllerAnimated:YES completion:nil];

    } else if (alertView.tag == 3) {
        edit = NO;
        if (buttonIndex == 1) {
            // copy to clipboard
            UIPasteboard *pb = [UIPasteboard generalPasteboard];
            pb.string = _webView.request.URL.absoluteString;
            [SVProgressHUD showSuccessWithStatus:@"Copied. Paste the link into any browser or text editor."];
        } else if (buttonIndex == 2) {
            // send email with link
            if ([MFMailComposeViewController canSendMail] == YES) {
                MFMailComposeViewController *composerView = [[MFMailComposeViewController alloc] init];
                composerView.mailComposeDelegate = self;
                [composerView setModalPresentationStyle:UIModalPresentationFormSheet];
                [composerView setSubject:@"Editing link"];
                [composerView setMessageBody:_webView.request.URL.absoluteString isHTML:NO];
                [self presentViewController:composerView animated:YES completion:nil];
            } else {
                // device cannot send mail
                UIPasteboard *pb = [UIPasteboard generalPasteboard];
                pb.string = _webView.request.URL.absoluteString;
                [SVProgressHUD showErrorWithStatus:@"Your device cannot send mail. We've copied the link to your clipboard. Paste the link into any browser or text editor."];
            }
        } else {
            UIPasteboard *pb = [UIPasteboard generalPasteboard];
            pb.string = _webView.request.URL.absoluteString;
            [SVProgressHUD showSuccessWithStatus:@"Just in case you did that by mistake, the link has been copied."];
            [_webView stopLoading];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } else if (buttonIndex == 1 && alertView.tag == 4)
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://campus.mbs.net/mbsnow/home/report.html"]]];
}

#pragma mark Mail
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    if (result == MFMailComposeResultSent)
        [SVProgressHUD showSuccessWithStatus:@"Queued for sending."];
    else if (result == MFMailComposeResultCancelled) {
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        pb.string = _webView.request.URL.absoluteString;
        [SVProgressHUD showErrorWithStatus:@"You deleted the draft. No worries; the editing link has been copied to your clipboard!"];
    }
    else if (result == MFMailComposeResultFailed) {
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        pb.string = _webView.request.URL.absoluteString;
        [SVProgressHUD showErrorWithStatus:@"Message failed to send. Editing link has been copied to your clipboard."];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end