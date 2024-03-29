//
//  AddItemViewController.m
//  MBS Now
//
//  Created by Lucas Fagan on 5/15/14.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "AddItemViewController.h"
@implementation AddItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *url = [NSURL URLWithString:_addressInit];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    self.webView.delegate = self;
    [SVProgressHUD showWithStatus:@"Loading..."];
    self.navBar.topItem.title = [NSString stringWithFormat:@"Add a %@", _nameInit];
}

#pragma mark WebView delegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Dagnabbit!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
    [alert show];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [SVProgressHUD showWithStatus:@"Working..."];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [SVProgressHUD dismiss];
    NSLog(@"(%@)", _webView.request.URL.host);
    NSString *h = webView.request.URL.host;
    if ([h isEqualToString:@"docs.google.com"]) {
        NSString *html = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
        edit = [[html componentsSeparatedByString:@"<a class=\"ss-bottom-link\" href=\""][1] componentsSeparatedByString:@"\" title=\"Save this link to edit your response later.\""][0];
        [[UIPasteboard generalPasteboard] setString:edit];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://campus.mbs.net/mbsnow/scripts/item_success.php?e=%@&n=%@", edit, [_nameInit stringByReplacingOccurrencesOfString:@" " withString:@"%20"]]]]];

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

#pragma mark Actions
- (IBAction)done:(id)sender {
    [SVProgressHUD dismiss];
    [_webView stopLoading];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) return YES;
    return (toInterfaceOrientation == UIDeviceOrientationPortrait) ? YES : NO;
}

#pragma mark Motion
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"(%@)", _webView.request.URL.host);
    if (motion == UIEventSubtypeMotionShake && [_webView.request.URL.host isEqualToString:@"campus.mbs.net"]) {
        if ([MFMessageComposeViewController canSendText] && ![MFMailComposeViewController canSendMail]) [self sendText];
        else if (![MFMessageComposeViewController canSendText] && [MFMailComposeViewController canSendMail]) [self sendEmail];
        else if (![MFMessageComposeViewController canSendText] && ![MFMailComposeViewController canSendMail]) [SVProgressHUD showErrorWithStatus:@"Your device can neither text nor email. Bummer!"];
        else {
            UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Text or email?" message:@"How would you like to share the URL?" delegate:self cancelButtonTitle:@"Neither" otherButtonTitles:@"SMS", @"Email", nil];
            [a show];
        }
    }
}

#pragma mark Messaging
- (void)sendEmail {
    MFMailComposeViewController *composerView = [[MFMailComposeViewController alloc] init];
    composerView.mailComposeDelegate = self;
    [composerView setModalPresentationStyle:UIModalPresentationFormSheet];
    [composerView setSubject:@"Service opportunity editing link"];
    [composerView setMessageBody:[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"] isHTML:YES];
    [self presentViewController:composerView animated:YES completion:nil];
}

- (void)sendText {
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    messageController.navigationBar.tintColor = [UIColor orangeColor];
    [messageController setBody:[NSString stringWithFormat:@"You're free to modify the %@ I just posted to MBS Now: %@", _nameInit, edit]];
    [self presentViewController:messageController animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    // dismiss MFMailVC (cancelled or saved)
    [self dismissViewControllerAnimated:YES completion:nil];

    if (result == MFMailComposeResultSent) [SVProgressHUD showSuccessWithStatus:@"Sent!"];
    else if (result == MFMailComposeResultFailed) [SVProgressHUD showErrorWithStatus:@"Nuts; failed to send!"];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result {
    if (result == MessageComposeResultFailed)
        [SVProgressHUD showErrorWithStatus:@"Failed to send SMS!"];

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Alert
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) [self sendText];
    else if (buttonIndex == 2) [self sendEmail];
}

@end