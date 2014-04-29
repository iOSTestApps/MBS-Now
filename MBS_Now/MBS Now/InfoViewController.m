//
//  InfoViewController.m
//  MBS Now
//
//  Created by Graham Dyer on 1/21/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import "InfoViewController.h"
#import "WebViewController.h"
#import "PhotoBrowser.h"
#import <MessageUI/MessageUI.h>

@implementation InfoViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

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

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

#pragma mark Actions
- (void)setUpMailWithTo:(NSString *)foo andSubject:(NSString *)bar {
    if ([MFMailComposeViewController canSendMail] == YES) {
        MFMailComposeViewController *composerView = [[MFMailComposeViewController alloc] init];
        composerView.mailComposeDelegate = self;
        [composerView setModalPresentationStyle:UIModalPresentationFormSheet];
        [composerView setToRecipients:[NSArray arrayWithObjects:foo, nil]];
        [composerView setSubject:bar];

        NSString *iOSVersion = [[UIDevice currentDevice] systemVersion];
        NSString *device = [[UIDevice currentDevice] model];
        CGRect screen = [[UIScreen mainScreen] bounds];
        CGFloat screenW = screen.size.width;
        CGFloat screenH = screen.size.height;

        NSString *path = [[NSBundle mainBundle] pathForResource:@"contactme" ofType:@"html"];
        NSString *body = [[NSString stringWithContentsOfFile:path encoding:NSMacOSRomanStringEncoding error:nil] stringByAppendingString:[NSString stringWithFormat:@"MBS Now: %@\niOS: %@\nCurrent device: %@\nDimensions: %.1f, %.1f</font></div></body></html>", VERSION_NUMBER, iOSVersion, device, screenW, screenH]];
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
    WebViewController *wvc = [[WebViewController alloc] initWithURL:[NSURL URLWithString:@"http://campus.mbs.net/mbsnow/home"]];
    [self presentViewController:wvc animated:YES completion:nil];
}

- (IBAction)pushedNew:(id)sender {
//    PhotoBrowser *pb = [[PhotoBrowser alloc] initWithImages:[NSArray arrayWithObjects:@"forms.png", @"rsvp.png", @"data.png", @"meetings.png", nil] showDismiss:YES description:[NSArray arrayWithObjects:@"Unified forms makes it easier to find things quickly. Add your own form instantly at campus.mbs.net/mbsnow/home/forms.", @"RSVPs are automatic. No more emails. Just enter your name, and we'll handle the rest.", @"Connections, such as automatic data uploads, are much smoother. No more lags.", @"We'll let you know when meetings have been changed or added. Create your own meetings from the 'Clubs' tab.", nil] title:@"What's new in 3.3.8"];
//    [self presentViewController:pb animated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)controlChange:(id)sender {
    NSString *path;
    switch (control.selectedSegmentIndex) {
        case 0: {
            // About us
            textView.userInteractionEnabled = NO;
            path = [[NSBundle mainBundle] pathForResource:@"Info"
                                                             ofType:@"txt"];
            break;
        }
        case 1: {
            textView.userInteractionEnabled = YES;
            path = [[NSBundle mainBundle] pathForResource:@"AboutUs"
                                                             ofType:@"txt"];
            break;
        }
        case 2: {
            textView.userInteractionEnabled = YES;
            path = [[NSBundle mainBundle] pathForResource:@"clubInfo"
                                                   ofType:@"txt"];
            break;
        }
        default: {
            [SVProgressHUD showErrorWithStatus:@"We messed up. Please report this bug."];
        }
    }

    [textView setText:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil]]
    ;
}

#pragma mark Mail
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {

    // dismiss MFMailVC (cancelled or saved)
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MFMailComposeResultSent) [SVProgressHUD showSuccessWithStatus:@"I'll reply soon"];
    else if (result == MFMailComposeResultFailed) [SVProgressHUD showErrorWithStatus:@"Failed to send"];
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        if(toInterfaceOrientation == UIDeviceOrientationPortrait) return YES;
        return NO;
    }
}

@end