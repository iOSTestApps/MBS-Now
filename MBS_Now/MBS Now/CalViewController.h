//
//  CalViewController.h
//  MBS Now
//
//  Created by Graham Dyer on 1/10/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate, UIAlertViewDelegate> {

    IBOutlet UISegmentedControl *control;
    NSURL *urlToLoad;
}

@property (weak, nonatomic) IBOutlet UIWebView *_webView;
@property (nonatomic, assign) NSMutableData *receivedData;

- (IBAction)controlChange:(id)sender;
- (IBAction)pushedReload:(id)sender;

@end
