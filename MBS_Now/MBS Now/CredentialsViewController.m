//
//  CredentialsViewController.m
//  MBS Now
//
//  Created by Graham Dyer on 8/6/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import "CredentialsViewController.h"

@implementation CredentialsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    names = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"databases" ofType:@"plist"]];
    ids = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ids" ofType:@"plist"]];
    keys = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keys" ofType:@"plist"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return names.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    return [names objectAtIndex:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    
    if (section % 3 == 0) {
        return @"Tap to copy";
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *CellIdentifier1 = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];

    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier1];

    NSInteger incrementor;
    if (indexPath.section == 0) {
        incrementor = 0;
    } else {
        incrementor = indexPath.section;
    }

    if (indexPath.row == 0) {
        cell.textLabel.text = [ids objectAtIndex:indexPath.row + incrementor];
    } else {
        cell.textLabel.text = [keys objectAtIndex:indexPath.row + (incrementor - 1)];
    }

    if (indexPath.row == 0) cell.detailTextLabel.text = @"Username";
    else cell.detailTextLabel.text = @"Password";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellText = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;

    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    pb.string = cellText;
    [SVProgressHUD showSuccessWithStatus:@"Copied"];

    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"loginsTapped"]) {
        // first time accessing a form
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"loginsTapped"];
    } else {
        NSInteger q = [[NSUserDefaults standardUserDefaults] integerForKey:@"loginsTapped"];
        q++;
        [[NSUserDefaults standardUserDefaults] setInteger:q forKey:@"loginsTapped"];
    }
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

@end
