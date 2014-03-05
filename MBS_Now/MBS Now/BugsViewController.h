//
//  BugsViewController.h
//  MBS Now
//
//  Created by gdyer on 10/11/13.
//  Copyright (c) 2013 DevelopMBS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BugsViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate, UIAlertViewDelegate> {
    NSString *version;
    IBOutlet UINavigationBar *navBar;

    NSURLConnection *connect;
    NSURLConnection *versionConnection;
}

- (IBAction)pushedAdd:(id)sender;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *bug;
@property (nonatomic, strong) NSArray *description;

@end
