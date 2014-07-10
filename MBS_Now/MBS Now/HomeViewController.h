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

    NSURLConnection *meetingsConnection;
    NSURLConnection *versionConnection;
    NSMutableData *versionData;
    NSURLConnection *sendingData;
}

- (NSArray *)countdown;

- (IBAction)pushedCountdown:(id)sender;
- (IBAction)pushedCredentials:(id)sender;
- (IBAction)pushedLibrary:(id)sender;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *first;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *second;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *third;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *l1;
@property (weak, nonatomic) IBOutlet UILabel *l2;

@property (nonatomic, assign) NSMutableData *receivedData;
@end