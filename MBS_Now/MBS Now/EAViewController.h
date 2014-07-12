//
//  EAViewController.h
//  MBS Now
//
//  Created by gdyer on 9/23/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
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