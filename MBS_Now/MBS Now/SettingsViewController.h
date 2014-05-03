//
//  SettingsViewController.h
//  MBS Now
//
//  Created by Graham Dyer on 8/16/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
    
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

- (void)setUpGeneralNotifications:(int)q;
- (void)setUpAB_Notifications:(int)q;
- (void)setUpDressUpNotifications:(int)q withHour:(NSString *)hours;

@end
