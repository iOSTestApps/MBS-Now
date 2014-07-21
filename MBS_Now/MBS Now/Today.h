//
//  Today.h
//  MBS Now
//
//  Created by Graham Dyer on 5/18/14.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import <UIKit/UIKit.h>

@interface Today : UITableViewController <NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
    NSURLConnection *specialConnection;
    NSMutableData *specialData;

    NSURLConnection *meetingsConnection;
    NSMutableData *meetingsData;

    NSURLConnection *versionConnection;
    NSMutableData *versionData;

    NSURLConnection *rssConnection;
    NSMutableData *rssData;

    NSURLConnection *rssNewsConnection;
    NSMutableData *rssNewsData;

    // text schedules
    NSURLConnection *scheduleConnection;
    NSMutableData *scheduleData;
    NSURLConnection *tomorrowTextConnection;
    NSMutableData *tomorrowTextData;

    // graphical schedules
    NSURLConnection *todayScheduleConnection;
    NSMutableData *todayScheduleData;
    NSURLConnection *tomorrowScheduleConnection;
    NSMutableData *tomorrowScheduleData;

    NSURLConnection *notificationUpdates;
    NSMutableData *notificationData;

    NSURLConnection *communityServiceConnection;
    NSMutableData *communityServiceData;

    NSURLConnection *weatherConnection;
    NSMutableData *weatherData;

    UIActionSheet *sheet;

    BOOL preserve; // set to YES when a refresh should not occur on viewDidAppear:
}

- (void)genFromPrefs:(NSString *)pack;

@property (assign, nonatomic) NSInteger ret; // see marcos in m for details
@property (strong, nonatomic) NSMutableDictionary *feeds;

@property (strong, nonatomic) NSDate *startDate;
// feeds[@"strings"] will be an array of text labels.text
// feeds[@"images"] will be an array of UIImages, except for Article Cells, where it's a string
// feeds[@"class"] class name strings
// feeds[@"urls"] will be the webpage OR more text. You must set it as "" when no URL or additional text is needed
@end