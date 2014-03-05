//
//  AppDelegate.m
//  MBS Now
//
//  Created by gdyer on 1/10/13.
//  Copyright (c) 2013 DevelopMBS. All rights reserved.
//

#import "AppDelegate.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        UIStoryboard *mainStoryboard = nil;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            mainStoryboard = [UIStoryboard storyboardWithName:@"StoryboardPhone_7" bundle:nil];
        } else {
            mainStoryboard = [UIStoryboard storyboardWithName:@"StoryboardPhone_6" bundle:nil];
        }
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = [mainStoryboard instantiateInitialViewController];
        [self.window makeKeyAndVisible];
    } else {
        // iPad
        UIStoryboard *mainStoryboard = nil;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            mainStoryboard = [UIStoryboard storyboardWithName:@"StoryboardPad_7" bundle:nil];
        } else {
            mainStoryboard = [UIStoryboard storyboardWithName:@"StoryboardPad_6" bundle:nil];
        }
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = [mainStoryboard instantiateInitialViewController];
        [self.window makeKeyAndVisible];

    }

    if (![[NSUserDefaults standardUserDefaults] integerForKey:@"dfl"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"dfl"];
    } else {
        int x = [[NSUserDefaults standardUserDefaults] integerForKey:@"dfl"];
        x++;
        [[NSUserDefaults standardUserDefaults] setInteger:x forKey:@"dfl"];
    }

    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"338"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"338"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"338"];
    }

    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (![[NSUserDefaults standardUserDefaults] integerForKey:@"dfl"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"dfl"];
    } else {
        int x = [[NSUserDefaults standardUserDefaults] integerForKey:@"dfl"];
        x++;
        [[NSUserDefaults standardUserDefaults] setInteger:x forKey:@"dfl"];
    }

    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"338"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"338"];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"338"];
    }

    [[NSUserDefaults standardUserDefaults] synchronize];

    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:[NSString stringWithFormat:@"%@. [This may be outdated]", notification.alertBody] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
    [alert show];
}

@end