//
//  CSDetailViewController.h
//  Community Service
//
//  Created by Lucas Fagan on 6/10/14.
//  Copyright (c) 2014 Lucas Fagan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface CSDetailViewController : UIViewController  <MFMailComposeViewControllerDelegate, UIActionSheetDelegate>
@property (nonatomic) NSMutableArray *array;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *exportButton;
@property (weak, nonatomic) IBOutlet UITextView *detailsView;
@property (weak, nonatomic) IBOutlet UILabel *detailsTitle;
- (IBAction)emailButtonPushed:(id)sender;
- (IBAction)exportButton:(id)sender;
@end
