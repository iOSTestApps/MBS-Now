//
//  SettingsViewController.m
//  MBS Now
//
//  Created by gdyer on 8/16/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "SettingsViewController.h"
#import "SimpleWebViewController.h"
#import "Today.h"
@interface SettingsViewController () {
    NSArray *colorsArray;
    NSArray *timesArray;
    NSArray *abbreviatedTimes;
}

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(pushedDone:)];
    right.direction = UISwipeGestureRecognizerDirectionRight;
    [right setNumberOfTouchesRequired:1];
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) [self.view addGestureRecognizer:right];

    for (UITableViewCell *cell in cells) {
        cell.backgroundColor = [UIColor colorWithWhite:1.0f alpha:.8f];
        cell.layer.shadowOffset = CGSizeMake(1, 0);
        cell.layer.shadowColor = [[UIColor blackColor] CGColor];
        cell.layer.shadowRadius = 1;
        cell.layer.shadowOpacity = .25;
        CGRect shadowFrame = cell.layer.bounds;
        CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
        cell.layer.shadowPath = shadowPath;
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
    }

    NSString *foo = ([[NSUserDefaults standardUserDefaults] objectForKey:@"buttonColor"]) ? [[NSUserDefaults standardUserDefaults] objectForKey:@"buttonColor"] : @"Not set — default";

    [colorButton setTitle:foo forState:UIControlStateNormal];
    abbreviatedTimes = @[@" 04 00", @" 05 00", @" 05 30", @" 06 00", @" 06 30", @" 06 45", @" 07 00"];

    nSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"dressUps"];
    nSwitch2.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"abs"];
    nSwitch3.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"general"];
    clubSwitch.on = ([[NSUserDefaults standardUserDefaults] integerForKey:@"autoCheck"] == 0) ? YES : NO;

    [self setUpButtonWithImageName:@"grey" andButton:msChange];

    [self setUpButtonWithImageName:(([[NSUserDefaults standardUserDefaults] objectForKey:@"division"] || [[NSUserDefaults standardUserDefaults] integerForKey:@"msGrade"]) ? @"grey" : @"black") andButton:msClear];

    dressTime.text = ([[NSUserDefaults standardUserDefaults] objectForKey:@"dressTime"]) ? [[NSUserDefaults standardUserDefaults] objectForKey:@"dressTime"] : @"7:00 AM";
}

- (void)setUpButtonWithImageName:(NSString *)iName andButton:(UIButton *)button {
    UIImage *buttonImage = [[UIImage imageNamed:[NSString stringWithFormat:@"%@Button.png", iName]]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:[NSString stringWithFormat:@"%@ButtonHighlight.png", iName]]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
}

