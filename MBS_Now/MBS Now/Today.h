//
//  Today.h
//  MBS Now
//
//  Created by Graham Dyer on 5/18/14.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import <UIKit/UIKit.h>

@interface Today : UITableViewController <NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate> {
    NSURLConnection *specialConnection;
    NSMutableData *specialData;

    NSURLConnection *meetingsConnection;
    NSMutableData *meetingsData;

    NSURLConnection *versionConnection;
    NSMutableData *versionData;

    NSURLConnection *rssConnection;
    NSMutableData *rssData;

//    NSURLConnection *rssNewsConnection;
//    NSMutableData *rssNewsData;

    // text schedules
    NSURLConnection *scheduleConnection;
    NSMutableData *scheduleData;
    NSURLConnection *tomorrowTextConnection;
    NSMutableData *tomorrowTextData;

    // photos
    NSURLConnection *todayScheduleConnection;
    NSMutableData *todayScheduleData;
    NSURLConnection *tomorrowScheduleConnection;
    NSMutableData *tomorrowScheduleData;

    NSURLConnection *communityServiceConnection;
    NSMutableData *communityServiceData;
}

@property (assign, nonatomic) NSInteger ret; // see marcos in m for details
@property (strong, nonatomic) NSMutableDictionary *feeds;
// feeds[@"strings"] will be an array of text labels.text
// feeds[@"images"] will be an array of UIImages
// feeds[@"class"] class name strings
// feeds[@"urls"] will be the webpage OR more text. You must set it as "" when no URL or additional text is needed
@end