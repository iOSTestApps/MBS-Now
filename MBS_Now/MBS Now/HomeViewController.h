//
//  HomeViewController.h
//  MBS Now
//
//  Created by gdyer on 1/10/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "InfoViewController.h"

@interface HomeViewController : UIViewController <UIPopoverControllerDelegate, UIAlertViewDelegate, NSURLConnectionDataDelegate, MFMailComposeViewControllerDelegate, UIScrollViewDelegate, NSURLConnectionDelegate, UIScrollViewDelegate> {

    IBOutletCollection(UILabel) NSArray *first;
    IBOutletCollection(UILabel) NSArray *second;
    IBOutletCollection(UILabel) NSArray *third;
    IBOutletCollection(UILabel) NSArray *fourth;

    NSURLConnection *connection1;
    NSURLConnection *connection2;
    NSURLConnection *meetingsConnection;
    NSURLConnection *versionConnection;
    NSMutableData *versionData;
    NSURLConnection *sendingData;

    // countdown
    NSInteger days;
    UIImage *bImage;
    NSDateComponents *components;
    NSString *messagePart;

    // for custom buttons
    IBOutletCollection(UIButton) NSArray *buttons;

    IBOutlet UILabel *_l1;
    IBOutlet UILabel *_l2;
    IBOutlet UILabel *_l3;
    IBOutlet UILabel *_l4;

    IBOutlet UILabel *versionLabel;
}

- (IBAction)pushedCountdown:(id)sender;
- (IBAction)pushedCredentials:(id)sender;
- (IBAction)pushedLibrary:(id)sender;
- (IBAction)pushedNotify:(id)sender;

@property (nonatomic, assign) NSMutableData *receivedData;

@end