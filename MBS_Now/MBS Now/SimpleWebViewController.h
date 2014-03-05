//
//  SimpleWebViewController.h
//  MBS Now
//
//  Created by 9fermat on 10/31/13.
//  Copyright (c) 2013 DevelopMBS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface SimpleWebViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate> {
    NSURL *urlToLoad;
}

@property (weak, nonatomic) IBOutlet UIWebView *_webView;
@property (nonatomic, assign) NSMutableData *receivedData;
@property (strong, nonatomic) NSString *specifier;

- (id)initWithURL:(NSURL *)url; // default initializer
- (IBAction)done:(id)sender;
- (IBAction)reload:(id)sender;

@end
