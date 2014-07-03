//
//  ContactViewController.h
//  MBS Now
//
//  Created by gdyer on 6/6/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import <UIKit/UIKit.h>

@interface ContactViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {

    NSArray *detail;
    NSArray *main;

    NSString *final;
}

@end