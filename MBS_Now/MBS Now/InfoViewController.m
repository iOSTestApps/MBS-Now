//
//  InfoViewController.m
//  MBS Now
//
//  Created by gdyer on 1/21/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "InfoViewController.h"
#import "SVModalWebViewController.h"
#import "PhotoBrowser.h"
#import <MessageUI/MessageUI.h>

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(done:)];
    right.direction = UISwipeGestureRecognizerDirectionRight;
    [right setNumberOfTouchesRequired:1];
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) [self.view addGestureRecognizer:right];

    UIImage *buttonImage = [[UIImage imageNamed:@"greyButton.png"]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"greyButtonHighlight.png"]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];

    NSMutableArray *outlets = [NSMutableArray arrayWithObjects:_1, _2, _3, nil];

    for (int x = 0; x < outlets.count; x++) {
        [[outlets objectAtIndex:x] setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [[outlets objectAtIndex:x] setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    }

    control.selectedSegmentIndex = self.segueIndex;
    [self controlChange:self];
}

#pragma mark Actions
- (void)setUpMailWithTo:(NSString *)foo andSubject:(NSString *)bar {
    if ([MFMailComposeViewController canSendMail] == YES) {
        MFMailComposeViewController *composerView = [[MFMailComposeViewController alloc] init];
        composerView.mailComposeDelegate = self;
        [composerView setModalPresentationStyle:UIModalPresentationFormSheet];
        [composerView setToRecipients:@[foo]];
        [composerView setSubject:bar];

        NSString *iOSVersion = [[UIDevice currentDevice] systemVersion];
        NSString *device = [[UIDevice currentDevice] model];
        CGRect screen = [[UIScreen mainScreen] bounds];
        CGFloat screenW = screen.size.width;
        CGFloat screenH = screen.size.height;

        NSString *path = [[NSBundle mainBundle] pathForResource:@"contactme" ofType:@"html"];
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *body = [[NSString stringWithContentsOfFile:path encoding:NSMacOSRomanStringEncoding error:nil] stringByAppendingString:[NSString stringWithFormat:@"MBS Now: %@\niOS: %@\nCurrent device: %@\nDimensions: %.1f, %.1f</font></div></body></html>", [infoDict objectForKey:@"CFBundleShortVersionString"], iOSVersion, device, screenW, screenH]];
        [composerView setMessageBody:body isHTML:YES];
        [self presentViewController:composerView animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Your device cannot send mail. Email would be sent to %@", foo]  delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (IBAction)pushedLucas:(id)sender {
    [self setUpMailWithTo:@"lucasfagan@verizon.net" andSubject:@"MBS Now"];
}

- (IBAction)pushedVisitSite:(id)sender {
    SVModalWebViewController *wvc = [[SVModalWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://campus.mbs.net/mbsnow/home"]];
    [self presentViewController:wvc animated:YES completion:nil];
}

- (IBAction)pushedNew:(id)sender {
    PhotoBrowser *pb = [[PhotoBrowser alloc] init];
    [self presentViewController:pb animated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)controlChange:(id)sender {
    NSString *path;
    switch (control.selectedSegmentIndex) {
        case 0: {
            textView.userInteractionEnabled = NO;
            path = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info"
                                                                                      ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
            NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            path = [path stringByReplacingOccurrencesOfString:@"%@" withString:version];
            break;
        }
        case 1: {
            textView.userInteractionEnabled = YES;
            path = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AboutUs"
                                                                                      ofType:@"txt"]encoding:NSUTF8StringEncoding error:nil];
            break;
        }
        case 2: {
            textView.userInteractionEnabled = YES;
            path = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"clubInfo"
                                                                                      ofType:@"txt"]encoding:NSUTF8StringEncoding error:nil];
            break;
        }
    }
    [textView setText:path];
}

#pragma mark Mail
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    // dismiss MFMailVC (cancelled or saved)
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MFMailComposeResultSent) [SVProgressHUD showSuccessWithStatus:@"Thanks!"];
    else if (result == MFMailComposeResultFailed) [SVProgressHUD showErrorWithStatus:@"Failed to send!"];
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) return YES;
    return (toInterfaceOrientation == UIDeviceOrientationPortrait) ? YES : NO;
}

@end