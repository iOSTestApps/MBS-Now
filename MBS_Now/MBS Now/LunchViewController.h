//
//  LunchViewController.h
//  MBS Now
//
//  Created by gdyer on 1/10/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

// THIS VC IS IPAD ONLY

#import <UIKit/UIKit.h>
@interface LunchViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate> {

    IBOutlet UITableView *tblView;

    NSArray *days;
    NSURL *lunchURL;
    NSString *weekDay;
    NSURL *nextLunchURL;
    NSString *nextWeekDay;
    NSURLConnection *meetingsConnection;
    
    NSURLConnection *notificationUpdates;
    NSMutableData *notificationData;
}

@property (weak, nonatomic) IBOutlet UIWebView *_webView;
@property (nonatomic, strong) NSMutableData *receivedData;

- (IBAction)pushedStop:(id)sender;
- (void)loadFromTable:(NSURL *)urlToLoad;

@end