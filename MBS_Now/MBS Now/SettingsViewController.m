//
//  SettingsViewController.m
//  MBS Now
//
//  Created by Graham Dyer on 8/16/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import "SettingsViewController.h"
#import "SimpleWebViewController.h"

@interface SettingsViewController () {

    NSArray *colorsArray;
    NSArray *timesArray;
    NSArray *abbreviatedTimes;
}

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *foo = ([[NSUserDefaults standardUserDefaults] objectForKey:@"buttonColor"]) ? [[NSUserDefaults standardUserDefaults] objectForKey:@"buttonColor"] : @"Not set — default";

    [colorButton setTitle:foo forState:UIControlStateNormal];
    abbreviatedTimes = [NSArray arrayWithObjects:@" 04 00", @" 05 00", @" 05 30", @" 06 00", @" 06 30", @" 06 45", @" 07 00", nil];

    nSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"dressUps"];
    nSwitch2.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"abs"];
    nSwitch3.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"general"];
    clubSwitch.on = ([[NSUserDefaults standardUserDefaults] integerForKey:@"autoCheck"] == 0) ? YES : NO;

    [self setUpButtonWithImageName:@"grey" andButton:msChange];

    [self setUpButtonWithImageName:([[NSUserDefaults standardUserDefaults] integerForKey:@"msGrade"] ? @"grey" : @"black") andButton:msClear];

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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"msGrade"]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"msGrade"];
        [SVProgressHUD showSuccessWithStatus:@"Grade cleared"];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [SVProgressHUD showErrorWithStatus:@"No grade has been saved"];
    }
}

- (IBAction)pushedChangeGrade:(id)sender {
    NSInteger q = [[NSUserDefaults standardUserDefaults] integerForKey:@"msGrade"];
    NSString *foo;
    if (q == 0) {
        foo = @"No MS grade has been saved";
    } else {
        foo = [NSString stringWithFormat:@"Currently in %ldth grade", (long)q];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Change MS Grade" message:foo delegate:self cancelButtonTitle:@"Save" otherButtonTitles:nil, nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
    [alert textFieldAtIndex:0].placeholder = @"6, 7, or 8";
    alert.tag = 1;
    [alert show];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"msGrade"];
}

#pragma mark -
- (IBAction)switchValueChanged:(id)sender {
    // Dress-up days
    if (nSwitch.on == YES) {
        if (sheet) {
            [sheet dismissWithClickedButtonIndex:-1 animated:YES];
            sheet = nil;
            return;
        }
        sheet = [[UIActionSheet alloc] initWithTitle:@"Tap away for 7 AM" delegate:self cancelButtonTitle:@"7 AM" destructiveButtonTitle:nil otherButtonTitles:@"4 AM", @"5 AM", @"5:30 AM", @"6 AM", @"6:30 AM", @"6:45 AM", nil];
        sheet.tag = 2;
        [sheet showInView:self.view];
    } else {
        [self turnOff];
    }
}

- (IBAction)switch2ValueChanged:(id)sender {
    // A/B weeks
    if (nSwitch2.on == YES) {
        [self setUpAB_Notifications:0];
    } else {
        [self turnOff];
    }
}

