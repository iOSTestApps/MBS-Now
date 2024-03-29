//
//  CSMainViewController.m
//  MBS Now
//
//  Created by Lucas Fagan on 5/15/14.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "CSMainViewController.h"
#import "CSDetailViewController.h"
#import "AddItemViewController.h"
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Community Service";
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, (IS_IPHONE_5) ? 20 : 40)];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
    self.tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    if (!IPAD) [self.tableView setContentInset:UIEdgeInsetsMake(20,0,0,0)];

    [self reloadData];
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Refreshing... just for you"];
    [refresh addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;

    [self.tableView addSubview:self.refreshControl];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"paperwork-7.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showSortOptions)];
    self.navigationItem.leftBarButtonItem.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
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
    if ([self.array[0] isKindOfClass:[NSString class]]) {
        cell.textLabel.text = self.array[indexPath.row];
        cell.detailTextLabel.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else {
        cell.textLabel.text = self.array[indexPath.row][1];
        cell.detailTextLabel.text = ([self.array[indexPath.row][7] isEqualToString:@"One Time Event"] && (![self.array[indexPath.row][2] isEqualToString:@""])) ? [NSString stringWithFormat:@"Happening on %@", self.array[indexPath.row][2]] : @"Ongoing Event";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self.array containsObject:@"Connection failure!"])
        [self performSegueWithIdentifier:@"csshowdetails" sender:self];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return ([self.array[indexPath.row] isKindOfClass:[NSString class]]) ? NO : YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return (_array.count > 1) ? _footer : nil;
}

#pragma mark Actions
- (void)showSortOptions {
    if (sheet) {
        [sheet dismissWithClickedButtonIndex:-1 animated:YES];
        sheet = nil;
        return;
    }

    sheet = [[UIActionSheet alloc] initWithTitle:@"Sort service opportunity listings" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Date", @"Modification date", @"Name", nil];

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

#pragma mark Connection
- (void)reloadData {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM d, h:mm:ss a";
    NSString *lastUpdated = [NSString stringWithFormat:@"Last updated %@", [formatter stringFromDate:[NSDate date]]];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    
    NSURL *url = [NSURL URLWithString:@"https://docs.google.com/spreadsheet/pub?key=0AsW47GVmNrjDdHZEWEoxS0lDVVpMVEg5LUR1ZnBIUkE&output=csv"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    __unused NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!_refreshControl.refreshing) [SVProgressHUD showWithStatus:@"Working..."];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    [_refreshControl endRefreshing];
    ((UIBarButtonItem *)self.navigationItem.leftBarButtonItems[0]).enabled = NO;
    [self.array removeAllObjects];
    self.array = [[NSMutableArray alloc] init];
    [self.array addObject:@"Connection failure!"];
    //self.tableView.userInteractionEnabled = NO;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
   // _tableView.userInteractionEnabled = YES;
    NSString *separation = @"\n";
    NSString *fileText = [NSString stringWithContentsOfURL:connection.currentRequest.URL encoding:NSMacOSRomanStringEncoding error:nil];

    NSArray *raw = [fileText componentsSeparatedByString:separation];
    self.array = [[NSMutableArray alloc] init];
    for (NSString *foo in raw) {
        NSArray *dummy = [foo componentsSeparatedByString:@","];
        [self.array addObject:dummy];
    }
    _descs = _array[0];
    if (self.array.count != 0) [self.array removeObjectAtIndex:0];
    if (_array.count > 1) ((UIBarButtonItem *)self.navigationItem.leftBarButtonItems[0]).enabled = YES;

//    NSLog(@"%@", _array[0]);

    [[NSUserDefaults standardUserDefaults] setObject:_array forKey:@"serviceLog"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [SVProgressHUD dismiss];
    [self.refreshControl endRefreshing];
    [self sortByCreationDate];
    [SVProgressHUD dismiss];
    [self.refreshControl endRefreshing];

    // self.descriptions = [self.csv objectAtIndex:0];
    //[self.csv removeObjectAtIndex:0];

    //  NSLog(@"%@",self.array);

    /* [[NSUserDefaults standardUserDefaults] setObject:self.csv forKey:@"meetingLog"];
     [[NSUserDefaults standardUserDefaults] synchronize];*/
}

#pragma mark Sorting methods
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
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
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
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)sortByTitle {
    _array = [_array sortedArrayUsingComparator:^(id a, id b) {
        NSString *string1 = a[1];
        NSString *string2 = b[1];
        return [string1 caseInsensitiveCompare:string2];
    }].mutableCopy;
    _footer = @"Sorted alphabetically by name";
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark Segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = _tableView.indexPathForSelectedRow;
    if ([segue.identifier isEqualToString:@"add"]) {
        [segue.destinationViewController setNameInit:@"service post"];
        [segue.destinationViewController setAddressInit:@"https://mbsdev.github.io/add-service.html"];
    }
    else if ([segue.identifier isEqualToString:@"csshowdetails"]) {
        [segue.destinationViewController setDetails:self.array[indexPath.row]];
        [segue.destinationViewController setDescriptions:_descs.mutableCopy];
    }
}

@end