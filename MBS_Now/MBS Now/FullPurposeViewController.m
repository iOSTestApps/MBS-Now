//
//  FullPurposeViewController.m
//  MBS Now
//
//  Created by Graham Dyer on 11/3/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import "FullPurposeViewController.h"

@implementation FullPurposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tv.text = self.fullPurpose;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) self.hideNavBar = NO;
    self.navBar.hidden = self.hideNavBar;
    self.navBar.topItem.title = self.navTitle;
    self.navigationItem.title = self.navTitle;
}

// iPad only
- (IBAction)pushedDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
