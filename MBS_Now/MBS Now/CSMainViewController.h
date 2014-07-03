//
//  ViewController.h
//  Community Service
//
//  Created by Lucas Fagan on 5/14/14.
//  Copyright (c) 2014 Lucas Fagan. All rights reserved.
//

#import <UIKit/UIKit.h>

// TODO: iPhone 4(S), iPad, details VC design here should mirror details VC for clubs

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, NSURLConnectionDelegate> {
    UIActionSheet *sheet;
}
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *footer;
- (void)reloadData;

@end