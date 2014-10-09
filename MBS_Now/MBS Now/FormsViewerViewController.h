//
//  FormsViewerViewController.h
//  MBS Now
//
//  Created by gdyer on 3/20/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface FormsViewerViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate> {
    
    NSString *extensionName;
    NSURL *finalURL;

    BOOL showingTomorrow;
    NSString *dayName;

    UIActionSheet *sheet;
    BOOL data1;
}

- (id)initWithStringForURL:(NSString *)stringForURL; // default initializer
- (id)initWithFullURL:(NSString *)full;
- (id)initWithLunchDay:(NSString *)day showingTomorrow:(BOOL)late;
- (void)mailLink;

@property (weak, nonatomic) IBOutlet UIWebView *_webView;
@property (strong, nonatomic) NSMutableData *receivedData;
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

@end