//
//  SettingsViewController.h
//  MBS Now
//
//  Created by gdyer on 8/16/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate, NSURLConnectionDataDelegate, NSURLConnectionDelegate> {

    IBOutletCollection(UITableViewCell) NSArray *cells;

    NSMutableData *notificationData;
    NSURLConnection *notificationUpdates;

    IBOutlet UIButton *colorButton;

    IBOutlet UISwitch *nSwitch;
    IBOutlet UISwitch *nSwitch2;
    IBOutlet UISwitch *nSwitch3;
    IBOutlet UISwitch *clubSwitch;

    IBOutlet UIButton *msClear;
    IBOutlet UIButton *msChange;

    IBOutlet UILabel *dressTime;

    UIActionSheet *sheet;

//    IBOutlet UITextField *receiptTime;
//    IBOutlet UIPickerView *receiptPicker;
}

- (IBAction)pushedDone:(id)sender;

- (IBAction)switchValueChanged:(id)sender;
- (IBAction)switch2ValueChanged:(id)sender;
- (IBAction)switch3ValueChanged:(id)sender;
- (IBAction)clubSwitchChanged:(id)sender;

- (IBAction)pushedClearGrade:(id)sender;
- (IBAction)pushedChangeGrade:(id)sender;
- (IBAction)changeColor:(id)sender;
- (IBAction)question:(id)sender;

@end