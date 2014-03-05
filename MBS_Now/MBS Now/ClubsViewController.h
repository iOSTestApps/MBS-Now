//
//  ClubsViewController.h
//  MBS Now
//
//  Created by 9fermat on 10/31/13.
//  Copyright (c) 2013 DevelopMBS. All rights reserved.
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
