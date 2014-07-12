//
//  CSDetailViewController.h
//  MBS Now
//
//  Created by Lucas Fagan on 5/15/14.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
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