- (IBAction)switch3ValueChanged:(id)sender {
    // General notifications
    if (nSwitch3.on == YES) {
        [self setUpGeneralNotifications:0];
    } else {
        [self turnOff];
    }
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

- (void)setUpDressUpNotifications:(int)q withHour:(NSString *)hours {
    NSMutableArray *datesOnly = [NSMutableArray arrayWithObjects:
                                @"03/04/2014",
                                @"04/11/2014",
                                @"04/25/2014",
                                @"05/01/2014",
                                @"05/08/2014",
                                @"05/20/2014", nil];

    NSMutableArray *dateStrings = [[NSMutableArray alloc] init];
    for (NSString *chi in datesOnly) {
        NSMutableString *foo = [chi mutableCopy];
        [foo insertString:hours atIndex:chi.length];
        [dateStrings addObject:foo];
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy hh mm"];
    [dateFormat setTimeZone:[NSTimeZone defaultTimeZone]];

    NSMutableArray *datesArray = [NSMutableArray arrayWithObjects: nil];

    for (int x = 0; x < dateStrings.count; x++) {
        [datesArray addObject:[dateFormat dateFromString:[dateStrings objectAtIndex:x]]];
    }

    for (int y = 0; y < datesArray.count; y++) {
        NSComparisonResult result = [[NSDate date] compare:datesArray[y]];
        if (result == NSOrderedAscending || result == NSOrderedSame) {
            // datesArray[y] is in the future or today
            UILocalNotification *lcl = [[UILocalNotification alloc] init];
            lcl.fireDate = [datesArray objectAtIndex:y];
            lcl.alertBody = [NSString stringWithFormat:@"Today: dress-up day"];
            lcl.soundName = UILocalNotificationDefaultSoundName;
            lcl.alertAction = @"View";
            lcl.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
            lcl.timeZone = [NSTimeZone defaultTimeZone];

            [[UIApplication sharedApplication] scheduleLocalNotification:lcl];
        }
    }

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"dressUps"];

    if (q == 0) {
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%lu alerts created", (unsigned long)dateStrings.count]];
    }
}

- (void)setUpAB_Notifications:(int)q {

    // A weeks
    NSArray *aWeeks = [NSArray arrayWithObjects:
                       @"02/03/2014 08",
                       @"02/19/2014 08",
                       @"03/03/2014 08",
                       @"03/31/2014 08",
                       @"04/14/2014 08",
                       @"04/28/2014 08",
                       @"05/12/2014 08",
                       @"05/27/2014 08", nil];

    // B weeks
    NSArray *bWeeks = [NSArray arrayWithObjects:
                       @"02/10/2014 08",
                       @"02/24/2014 08",
                       @"03/24/2014 08",
                       @"04/08/2014 08",
                       @"04/21/2014 09",
                       @"05/05/2014 08",
                       @"05/19/2014 08", nil];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy hh"];
    [dateFormat setTimeZone:[NSTimeZone defaultTimeZone]];

    NSMutableArray *aArray = [NSMutableArray arrayWithObjects: nil];
    NSMutableArray *bArray = [NSMutableArray arrayWithObjects: nil];

    for (int x = 0; x < aWeeks.count; x++) {
        [aArray addObject:[dateFormat dateFromString:[aWeeks objectAtIndex:x]]];
    }

    for (int x = 0; x < bWeeks.count; x++) {
        [bArray addObject:[dateFormat dateFromString:[bWeeks objectAtIndex:x]]];
    }

    // B WEEKS
    NSMutableArray *bNotificiations = [[NSMutableArray alloc] init];
    for (int y = 0; y < bArray.count; y++) {
        NSComparisonResult result = [[NSDate date] compare:bArray[y]];
        if (result == NSOrderedAscending || result == NSOrderedSame) {
            // bArray[y] is in the future or today
            UILocalNotification *lcl = [[UILocalNotification alloc] init];
            lcl.fireDate = [bArray objectAtIndex:y];
            lcl.alertBody = [NSString stringWithFormat:@"This week: B"];
            lcl.soundName = UILocalNotificationDefaultSoundName;
            lcl.alertAction = @"View";
            [bNotificiations addObject:lcl];
            lcl.timeZone = [NSTimeZone defaultTimeZone];

            [[UIApplication sharedApplication] scheduleLocalNotification:lcl];
        }
    }

    // A WEEKS
    NSMutableArray *aNotifications = [[NSMutableArray alloc] init];
    for (int y = 0; y < aArray.count; y++) {
        NSComparisonResult result = [[NSDate date] compare:aArray[y]];
        if (result == NSOrderedAscending || result == NSOrderedSame) {
            // aArray[y] is in the future or today
            UILocalNotification *lcl = [[UILocalNotification alloc] init];
            lcl.fireDate = [aArray objectAtIndex:y];
            lcl.alertBody = [NSString stringWithFormat:@"This week: A"];
            lcl.soundName = UILocalNotificationDefaultSoundName;
            lcl.alertAction = @"View";
            [aNotifications addObject:lcl];
            lcl.timeZone = [NSTimeZone defaultTimeZone];

            [[UIApplication sharedApplication] scheduleLocalNotification:lcl];
        }
    }

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"abs"];

    if (q == 0) {
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%d alerts created", (aWeeks.count + bWeeks.count)]];
    }
}

