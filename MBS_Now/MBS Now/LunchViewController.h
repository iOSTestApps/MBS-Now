//
//  LunchViewController.h
//  MBS Now
//
//  Created by gdyer on 1/10/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
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
