//
//  HomeViewController.h
//  MBS Now
//
//  Created by gdyer on 1/10/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
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
- (NSArray *)intervalDates;

- (IBAction)pushedCountdown:(id)sender;
- (IBAction)pushedCredentials:(id)sender;
- (IBAction)pushedLibrary:(id)sender;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *first;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *second;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *third;
@property (weak, nonatomic) IBOutlet UILabel *iPadCatalog;
@property (weak, nonatomic) IBOutlet UIScrollView *iPadScroller;

@property (weak, nonatomic) IBOutlet UIScrollView *iphoneScroller;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (nonatomic, assign) NSMutableData *receivedData;
@end