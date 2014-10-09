//
//  ContactViewController.h
//  MBS Now
//
//  Created by gdyer on 6/6/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import <UIKit/UIKit.h>

@interface ContactViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {

    NSArray *detail;
    NSArray *main;

    NSString *final;
}

@end