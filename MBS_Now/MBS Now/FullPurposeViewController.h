//
//  FullPurposeViewController.h
//  MBS Now
//
//  Created by 9fermat on 11/3/13.
//  Copyright (c) 2013 DevelopMBS. All rights reserved.
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
