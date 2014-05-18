//
//  ContactViewController.m
//  MBS Now
//
//  Created by Graham Dyer on 6/6/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import "ContactViewController.h"
#import "SVModalWebViewController.h"
#import <AudioToolbox/AudioServices.h>

@implementation ContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    main = @[@"Main Phone", @"Fax", @"Absences", @"Nurse", @"Head of US", @"Head of MS", @"Twitter feed", @"Facebook wall", @"Address"];
    detail = @[@"(973) 539-3032", @"(973) 539-1590", @"Denise Elliot, x542", @"Joyce Kramer, x530", @"Darren Burns, x535", @"Boni Luna, x527", @"View", @"View", @"70 Whippany Road, 07960"];
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Table View
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *iden = @"iden";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];

    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:iden];

    cell.textLabel.text = [main objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [detail objectAtIndex:indexPath.row];

    if (indexPath.row == 6 || indexPath.row == 7) [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"contactsTapped"]) {
        // first time accessing copying a contact
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"contactsTapped"];
    } else {
        NSInteger q = [[NSUserDefaults standardUserDefaults] integerForKey:@"contactsTapped"];
        q++;
        [[NSUserDefaults standardUserDefaults] setInteger:q forKey:@"contactsTapped"];
    }

    if (indexPath.row < 6) {
        NSString *string;
        switch ([indexPath row]) {
            case 0:
                string = @"19735393032";
                break;
            case 1:
                string = @"19735391590";
                break;
            case 2:
                string = @"19735393032;542";
                break;
            case 3:
                string = @"19735393032;530";
                break;
            case 4:
                string = @"19735393032;535";
                break;
            case 5:
                string = @"19735393032;527";
                break;
        }
        final = [NSString stringWithFormat:@"tel:%@", string];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Call or Copy?" message:string delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Call", @"Copy", nil];
        [alert show];
    } else {
        SVModalWebViewController *wvc;
        switch (indexPath.row) {
            case 6:
                wvc = [[SVModalWebViewController alloc] initWithURL:[NSURL URLWithString:@"https://twitter.com/MorristownBeard"]];
                [self presentViewController:wvc animated:YES completion:nil];
                break;
            case 7:
                wvc = [[SVModalWebViewController alloc] initWithURL:[NSURL URLWithString:@"https://www.facebook.com/morristown.beard"]];
                [self presentViewController:wvc animated:YES completion:nil];
                break;
            case 8:
                [[UIPasteboard generalPasteboard] setString:@"70 Whippany Road, Morristown, New Jersey, 07960"];
                [SVProgressHUD showSuccessWithStatus:@"Copied"];
                break;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return detail.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"Tap to call or copy";
}

#pragma mark Alert view
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // call
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:final]];
    } else if (buttonIndex == 2) {
        // copy
        [[UIPasteboard generalPasteboard] setString:final];
        [SVProgressHUD showSuccessWithStatus:@"Copied"];
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
