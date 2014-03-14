//
//  FullPurposeViewController.h
//  MBS Now
//
//  Created by Graham Dyer on 11/3/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FullPurposeViewController : UIViewController

// iPad only
- (IBAction)pushedDone:(id)sender;

@property (strong, nonatomic) NSString *fullPurpose;
@property (strong, nonatomic) NSString *navTitle;

@property (weak, nonatomic) IBOutlet UITextView *tv;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (assign) BOOL hideNavBar;


@end
