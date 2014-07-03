//
//  RSVPViewController.h
//  MBS Now
//
//  Created by gdyer on 11/3/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface RSVPViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, NSURLConnectionDataDelegate, NSURLConnectionDelegate, MFMailComposeViewControllerDelegate>

- (IBAction)switchDidChange:(id)sender;

// iPad only
- (IBAction)pushedDone:(id)sender;

- (IBAction)directContact:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *directButton;
@property (strong,nonatomic) NSArray *details;
@property (strong, nonatomic) NSString *label;
@property (weak, nonatomic) IBOutlet UILabel *boolLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UISwitch *boolSwitch;

@end
