//
//  CredentialsViewController.h
//  MBS Now
//
//  Created by gdyer on 8/6/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import <UIKit/UIKit.h>

@interface CredentialsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {

    NSArray *ids;
    NSArray *names;
    NSArray *keys;
}

@end
