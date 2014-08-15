//
//  CredentialsViewController.h
//  MBS Now
//
//  Created by gdyer on 8/6/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import <UIKit/UIKit.h>

@interface CredentialsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSArray *ids;
    NSArray *names;
    NSArray *keys;
}

@end
