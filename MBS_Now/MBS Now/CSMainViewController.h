//
//  CSMainViewController.h
//  MBS Now
//
//  Created by Lucas Fagan on 5/15/14.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, NSURLConnectionDelegate> {
    UIActionSheet *sheet;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSString *footer;
@property (strong, nonatomic) NSArray *descs;
- (void)reloadData;

@end