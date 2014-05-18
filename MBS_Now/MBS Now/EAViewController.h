//
//  EAViewController.h
//  MBS Now
//
//  Created by Graham Dyer on 9/23/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EAViewController : UIViewController <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    NSArray *distinctions;

    NSString *string;

    NSURLConnection *firstConnection;
}

@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UISearchBar *_searchBar;

@end