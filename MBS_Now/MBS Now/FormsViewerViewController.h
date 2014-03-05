//
//  FormsViewerViewController.h
//  MBS Now
//
//  Created by gdyer on 3/20/13.
//  Copyright (c) 2013 DevelopMBS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface FormsViewerViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate> {
    
    NSString *extensionName;
    NSURL *finalURL;

    UIActionSheet *sheet;
    IBOutlet UIBarButtonItem *output;
}

- (id)initWithStringForURL:(NSString *)stringForURL; // default initializer

- (IBAction)done:(id)sender;

- (IBAction)pushedOpenIn:(id)sender;
- (void)mailLink;


@property (weak, nonatomic) IBOutlet UIWebView *_webView;
@property (assign, nonatomic) NSMutableData *receivedData;
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

@end