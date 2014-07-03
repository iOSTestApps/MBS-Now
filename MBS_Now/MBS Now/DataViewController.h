//
//  DataViewController.h
//  MBS Now
//
//  Created by gdyer on 7/19/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface DataViewController : UIViewController <MFMailComposeViewControllerDelegate> {

    IBOutlet UIButton *_1;
    IBOutlet UITextView *textView;

    NSInteger q;
}

- (IBAction)pushedSend:(id)sender;
- (IBAction)pushedQuestion:(id)sender;
- (IBAction)done:(id)sender;

- (NSString *)generateData;

@end