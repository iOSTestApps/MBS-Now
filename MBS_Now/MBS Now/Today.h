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

    NSURLConnection *meetingsConnection;
    NSMutableData *meetingsData;

    NSURLConnection *versionConnection;
    NSMutableData *versionData;

    NSURLConnection *rssConnection;
    NSMutableData *rssData;

    NSURLConnection *rssNewsConnection;
    NSMutableData *rssNewsData;

    NSURLConnection *scheduleConnection;
    NSMutableData *scheduleData;
}

@property (strong, nonatomic) NSMutableDictionary *feeds;
// feeds[@"strings"] will be an array of text labels.text
// feeds[@"heights"] will be an array of NSNumbers
// feeds[@"images"] will be an array of UIImages
// feeds[@"class"] will be a boolean indicating the UITableViewCell class (or subclass) ————— YES will be if it's standard, otherwise NO

@end