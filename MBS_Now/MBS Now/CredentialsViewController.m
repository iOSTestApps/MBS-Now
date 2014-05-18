//
//  CredentialsViewController.m
//  MBS Now
//
//  Created by Graham Dyer on 8/6/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import "CredentialsViewController.h"

@implementation CredentialsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    names = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"databases" ofType:@"plist"]];
    ids = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ids" ofType:@"plist"]];
    keys = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"keys" ofType:@"plist"]];
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
    if (section % 3 == 0) return @"Tap to copy";
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *iden = @"iden";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:iden];

    NSInteger incrementor = (indexPath.section == 0) ? 0 : indexPath.section;
    cell.textLabel.text = (indexPath.row == 0) ? [ids objectAtIndex:indexPath.row + incrementor] : [keys objectAtIndex:indexPath.row + (incrementor - 1)];
    cell.detailTextLabel.text = (indexPath.row == 0) ? @"Username" : @"Password";

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellText = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;

    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    pb.string = cellText;
    [SVProgressHUD showSuccessWithStatus:@"Copied"];

    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"loginsTapped"]) {
        // first time accessing copying credentials
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"loginsTapped"];
    } else {
        NSInteger q = [[NSUserDefaults standardUserDefaults] integerForKey:@"loginsTapped"];
        q++;
        [[NSUserDefaults standardUserDefaults] setInteger:q forKey:@"loginsTapped"];
    }
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        return YES;
    else {
        if(toInterfaceOrientation == UIDeviceOrientationPortrait) return YES;
        return NO;
    }
}

@end
