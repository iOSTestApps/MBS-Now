//
//  AddItemViewController.m
//  Community Service
//
//  Created by Lucas Fagan on 5/15/14.
//  Copyright (c) 2014 Lucas Fagan. All rights reserved.
//

#import "CSAddItemViewController.h"

@interface AddItemViewController ()
//@property (nonatomic) NSString *editingLink;
@end

@implementation AddItemViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *url = [NSURL URLWithString:@"http://campus.mbs.net/mbsnow/home/service.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    self.webView.delegate = self;
    [SVProgressHUD showWithStatus:@"Loading"];
}

#pragma mark - WebView delegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dagnabbit!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
    [alert show];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [SVProgressHUD showWithStatus:@"Working..."];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [SVProgressHUD dismiss];
    NSString *h = webView.request.URL.host;
    if ([h isEqualToString:@"docs.google.com"]) {
        NSString *html = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
        NSString *edit = [[html componentsSeparatedByString:@"<a class=\"ss-bottom-link\" href=\""][1] componentsSeparatedByString:@"\" title=\"Save this link to edit your response later.\""][0];
        [[UIPasteboard generalPasteboard] setString:edit];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://grahamd.net/service_success.php?e=%@", edit]]]];
        return;
    }
}

//- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
//    if (alertView.tag == 7 && buttonIndex == 1) {
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
//    if (alertView.tag == 7 && buttonIndex == 0) {
//        NSArray *objectsToShare = @[self.editingLink];
//        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
//
//        NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
//                                        UIActivityTypePostToWeibo,
//                                        UIActivityTypePrint,
//                                        UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
//                                        UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
//                                        UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
//        controller.excludedActivityTypes = excludedActivities;
//
//        [controller setCompletionHandler:^(NSString *act, BOOL done)
//         {
//             NSLog(@"act type %@",act);
//             /*NSString *ServiceMsg = nil;
//              if ([act isEqualToString:UIActivityTypeMail])  {}*/
//             if (done) {
////                 self.savedEditingLink = YES;
//             }
//         }];
//        [self presentViewController:controller animated:YES completion:nil];
//    }
//}

#pragma mark - Actions
- (IBAction)done:(id)sender {
    [SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) return YES;
    return (toInterfaceOrientation == UIDeviceOrientationPortrait) ? YES : NO;
}

#pragma mark - Motion
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake && [_webView.request.URL.host isEqualToString:@"grahamd.net"]) {
        MFMailComposeViewController *composerView = [[MFMailComposeViewController alloc] init];
        composerView.mailComposeDelegate = self;
        [composerView setModalPresentationStyle:UIModalPresentationFormSheet];
        [composerView setSubject:@"Service opportunity editing link"];
        [composerView setMessageBody:[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"] isHTML:YES];
        [self presentViewController:composerView animated:YES completion:nil];
    }
}

#pragma mark - Mail
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    // dismiss MFMailVC (cancelled or saved)
    [self dismissViewControllerAnimated:YES completion:nil];

    if (result == MFMailComposeResultSent) [SVProgressHUD showSuccessWithStatus:@"Sent!"];
    else if (result == MFMailComposeResultFailed) [SVProgressHUD showErrorWithStatus:@"Nuts; failed to send!"];
}

@end