//
//  EAViewController.h
//  MBS Now
//
//  Created by gdyer on 9/23/13.
//  Copyright (c) 2013 DevelopMBS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EAViewController : UIViewController <UIAlertViewDelegate, UITableViewDelegate, UITableViewDataSource, NSURLConnectionDataDelegate, NSURLConnectionDelegate> {
    NSArray *distinctions;
    NSArray *searchResults;

    NSString *string;
    
    IBOutlet UITableView *tblView;
    IBOutlet UISearchBar *_searchBar;

    NSURLConnection *firstConnection;
}

@end
