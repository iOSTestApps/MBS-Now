//
//  TabViewController.m
//  MBS Now
//
//  Created by gdyer on 7/23/13.
//  Copyright (c) 2013 DevelopMBS. All rights reserved.
//

#import "TabViewController.h"

@implementation TabViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        // iOS 7.x
        [[UITabBarItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor darkGrayColor]}
                                                 forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor clearColor]}
                                                 forState:UIControlStateSelected];
    } else {
        [[UITabBar appearance] setTintColor:[UIColor colorWithWhite:40 alpha:.7]];
        [[UITabBarItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor whiteColor]}
                                                 forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:@{UITextAttributeTextColor:[UIColor clearColor]}
                                                 forState:UIControlStateSelected];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Tabs
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {

    [SVProgressHUD dismiss];
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
