//
//  DataViewController.m
//  MBS Now
//
//  Created by Graham Dyer on 7/19/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import "DataViewController.h"
#import "WebViewController.h"
@implementation DataViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    q = [[NSUserDefaults standardUserDefaults] integerForKey:@"dfl"];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"Data" ofType:@"txt"];
    [textView setText:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil]];

    [self setUpButtons:@"grey" andButton:_1];
}

- (void)setUpButtons:(NSString *)name andButton:(UIButton *)button {

    UIImage *buttonImage = [[UIImage imageNamed:[NSString stringWithFormat:@"%@Button.png", name]]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:[NSString stringWithFormat:@"%@ButtonHighlight.png", name]]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
}

#pragma mark Generate data
- (NSString *)generateData {

    NSString *systemName = [[UIDevice currentDevice] systemName];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    NSString *model = [[UIDevice currentDevice] model];

    CGRect screen = [[UIScreen mainScreen] bounds];
    CGFloat screenW = screen.size.width;
    CGFloat screenH = screen.size.height;

    NSInteger forms = [[NSUserDefaults standardUserDefaults] integerForKey:@"formsTapped"];
    NSInteger offline = [[NSUserDefaults standardUserDefaults] integerForKey:@"schedulesTapped"];
    NSInteger menus = [[NSUserDefaults standardUserDefaults] integerForKey:@"menusTapped"];
    NSInteger contacts = [[NSUserDefaults standardUserDefaults] integerForKey:@"contactsTapped"];

    BOOL sentBefore = [[NSUserDefaults standardUserDefaults] boolForKey:@"sent"];

    NSInteger ms = [[NSUserDefaults standardUserDefaults] integerForKey:@"msGrade"];

    NSString *color = [[NSUserDefaults standardUserDefaults] objectForKey:@"buttonColor"];

    BOOL formalNs = [[NSUserDefaults standardUserDefaults] boolForKey:@"dressUps"];
    BOOL abNs = [[NSUserDefaults standardUserDefaults] boolForKey:@"abs"];
    BOOL generalNs = [[NSUserDefaults standardUserDefaults] boolForKey:@"general"];

    BOOL logsSaved = [[NSUserDefaults standardUserDefaults] integerForKey:@"loginsTapped"];

    NSString *string = [NSString stringWithFormat:@"\n\n\nSystem name %@, version %@, model %@, height %.2f, width %.2f, forms tapped %ld, offline tapped %ld, menus tapped %ld, contacts tapped %ld, launches %ld, version %@, sent before %d, MS grade %ld, dress notifications %d, A/B notifications %d, General notifications %d, logins tapped %d, button color %@",
        systemName, systemVersion, model, screenH, screenW, (long)forms, (long)offline, (long)menus, (long)contacts, (long)q, VERSION_NUMBER, sentBefore, (long)ms, formalNs, abNs, generalNs, logsSaved, color];
    
    return string;
}

#pragma mark Actions
- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)pushedSend:(id)sender {

    if ([MFMailComposeViewController canSendMail] == YES) {
        MFMailComposeViewController *composerView = [[MFMailComposeViewController alloc] init];
        composerView.mailComposeDelegate = self;
        [composerView setModalPresentationStyle:UIModalPresentationFormSheet];
        [composerView setSubject:@"Your sample data"];
        
        [composerView addAttachmentData:[[self generateData] dataUsingEncoding:NSUTF8StringEncoding] mimeType:@"text/rtf" fileName:[NSString stringWithFormat:@"Data_%@.txt", VERSION_NUMBER]];

        [composerView setMessageBody:@"You'll be able to view the attachment on any computer. Devices with iOS 7 and later can natively view it. We only see the attachment data upon automatic uploads — nothing else." isHTML:NO];

        [self presentViewController:composerView animated:YES completion:nil];
    } else {
        [SVProgressHUD showErrorWithStatus:@"Device cannot send mail"];
    }
}

- (IBAction)pushedQuestion:(id)sender {
    WebViewController *wvc = [[WebViewController alloc] initWithURL:[NSURL URLWithString:@"http://campus.mbs.net/mbsnow/home/meta/privacy.php"]];
    [self presentViewController:wvc animated:YES completion:nil];
}

- (IBAction)pushedHistory:(id)sender {
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSend"];
    NSString *string;
    if (date) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd, HH:mm"];
        string = [NSString stringWithFormat:@"Last collected on %@. Next collection in %d launches.", [formatter stringFromDate:date], AUTO - (q % AUTO)];
    } else {
        string = [NSString stringWithFormat:@"Never collected before. First collection in %d launch(es)", AUTO - (q % AUTO)];
    }
    [SVProgressHUD showImage:[UIImage imageNamed:@"book-7-active@2x.png"] status:string];
}

#pragma mark Mail
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    // dismiss MFMailVC (cancelled or saved)
    [self dismissViewControllerAnimated:YES completion:nil];

    if (result == MFMailComposeResultSent) [SVProgressHUD showSuccessWithStatus:@"Sent"];
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