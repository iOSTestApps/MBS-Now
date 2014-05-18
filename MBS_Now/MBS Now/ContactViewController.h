//
//  ContactViewController.h
//  MBS Now
//
//  Created by Graham Dyer on 6/6/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {

    NSArray *detail;
    NSArray *main;

    NSString *final;
}

@end