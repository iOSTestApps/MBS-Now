//
//  FullPurposeViewController.m
//  MBS Now
//
//  Created by gdyer on 11/3/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
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
    if (!self.navigationController.navigationBar.translucent && [UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        _tv.frame = CGRectMake(10, 11, 300, self.view.bounds.size.height - 70);
    }
}

// iPad only
- (IBAction)pushedDone:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end