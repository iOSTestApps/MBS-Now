//
//  CredentialsViewController.h
//  MBS Now
//
//  Created by Graham Dyer on 8/6/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CredentialsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {

    NSArray *ids;
    NSArray *names;
    NSArray *keys;
}

@end
