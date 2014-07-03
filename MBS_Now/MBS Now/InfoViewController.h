//
//  InfoViewController.h
//  MBS Now
//
//  Created by gdyer on 1/21/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface InfoViewController : UIViewController <MFMailComposeViewControllerDelegate> {
    
    IBOutlet UIButton *_1;
    IBOutlet UIButton *_2;
    IBOutlet UIButton *_3; // iPhones only
    
    IBOutlet UISegmentedControl *control;
    IBOutlet UITextView *textView;
}

- (IBAction)pushedNew:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)pushedLucas:(id)sender;
- (IBAction)pushedVisitSite:(id)sender;

@property (assign) int segueIndex;

@end