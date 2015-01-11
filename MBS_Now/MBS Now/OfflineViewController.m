//
//  OfflineViewController.m
//  MBS Now
//
//  Created by gdyer on 6/6/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "OfflineViewController.h"
#import "OfflineViewerViewController.h"
#import "HomeViewController.h"

@implementation OfflineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    divisions = @[@"Upper School", @"Middle School", @"Listing"];
}

- (NSDate *)dateByDistanceFromToday:(NSInteger)d {
    NSDateComponents *tomorrowComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSDate *compDate = [[NSCalendar currentCalendar] dateFromComponents:tomorrowComponents];

    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    offsetComponents.day = d;
    return [[NSCalendar currentCalendar] dateByAddingComponents:offsetComponents toDate:compDate options:0];
}


#pragma mark TableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"schedulesTapped"]) {
        // first time accessing a form
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"schedulesTapped"];
    } else {
        NSInteger q = [[NSUserDefaults standardUserDefaults] integerForKey:@"schedulesTapped"];
        q++;
        [[NSUserDefaults standardUserDefaults] setInteger:q forKey:@"schedulesTapped"];
    }

    // section, row -- image naming scheme
    NSString *name = [NSString stringWithFormat:@"%ld%ld.png", (long)indexPath.section, (long)indexPath.row];
    OfflineViewerViewController *ovvc = [[OfflineViewerViewController alloc] initWithImageName:name];
    [self presentViewController:ovvc animated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return divisions.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 2) ? 1 : 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return divisions[section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return (section == 0 || section == 1) ? @"Static schedules are subject to change" : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *iden = @"iden";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];

    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:iden];

    if (indexPath.section == 0 || indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Regular Week";
                cell.detailTextLabel.text = @"A";
                break;
            case 1:
                cell.textLabel.text = @"Regular Week";
                cell.detailTextLabel.text = @"B";
                break;
            case 2:
                cell.textLabel.text = @"Delayed Week";
                cell.detailTextLabel.text = @"A/B";
            default:
                break;
        }
    } else {
        // listings section
        cell.textLabel.text = @"A/B Week List";
        NSDateFormatter *form = [[NSDateFormatter alloc] init];
        [form setDateFormat:@"YYYY"];
        HomeViewController *hvc = [[HomeViewController alloc] init];
        NSArray *interval = [hvc intervalDates];
        // this is great because these dates will automatically update when the countdown date changes. This type of automation saves a lot of time and prevents user-confusion
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@-%@", [form stringFromDate:interval[0]], [form stringFromDate:interval[1]]];
    }
    return cell;
}

#pragma mark Actions
- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) return YES;
    return toInterfaceOrientation == UIDeviceOrientationPortrait;
}

@end