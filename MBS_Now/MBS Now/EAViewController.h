//
//  EAViewController.h
//  MBS Now
//
//  Created by gdyer on 9/23/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import <UIKit/UIKit.h>

@interface EAViewController : UIViewController <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    NSArray *distinctions;
    NSString *string;
    NSURLConnection *firstConnection;
}

@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (nonatomic) UIRefreshControl *refreshControl;

@end