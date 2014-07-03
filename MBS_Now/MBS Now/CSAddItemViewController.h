//
//  AddItemViewController.h
//  Community Service
//
//  Created by Lucas Fagan on 5/15/14.
//  Copyright (c) 2014 Lucas Fagan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
@interface AddItemViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate> {NSString *edit;}
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)done:(id)sender;
@end