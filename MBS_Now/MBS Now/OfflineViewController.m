//
//  OfflineViewController.m
//  MBS Now
//
//  Created by Graham Dyer on 6/6/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import "OfflineViewController.h"
#import "OfflineViewerViewController.h"

@implementation OfflineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    divisions = [NSArray arrayWithObjects:@"Upper School", @"Middle School", @"Listing", nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

    if (section == 2) {
        return 1;
    } else {
        return 3;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    return [divisions objectAtIndex:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {

    if (section == 0 || section == 1) {
        return @"Static schedules are subject to change";
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *CellIdentifier1 = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier1];
    }

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
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        if(toInterfaceOrientation == UIDeviceOrientationPortrait) return YES;
        return NO;
    }
}

#pragma mark Segue


@end
