//
//  TabViewController.m
//  MBS Now
//
//  Created by gdyer on 7/23/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "TabViewController.h"

@implementation TabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"showTodayFirst"])
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedLaunching) name:UIApplicationDidFinishLaunchingNotification object:nil];

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

- (void)finishedLaunching {
    self.selectedIndex = 1;
}

#pragma mark Tabs
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    [SVProgressHUD dismiss];
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) return YES;
    return toInterfaceOrientation == UIDeviceOrientationPortrait;
}

@end