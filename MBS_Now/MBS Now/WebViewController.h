//
//  WebViewController.h
//  MBS Now
//
//  Created by gdyer on 3/2/13.
//  Copyright (c) 2013 DevelopMBS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate,UIActionSheetDelegate> {
    
    IBOutlet UIBarButtonItem *output;
    UIActionSheet *sheet;
    
    NSURL *urlToLoad;

}

@property (weak, nonatomic) IBOutlet UIWebView *_webView;
@property (nonatomic, assign) NSMutableData *receivedData;

- (id)initWithURL:(NSURL *)url; // default initializer
- (IBAction)done:(id)sender;
- (IBAction)pushedBack:(id)sender;
- (IBAction)pushedForward:(id)sender;
- (IBAction)output:(id)sender;

@end