- (void)startConnection {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    NSURLRequest *notifs = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/mbsdev/MBS-Now/master/Resources/notifs.txt"] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:20.0f];
    notificationData = [NSMutableData data];
    notificationUpdates = [[NSURLConnection alloc] initWithRequest:notifs delegate:self startImmediately:YES];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Connection
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [notificationData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *remotePack = [[NSString alloc] initWithData:notificationData encoding:NSUTF8StringEncoding];
    Today *t = [[Today alloc] init];
    [t genFromPrefs:remotePack];
    [[NSUserDefaults standardUserDefaults] setObject:remotePack forKey:@"notificationPack"];
    [SVProgressHUD dismiss];
}

#pragma mark Actions
- (IBAction)pushedDone:(id)sender {
    [SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clubSwitchChanged:(id)sender {
    int *toSet = (clubSwitch.on == YES) ? 0 : 1;
    [[NSUserDefaults standardUserDefaults] setInteger:toSet forKey:@"autoCheck"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)pushedClearGrade:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"msGrade"] || [[NSUserDefaults standardUserDefaults] objectForKey:@"division"]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"msGrade"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"division"];
        [SVProgressHUD showSuccessWithStatus:@"Grade cleared"];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else [SVProgressHUD showErrorWithStatus:@"No grade has been saved"];
}

- (IBAction)pushedChangeGrade:(id)sender {
    NSString *g = [NSString stringWithFormat:@"%dth", [[NSUserDefaults standardUserDefaults] integerForKey:@"msGrade"]];
    if ([g isEqualToString:@"0th"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"division"]) g = [NSString stringWithFormat:@"a %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"division"]];
    NSString *foo = ([g isEqualToString:@"0th"]) ? @"No grade has been saved" : [NSString stringWithFormat:@"Currently in %@ grade", g];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change MS Grade" message:foo delegate:self cancelButtonTitle:@"Save" otherButtonTitles:nil, nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [alert textFieldAtIndex:0].placeholder = @"Enter between 6 and 12";
    alert.tag = 1;
    [alert show];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"msGrade"];
}

#pragma mark -
- (IBAction)switchValueChanged:(id)sender {
    [SVProgressHUD dismiss];
    // Dress-up days
    [[NSUserDefaults standardUserDefaults] setBool:nSwitch.on forKey:@"dressUps"];
    if (nSwitch.on == YES) {
        if (sheet) {
            [sheet dismissWithClickedButtonIndex:-1 animated:YES];
            sheet = nil;
            return;
        }

        // WARNING: do NOT change these times to two-digit hours (e.g. 10:00 AM) or 0-leading hours (e.g. 8:05)
        // if you must, rewrite generateNotifications:: in Today.m
        sheet = [[UIActionSheet alloc] initWithTitle:@"Tap away for 7 AM" delegate:self cancelButtonTitle:@"7 AM" destructiveButtonTitle:nil otherButtonTitles:@"4 AM", @"5 AM", @"5:30 AM", @"6 AM", @"6:30 AM", @"6:45 AM", nil];
        sheet.tag = 2;
        [sheet showInView:self.view];
    } else [self turnOff];
}

- (IBAction)switch2ValueChanged:(id)sender {
    [SVProgressHUD dismiss];
    // A/B weeks
    [[NSUserDefaults standardUserDefaults] setBool:nSwitch2.on forKey:@"abs"];
    if (nSwitch2.on == YES) [self startConnection];
    else [self turnOff];
}

- (IBAction)switch3ValueChanged:(id)sender {
    [SVProgressHUD dismiss];
    // General notifications
    [[NSUserDefaults standardUserDefaults] setBool:nSwitch3.on forKey:@"general"];
    if (nSwitch3.on == YES) [self startConnection];
    else [self turnOff];
}

- (IBAction)changeColor:(id)sender {
    if (sheet) {
        [sheet dismissWithClickedButtonIndex:-1 animated:YES];
        sheet = nil;
        return;
    }
    sheet = [[UIActionSheet alloc] initWithTitle:@"Home buttons color" delegate:self cancelButtonTitle:@"Dismiss" destructiveButtonTitle:nil otherButtonTitles:@"Grey", @"Black", @"Tan", nil];
    sheet.tag = 1;
    [sheet showInView:self.view];
}

- (IBAction)question:(id)sender {
    sheet = nil;
    [SVProgressHUD showImage:[UIImage imageNamed:@"notifications-board.png"] status:@"When you turn on dress-up day notifications, you can choose the time at which you receive them. Toggle the switch to modify a previous choice."];
}

#pragma mark Notifications
- (void)turnOff {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [SVProgressHUD showSuccessWithStatus:@"All notifications are off. Switch 'on' the ones you wish to receive"];

    nSwitch3.on = NO;
    nSwitch2.on = NO;
    nSwitch.on = NO;

    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"dressUps"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"abs"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"general"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Alert View
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        // middle school alert
        if (buttonIndex == 0) {
            // save grade
            NSInteger q = [alertView textFieldAtIndex:0].text.integerValue;
            NSNumber *grade = [NSNumber numberWithInteger:q];

            NSMutableArray *grades = [NSMutableArray array];
            for (int x = 6; x < 13; x++)
                [grades addObject:[NSNumber numberWithInt:x]];
            NSMutableArray *msGrades = [NSMutableArray array];
            for (int x = 6; x < 9; x++)
                [grades addObject:[NSNumber numberWithInt:x]];

            if ([msGrades containsObject:grade])
                [[NSUserDefaults standardUserDefaults] setInteger:q forKey:@"msGrade"];
            else if ([grades containsObject:grade])
                [[NSUserDefaults standardUserDefaults] setObject:((grade.integerValue < 9) ? @"MS" : @"US") forKey:@"division"];
            else {
                [SVProgressHUD showErrorWithStatus:@"Invalid grade! Try again."];
                return;
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self setUpButtonWithImageName:@"grey" andButton:msClear];
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Enjoy %ldth grade!", (long)q]];
        }
    } else if (alertView.tag == 2) {
        if (buttonIndex == 0) {
            // report bag general notifications
            SimpleWebViewController *swvc = [[SimpleWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://campus.mbs.net/mbsnow/home/report.html"]];
            [self presentViewController:swvc animated:YES completion:nil];
        }
    }
}

#pragma mark Action sheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (sheet.tag == 1) {
        if (buttonIndex != 3) {
            NSString *foo = [actionSheet buttonTitleAtIndex:buttonIndex];
            [colorButton setTitle:foo forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] setObject:[foo lowercaseString] forKey:@"buttonColor"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [SVProgressHUD showSuccessWithStatus:@"Change will occur upon next launch (close from multitasking)"];
        }
    } else {
        dressTime.text = [actionSheet buttonTitleAtIndex:buttonIndex];
        [[NSUserDefaults standardUserDefaults] setObject:dressTime.text forKey:@"dressTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self startConnection];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    sheet = nil;
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) return YES;
    return (toInterfaceOrientation == UIDeviceOrientationPortrait) ? YES : NO;
}

@end