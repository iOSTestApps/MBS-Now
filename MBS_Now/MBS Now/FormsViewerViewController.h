//
//  FormsViewerViewController.h
//  MBS Now
//
//  Created by Graham Dyer on 3/20/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface FormsViewerViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate> {
    
    NSString *extensionName;
    NSURL *finalURL;

    UIActionSheet *sheet;
}

- (id)initWithStringForURL:(NSString *)stringForURL; // default initializer
- (id)initWithFullURL:(NSString *)full;
- (void)mailLink;

@property (weak, nonatomic) IBOutlet UIWebView *_webView;
@property (assign, nonatomic) NSMutableData *receivedData;
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

@end