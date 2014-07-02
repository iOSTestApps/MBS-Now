//
//  ViewController.m
//  Community Service
//
//  Created by Lucas Fagan on 5/14/14.
//  Copyright (c) 2014 Lucas Fagan. All rights reserved.
//

#import "CSMainViewController.h"
#import "CSDetailViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0)];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.tableView setContentInset:UIEdgeInsetsMake(20,0,0,0)];

    [self reloadData];

    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing..."];
    [refresh addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    [self.tableView addSubview:self.refreshControl];
    NSLog(@"%@",self.array);
}

#pragma mark- Table View
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.array) self.array = [[NSMutableArray alloc] init];
    return self.array.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    
    cell.textLabel.text = [[self.array objectAtIndex:indexPath.row] objectAtIndex:1];
    cell.detailTextLabel.text = ([self.array[indexPath.row][7] isEqualToString:@"One Time Event"] && (![self.array[indexPath.row][2] isEqualToString:@""])) ? [NSString stringWithFormat:@"On %@", self.array[indexPath.row][2]] : @"Ongoing Event";

    NSLog(@"%@",self.array);
    // show the arrow at the end of a cell
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
#pragma mark- Actions
- (IBAction)sortByChanged:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            [self sortByTitle];
            break;
        case 1:
            [self sortByDate];
            break;
        case 2:
            [self sortByCreationDate];
            break;
        default:
            break;
    }
}

#pragma mark- Connection
-(void)reloadData {
    NSURL *url = [NSURL URLWithString:@"https://docs.google.com/spreadsheet/pub?key=0AsW47GVmNrjDdHZEWEoxS0lDVVpMVEg5LUR1ZnBIUkE&output=csv"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    __unused NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!_refreshControl.refreshing) [SVProgressHUD showWithStatus:@"Working..."];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [SVProgressHUD dismiss];
    [self.refreshControl endRefreshing];
    NSString *separation = @"\n";
    NSString *fileText = [NSString stringWithContentsOfURL:connection.currentRequest.URL encoding:NSMacOSRomanStringEncoding error:nil];
    
    NSArray *raw = [fileText componentsSeparatedByString:separation];
    self.array = [[NSMutableArray alloc] init];
    for (NSString *foo in raw) {
        NSArray *dummy = [foo componentsSeparatedByString:@","];
        [self.array addObject:dummy];
    }
    [self.array removeObjectAtIndex:0];
    [self sortByChanged:nil];

    // self.descriptions = [self.csv objectAtIndex:0];
    //[self.csv removeObjectAtIndex:0];

    //  NSLog(@"%@",self.array);
    
    /* [[NSUserDefaults standardUserDefaults] setObject:self.csv forKey:@"meetingLog"];
     [[NSUserDefaults standardUserDefaults] synchronize];*/
    
}

#pragma mark- Sort By Methods
-(void)sortByDate{
    _array = [_array sortedArrayUsingComparator:^(id a, id b) {
        if ([a[2] isEqualToString:@""])
            return NSOrderedDescending;
        else if ([b[2] isEqualToString:@""])
            return NSOrderedAscending;
        NSString *string1 = a[2];
        NSString *string2 = b[2];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MM/dd/yy"];
        NSDate *date1 = [format dateFromString:string1];
        NSDate *date2 = [format dateFromString:string2];
        return [date1 compare:date2];
    }].mutableCopy;
    [self.tableView reloadData];
    
}

-(void)sortByCreationDate {
    _array = [_array sortedArrayUsingComparator:^(id a, id b) {
        NSString *string1 = a[0];
        NSString *string2 = b[0];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
        NSDate *date1 = [format dateFromString:string1];
        NSDate *date2 = [format dateFromString:string2];
        return [date1 compare:date2];
    }].mutableCopy;
    [self.tableView reloadData];
    
}

-(void)sortByTitle {
    _array = [_array sortedArrayUsingComparator:^(id a, id b) {
        NSString *string1 = a[1];
        NSString *string2 = b[1];
        NSLog(@"STRING 1: %@",a[1]);
        return [string1 caseInsensitiveCompare:string2];
    }].mutableCopy;
    [self.tableView reloadData];
    
}

#pragma mark- Other
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDetails"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        CSDetailViewController *destViewController = segue.destinationViewController;
        destViewController.array = [self.array objectAtIndex:indexPath.row];
    }
}

@end