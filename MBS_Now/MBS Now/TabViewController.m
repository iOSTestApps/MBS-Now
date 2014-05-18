//
//  TabViewController.m
//  MBS Now
//
//  Created by Graham Dyer on 7/23/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import "TabViewController.h"

@implementation TabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        // iOS 7.x
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor]}
                                                 forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor clearColor]}
                                                 forState:UIControlStateSelected];
    } else {
        [[UITabBar appearance] setTintColor:[UIColor colorWithWhite:40 alpha:.7]];
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}
                                                 forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor clearColor]}
                                                 forState:UIControlStateSelected];
    }
}

#pragma mark Tabs
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {

    [SVProgressHUD dismiss];
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