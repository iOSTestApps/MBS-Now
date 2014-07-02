//
//  AddItemViewController.m
//  Community Service
//
//  Created by Lucas Fagan on 5/15/14.
//  Copyright (c) 2014 Lucas Fagan. All rights reserved.
//

#import "CSAddItemViewController.h"

@interface AddItemViewController ()
@property (nonatomic) NSString *editingLink;
@property (nonatomic) BOOL savedEditingLink;
@end

@implementation AddItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *url = [NSURL URLWithString:@"http://grahamd.net/s/service.html"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    self.webView.delegate = self;
    self.savedEditingLink = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
    [alert show];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [SVProgressHUD showWithStatus:@"Working..."];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([webView.request.URL.host isEqualToString:@"docs.google.com"]) {
        // they just came from creating a meeting; ask to edit later.
        NSString *html = [webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
        _editingLink = [[html componentsSeparatedByString:@"<a class=\"ss-bottom-link\" href=\""][1] componentsSeparatedByString:@"\" title=\"Save this link to edit your response later.\">Edit your response</a>"][0];
        [[UIPasteboard generalPasteboard] setString:_editingLink];
        [SVProgressHUD showSuccessWithStatus:@"Created! An editing link has been copied to your clipboard. Paste it anywhere to allow others to modify your post."];
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [SVProgressHUD dismiss];
}

//- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
//    if (alertView.tag == 7 && buttonIndex == 1)
//        [self dismissViewControllerAnimated:YES completion:nil];
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
//             if ([act isEqualToString:UIActivityTypeMail])  {}*/
//             if (done) {
//                 self.savedEditingLink = YES;
//             }
//         }];
//        [self presentViewController:controller animated:YES completion:nil];
//    }
//    
//}

#pragma mark Actions
- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end