//
//  Today.h
//  MBS Now
//
//  Created by Graham Dyer on 5/18/14.
//  Copyright (c) 2014 MBS Now. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Today : UITableViewController <NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate> {
    NSURLConnection *specialConnection;
    NSMutableData *specialData;

//    NSURLConnection *meetingsConnection;
//    NSMutableData *meetingsData;
//
//    NSURLConnection *versionConnection;
//    NSMutableData *versionData;

    NSURLConnection *rssConnection;
    NSMutableData *rssData;

    NSURLConnection *rssNewsConnection;
    NSMutableData *rssNewsData;

    NSURLConnection *scheduleConnection;
    NSMutableData *scheduleData;

    NSURLConnection *todayScheduleConnection;
    NSMutableData *todayScheduleData;
    NSURLConnection *tomorrowScheduleConnection;
    NSMutableData *tomorrowScheduleData;
}

@property (strong, nonatomic) NSMutableDictionary *feeds;
@property (strong, nonatomic) NSDate *tomorrow;
// feeds[@"strings"] will be an array of text labels.text
// feeds[@"images"] will be an array of UIImages
// feeds[@"class"] class name strings
// feeds[@"urls"] will be the webpage loaded when a Standard cell is tapped.

@end