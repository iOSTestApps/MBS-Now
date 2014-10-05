//
//  ClubsViewController.h
//  MBS Now
//
//  Created by gdyer on 10/31/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import <UIKit/UIKit.h>

@interface ClubsViewController : UITableViewController <UIAlertViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) NSMutableArray *csv;
@property (strong, nonatomic) NSArray *descriptions; // includes descriptions of data
@property (assign) BOOL showHistory;
@end