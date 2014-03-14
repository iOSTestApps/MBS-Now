//
//  ClubsViewController.h
//  MBS Now
//
//  Created by Graham Dyer on 10/31/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClubsViewController : UITableViewController <UIAlertViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
    BOOL firstTime;
}

- (IBAction)pushedAdd:(id)sender;
- (IBAction)pushedRefresh:(id)sender;

@property (nonatomic, strong) NSMutableArray *csv;
@property (strong, nonatomic) NSArray *descriptions; // includes descriptions of data
@property (weak, nonatomic) IBOutlet UITableView *tblView;


@end