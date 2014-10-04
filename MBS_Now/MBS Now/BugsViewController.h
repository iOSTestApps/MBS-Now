//
//  BugsViewController.h
//  MBS Now
//
//  Created by gdyer on 10/11/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import <UIKit/UIKit.h>

@interface BugsViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate, UIAlertViewDelegate> {
    NSURLConnection *versionConnection;
    NSMutableData *versionData;
    
    NSMutableData *connectionData;
    NSURLConnection *connect;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *bug;
@property (nonatomic, strong) NSMutableArray *mainTitle;

@end