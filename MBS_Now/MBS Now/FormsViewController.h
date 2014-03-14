//
//  FormsViewController.h
//  MBS Now
//
//  Created by Graham Dyer on 3/20/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate> {

    NSString *urlString;
    
    IBOutlet UISearchBar *_searchBar;
    IBOutlet UITableView *tblView;
}

@property (nonatomic, assign) NSMutableData *receivedData;
@property (strong, nonatomic) NSArray *dataArray;
@property (strong, nonatomic) NSArray *searchResults;

- (IBAction)refresh:(id)sender;
- (IBAction)howto:(id)sender;

@end
