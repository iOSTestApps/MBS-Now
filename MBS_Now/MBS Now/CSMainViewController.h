//
//  ViewController.h
//  Community Service
//
//  Created by Lucas Fagan on 5/14/14.
//  Copyright (c) 2014 Lucas Fagan. All rights reserved.
//

#import <UIKit/UIKit.h>

//things to do: SVProgressHUDs, iPhone 3.5 inch, iPad

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSURLConnectionDelegate>
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)sortByChanged:(id)sender;
-(void)reloadData;
@end
