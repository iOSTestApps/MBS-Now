//
//  ViewController.h
//  MBS Now
//
//  Created by Lucas Fagan on 5/15/14.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
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
@property (strong, nonatomic) NSArray *descs;
- (void)reloadData;

@end