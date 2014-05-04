//
//  BugsViewController.h
//  MBS Now
//
//  Created by Graham Dyer on 10/11/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BugsViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate, UIAlertViewDelegate> {

    NSURLConnection *versionConnection;

    NSURLConnection *connect;

    IBOutlet UINavigationBar *navBar;
}

- (IBAction)pushedAdd:(id)sender;

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *bug;
@property (nonatomic, strong) NSArray *description;

@end
