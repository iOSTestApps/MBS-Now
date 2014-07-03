//
//  ViewController.m
//  Community Service
//
//  Created by Lucas Fagan on 5/14/14.
//  Copyright (c) 2014 Lucas Fagan. All rights reserved.
//

#import "CSMainViewController.h"
#import "CSDetailViewController.h"
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 20)];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.tableView setContentInset:UIEdgeInsetsMake((IS_IPHONE_5 ? 20 : 40),0,0,0)];

    [self reloadData];
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing..."];
    [refresh addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    [self.tableView addSubview:self.refreshControl];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"paperwork-7.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showSortOptions)];

    NSLog(@"%@",self.array);
}

#pragma mark- Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.array) self.array = [[NSMutableArray alloc] init];
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *iden = @"cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];

    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:iden];

    cell.textLabel.text = [[self.array objectAtIndex:indexPath.row] objectAtIndex:1];
    cell.detailTextLabel.text = ([self.array[indexPath.row][7] isEqualToString:@"One Time Event"] && (![self.array[indexPath.row][2] isEqualToString:@""])) ? [NSString stringWithFormat:@"On %@", self.array[indexPath.row][2]] : @"Ongoing Event";

    NSLog(@"%@",self.array);
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return _footer;
}

#pragma mark- Actions
- (void)showSortOptions {
    if (sheet) {
        [sheet dismissWithClickedButtonIndex:-1 animated:YES];
        sheet = nil;
        return;
    }

    sheet = [[UIActionSheet alloc] initWithTitle:@"Sort service opportunity listings by..." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Date", @"Modification date", @"Name", nil];

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [sheet showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
    else
        [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self sortByDate];
            break;
        case 1:
            [self sortByCreationDate];
            break;
        case 2:
            [self sortByTitle];
            break;
        default:
            break;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    sheet = nil;
}


- (void)sort:(int)i {
    switch (i) {
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
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy hh:mma"];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:[dateFormat stringFromDate:[NSDate date]]];
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
    [self sortByCreationDate];

    // self.descriptions = [self.csv objectAtIndex:0];
    //[self.csv removeObjectAtIndex:0];

    //  NSLog(@"%@",self.array);

    /* [[NSUserDefaults standardUserDefaults] setObject:self.csv forKey:@"meetingLog"];
     [[NSUserDefaults standardUserDefaults] synchronize];*/
}

#pragma mark- Sort By Methods
- (void)sortByDate{
    _array = [_array sortedArrayUsingComparator:^(id a, id b) {
        if ([a[2] isEqualToString:@""] || [a[7] isEqualToString:@"Ongoing"])
            return NSOrderedDescending;
        else if ([b[2] isEqualToString:@""] || [b[7] isEqualToString:@"Ongoing"])
            return NSOrderedAscending;
        NSString *string1 = a[2];
        NSString *string2 = b[2];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MM/dd/yy"];
        NSDate *date1 = [format dateFromString:string1];
        NSDate *date2 = [format dateFromString:string2];
        return [date1 compare:date2];
    }].mutableCopy;
    _footer = @"Sorted by opportunity date";
    [self.tableView reloadData];
}

- (void)sortByCreationDate {
    _array = [_array sortedArrayUsingComparator:^(id a, id b) {
        NSString *string1 = a[0];
        NSString *string2 = b[0];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
        NSDate *date1 = [format dateFromString:string1];
        NSDate *date2 = [format dateFromString:string2];
        return [date1 compare:date2];
    }].mutableCopy;
    _footer = @"Sorted by modification date";
    [self.tableView reloadData];
}

- (void)sortByTitle {
    _array = [_array sortedArrayUsingComparator:^(id a, id b) {
        NSString *string1 = a[1];
        NSString *string2 = b[1];
        NSLog(@"STRING 1: %@",a[1]);
        return [string1 caseInsensitiveCompare:string2];
    }].mutableCopy;
    _footer = @"Sorted alphabetically by name";
    [self.tableView reloadData];
}

#pragma mark - Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDetails"])
        ((CSDetailViewController *)segue.destinationViewController).array = self.array[_tableView.indexPathForSelectedRow.row];
}

@end