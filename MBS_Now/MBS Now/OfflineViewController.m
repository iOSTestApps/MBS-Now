//
//  OfflineViewController.m
//  MBS Now
//
//  Created by gdyer on 6/6/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import "OfflineViewController.h"
#import "OfflineViewerViewController.h"

@implementation OfflineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    divisions = @[@"Upper School", @"Middle School", @"Listing"];
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
        cell.detailTextLabel.text = @"2013-2014";
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
    return (toInterfaceOrientation == UIDeviceOrientationPortrait) ? YES : NO;
}

@end