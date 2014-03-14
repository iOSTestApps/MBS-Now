//
//  InfoViewController.h
//  MBS Now
//
//  Created by Graham Dyer on 1/21/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
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
- (IBAction)pushedGraham:(id)sender;
- (IBAction)pushedVisitSite:(id)sender;

@property (assign) int segueIndex;

@end