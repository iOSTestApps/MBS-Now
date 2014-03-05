//
//  ContactViewController.h
//  MBS Now
//
//  Created by gdyer on 6/6/13.
//  Copyright (c) 2013 DevelopMBS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {

    NSArray *detail;
    NSArray *main;

    NSString *final;
}

- (IBAction)done:(id)sender;

@end
