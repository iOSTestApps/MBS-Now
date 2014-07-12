//
//  WidgetViewController.h
//  MBS Now
//
//  Created by Graham Dyer on 1/10/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import <UIKit/UIKit.h>

@interface WidgetViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate> {
    NSURLConnection *specialConnection;
    NSURLConnection *meetingsConnection;
}



@property (weak, nonatomic) IBOutlet UIWebView *_webView;
@property (nonatomic, assign) NSMutableData *receivedData;
@property (assign) BOOL unique;

- (IBAction)pushedReload:(id)sender;

@end