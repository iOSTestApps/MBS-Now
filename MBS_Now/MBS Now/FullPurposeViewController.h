//
//  FullPurposeViewController.h
//  MBS Now
//
//  Created by gdyer on 11/3/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
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
