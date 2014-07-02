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


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *url = [NSURL URLWithString:@"https://docs.google.com/forms/d/1j2vn9S6tqa4gDYPd7v3d_zZJARIZnsO_kIzLDw5t9hY/viewform?usp=send_form"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    self.webView.delegate = self;
    self.savedEditingLink = NO;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, there's a problem with the page. Please check internet connection and try again" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
    [alert show];
}
- (IBAction)donePressed:(id)sender {
    NSString *html = [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    if ([html rangeOfString:@"option value"].location == NSNotFound && self.savedEditingLink == NO) {
        self.editingLink = [html substringWithRange:NSMakeRange(298, 154)];
        NSLog(@"%@",self.editingLink);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Meeting Created" message:@"You have successfully added a community service opportunity. (Note: This will take up to 5 minutes to appear in the app.) In order edit it in the future, you will need to save the editing link. If it is not saved, you will have to contact Lucas Fagan to make changes." delegate:self cancelButtonTitle:@"Save link" otherButtonTitles:@"Don't save", nil];
        alert.tag = 7;
        [alert show];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
   
    
    
    
}
-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 7 && buttonIndex == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    if (alertView.tag == 7 && buttonIndex == 0) {
        NSArray *objectsToShare = @[self.editingLink];
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
        
        NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook,
                                        UIActivityTypePostToWeibo,
                                        UIActivityTypePrint,
                                        UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                        UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                        UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
        controller.excludedActivityTypes = excludedActivities;
    
        [controller setCompletionHandler:^(NSString *act, BOOL done)
         {
             NSLog(@"act type %@",act);
             /*NSString *ServiceMsg = nil;
             if ([act isEqualToString:UIActivityTypeMail])  {}*/
             if (done) {
                 self.savedEditingLink = YES;
             }
         }];
        [self presentViewController:controller animated:YES completion:nil];
    }
    
}
@end
