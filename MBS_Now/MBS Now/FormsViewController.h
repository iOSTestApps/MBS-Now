//
//  FormsViewController.h
//  MBS Now
//
//  Created by gdyer on 3/20/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import <UIKit/UIKit.h>

@interface FormsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, UIAlertViewDelegate> {
    NSString *urlString;
}

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic, assign) NSMutableData *receivedData;
@property (strong, nonatomic) NSArray *dataArray;
@property (strong, nonatomic) NSArray *searchResults;

- (IBAction)howto:(id)sender;

@end