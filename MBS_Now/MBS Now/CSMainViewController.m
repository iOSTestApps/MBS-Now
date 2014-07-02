//
//  ViewController.m
//  Community Service
//
//  Created by Lucas Fagan on 5/14/14.
//  Copyright (c) 2014 Lucas Fagan. All rights reserved.
//

#import "CSMainViewController.h"
#import "CSDetailViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return NO;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.array) {
        self.array = [[NSMutableArray alloc] init];
    }
    return self.array.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [[self.array objectAtIndex:indexPath.row] objectAtIndex:1];
    if ([[self.array[indexPath.row] objectAtIndex:7] isEqualToString:@"One Time Event"] && (![[self.array[indexPath.row] objectAtIndex:2] isEqualToString:@""])) {
         cell.detailTextLabel.text = [NSString stringWithFormat:@"On %@", [[self.array objectAtIndex:indexPath.row] objectAtIndex:2]];
    } else {
        cell.detailTextLabel.text = @"Ongoing Event";
    }
   
    NSLog(@"%@",self.array);
    
    // show the arrow at the end of a cell
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
	return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
#pragma mark- Actions
- (IBAction)sortByChanged:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    if (segmentedControl.selectedSegmentIndex == 1) {
        [self sortByDate];
    } else if (segmentedControl.selectedSegmentIndex == 2) {
        [self sortByCreationDate];
    } else if (segmentedControl.selectedSegmentIndex == 0) {
        [self sortByTitle];
    }
}
#pragma mark- Connection

-(void)reloadData {
    NSURL *url = [NSURL URLWithString:@"https://docs.google.com/spreadsheet/pub?key=0AsW47GVmNrjDdHZEWEoxS0lDVVpMVEg5LUR1ZnBIUkE&output=csv"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    __unused NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
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
    
    // self.descriptions = [self.csv objectAtIndex:0];
    //[self.csv removeObjectAtIndex:0];
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [self sortByTitle];
    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        [self sortByDate];
    } else if (self.segmentedControl.selectedSegmentIndex == 2) {
        [self sortByCreationDate];
    }
    [self.tableView reloadData];
    //  NSLog(@"%@",self.array);
    
    /* [[NSUserDefaults standardUserDefaults] setObject:self.csv forKey:@"meetingLog"];
     [[NSUserDefaults standardUserDefaults] synchronize];*/
    
}
#pragma mark- Sort By Methods
-(void)sortByDate{
    _array = [_array sortedArrayUsingComparator:^(id a, id b) {
        if ([a[2] isEqualToString:@""]) {
            return NSOrderedDescending;
        } else if ([b[2] isEqualToString:@""]) {
            return NSOrderedAscending;
        }
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