- (void)setUpGeneralNotifications:(int)q {
    // BE SURE TO CHANGE DESCRIPTIONS
    NSArray *dateStrings = [NSArray arrayWithObjects:
                            @"03/28/2014 08",
                            @"05/30/2014 08",
                            @"02/19/2014 08",
                            @"05/08/2014 08",
                            @"05/05/2014 08", nil];
    // BE SURE TO CHANGE dateString ARRAY
    NSArray *descriptions = [NSArray arrayWithObjects:
                             @"Today: end of 3/4",
                             @"See you in September!",
                             @"Monday, A schedule",
                             @"Tomorrow: service hours due",
                             @"Best of luck on APs!", nil];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy hh"];
    [dateFormat setTimeZone:[NSTimeZone defaultTimeZone]];

    NSMutableArray *datesArray = [NSMutableArray arrayWithObjects: nil];

    for (int x = 0; x < dateStrings.count; x++) {
        [datesArray addObject:[dateFormat dateFromString:[dateStrings objectAtIndex:x]]];
    }

    if (descriptions.count == datesArray.count) {
        for (int y = 0; y < datesArray.count; y++) {
            // datesArray[y] is in the future or today
            NSComparisonResult result = [[NSDate date] compare:datesArray[y]];
            if (result == NSOrderedAscending || result == NSOrderedSame) {
                UILocalNotification *lcl = [[UILocalNotification alloc] init];
                lcl.fireDate = [datesArray objectAtIndex:y];
                lcl.alertBody = [descriptions objectAtIndex:y];
                lcl.soundName = UILocalNotificationDefaultSoundName;
                lcl.alertAction = @"View";
                lcl.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
                lcl.timeZone = [NSTimeZone defaultTimeZone];

                [[UIApplication sharedApplication] scheduleLocalNotification:lcl];
            }
        }
        if (q == 0) {
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%lu alerts created", (unsigned long)dateStrings.count]];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"General alerts are not available. Please report this bug ASAP." delegate:self cancelButtonTitle:@"Report" otherButtonTitles:@"Dismiss", nil];
        alert.tag = 2;
        [alert show];
    }

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"general"];
}

#pragma mark Alert View
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        // middle school alert
        if (buttonIndex == 0) {
            // save grade
            NSInteger q = [alertView textFieldAtIndex:0].text.integerValue;
            NSNumber *grade = [NSNumber numberWithInteger:q];
            NSArray *grades = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:7], [NSNumber numberWithInt:8], nil];
            if ([grades containsObject:grade]) {
                [[NSUserDefaults standardUserDefaults] setInteger:q forKey:@"msGrade"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self setUpButtonWithImageName:@"grey" andButton:msClear];
                [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Enjoy %ldth grade!", (long)q]];
            } else {
                [SVProgressHUD showErrorWithStatus:@"Not an MS grade. Try again"];
            }
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
        [self setUpDressUpNotifications:0 withHour:abbreviatedTimes[buttonIndex]];
        dressTime.text = [actionSheet buttonTitleAtIndex:buttonIndex];
        [[NSUserDefaults standardUserDefaults] setObject:[actionSheet buttonTitleAtIndex:buttonIndex] forKey:@"dressTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    sheet = nil;
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
