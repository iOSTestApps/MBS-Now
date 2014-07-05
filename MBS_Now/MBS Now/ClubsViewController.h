//
//  ClubsViewController.h
//  MBS Now
//
//  Created by gdyer on 10/31/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import <UIKit/UIKit.h>

@interface ClubsViewController : UITableViewController <UIAlertViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

- (IBAction)pushedAdd:(id)sender;

@property (nonatomic, strong) NSMutableArray *csv;
@property (strong, nonatomic) NSArray *descriptions; // includes descriptions of data
@end