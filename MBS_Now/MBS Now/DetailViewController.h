//
//  DetailViewController.h
//  MBS Now
//
//  Created by gdyer on 11/1/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <EventKit/EventKit.h>

@interface DetailViewController : UITableViewController <UIAlertViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    IBOutlet UIBarButtonItem *output;
    UIActionSheet *sheet;
}

@property (strong, nonatomic) NSArray *descriptions;
@property (strong, nonatomic) NSArray *details;
@property (assign) int *detailIndexPath;

@end
