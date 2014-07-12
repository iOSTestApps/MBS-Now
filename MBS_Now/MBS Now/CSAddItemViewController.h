//
//  AddItemViewController.h
//  MBS Now
//
//  Created by Lucas Fagan on 5/15/14.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
@interface AddItemViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate> {NSString *edit;}
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)done:(id)sender;
@end