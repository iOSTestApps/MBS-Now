//
//  CredentialsViewController.h
//  MBS Now
//
//  Created by gdyer on 8/6/13.
//  Copyright (c) 2013 DevelopMBS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CredentialsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {

    NSArray *ids;
    NSArray *names;
    NSArray *keys;
}

@end
