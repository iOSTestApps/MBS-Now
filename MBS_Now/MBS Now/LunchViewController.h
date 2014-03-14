//
//  LunchViewController.h
//  MBS Now
//
//  Created by Graham Dyer on 1/10/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LunchViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate> {

    IBOutlet UITableView *tblView;

    NSArray *days;
    NSURL *lunchURL;
    NSString *weekDay;
    NSURL *nextLunchURL;
    NSString *nextWeekDay;
    NSURLConnection *meetingsConnection;
}

@property (weak, nonatomic) IBOutlet UIWebView *_webView;
@property (nonatomic, assign) NSMutableData *receivedData;

- (IBAction)pushedStop:(id)sender;

- (void)loadFromTable:(NSURL *)urlToLoad;

@end
