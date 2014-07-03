//
//  FormsViewerViewController.h
//  MBS Now
//
//  Created by gdyer on 3/20/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
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