//
//  BugsViewController.h
//  MBS Now
//
//  Created by gdyer on 10/11/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import <UIKit/UIKit.h>

@interface BugsViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate, UIAlertViewDelegate> {
    NSURLConnection *versionConnection;
    NSURLConnection *connect;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *bug;
@property (nonatomic, strong) NSArray *description;

@end