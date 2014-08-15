//
//  ExploreViewController.m
//  MBS Now
//
//  Created by gdyer on 3/22/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "ExploreViewController.h"
#define METERSTOMILE 1609.344

@implementation ExploreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home-7-active.png"] style:UIBarButtonItemStylePlain target:self action:@selector(orient)];

    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 20)];
    footer.backgroundColor = [UIColor clearColor];
    self.listings.tableFooterView = footer;
    [self.listings setContentInset:UIEdgeInsetsMake(20,0,0,0)];

    self.listings.hidden = YES;
    CLLocationCoordinate2D radius;
    radius.latitude = 40.803974;
    radius.longitude = -74.448391;
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:radius radius:200];
    [self.mapView addOverlay:circle];
    lat = @[@"40.802721", @"40.802404", @"40.802345", @"40.803436", @"40.803596", @"40.803527", @"40.803054", @"40.802703", @"40.803286", @"40.803264", @"40.803242", @"40.803447", @"40.803728", @"40.804026", @"40.80428", @"40.804944", @"40.804542", @"40.804367", @"40.804479", @"40.804008", @"40.80385", @"40.805161", @"40.805697", @"40.803638"];
    lon = @[@"-74.448287", @"-74.448684", @"-74.450977", @"-74.449468", @"-74.449204", @"-74.448904", @"-74.449457", @"-74.448942", @"-74.448647", @"-74.449141", @"-74.449946", @"-74.450251", @"-74.449999", @"-74.4496", @"-74.449189", @"-74.448631", @"-74.44788", @"-74.448038", @"-74.448325", @"-74.448625", @"-74.447552", @"-74.447088", @"-74.447131", @"-74.449724"];
    descriptions = @[@"Entrance off of Whippany Rd", @"Exit on to Whippany Rd", @"Frelinghuysen Arboretum", @"Beard Hall (BH)", @"The Anderson Library", @"Grant Hall (GH)", @"South Wing (SW)", @"Alumni House", @"Wilkie Hall (WH)", @"Senior circle", @"Math Center (MC)", @"Science Annex (SA)", @"Science departement (SB) & cafeteria", @"Middle School (MS)", @"Founders' Hall (FH)", @"Faculty, staff, & senior parking", @"Main gymnasium", @"Rooke pool", @"Auxiliary gymnasium", @"Field-hockey & softball field", @"Football/soccer field", @"Baseball field", @"Exit on to Hanover Ave", @"The quad"];
    subtitles = @[@" ", @" ", @"Walking paths, beautiful scenery, faculty parking", @"1st Floor: offices, 2nd Floor: History Department, 3rd Floor: College Counseling", @"17,000 volumes, 12 databases, iMac stations, the Writing Center", @"1st Floor: World Languages Department, 2nd Floor: English Department", @"Lower and 1st floor: classrooms, 2nd Floor: the Learning Center", @"Alumni relations, school communications and news", @"Computer Science Department, iPad Help Desk, Digital Arts, Geosciences", @"Only seniors can walk across!", @"1st and 2nd Floor: Math classrooms", @"Physics classrooms", @"Lower Level: Science departement, Ground Level: Cafeteria", @"Access to Founders' Hall. Newly built", @"Theater, Dance Studio, Band and Choral Classrooms, Performing Arts Department", @" ", @"Fitness Center, Athletics Department", @"Go Crimson!", @"Go Crimson!", @"Go Crimson!", @"Go Crimson!", @"Go Crimson!", @" ", @"Surrounded by BH, SB/cafeteria, MC, and MS"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    self.mapView.showsUserLocation = YES;
    
    CLLocationCoordinate2D mbs;
    mbs.latitude = 40.804085;
    mbs.longitude = -74.448408;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        viewRegion = MKCoordinateRegionMakeWithDistance(mbs, .3 * METERSTOMILE, .3 * METERSTOMILE);
    } else {
        viewRegion = MKCoordinateRegionMakeWithDistance(mbs, .22 * METERSTOMILE, .22 * METERSTOMILE);
    }

    [self.mapView setRegion:viewRegion animated:YES];

    annotations = [[NSMutableArray alloc] init];
    for (int x = 0; x < lat.count; x++) {
        CLLocationCoordinate2D coord;
        NSString *foo = [lat objectAtIndex:x];
        NSString *bar = [lon objectAtIndex:x];
        coord.latitude = foo.floatValue;
        coord.longitude = bar.floatValue;

        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.title = [descriptions objectAtIndex:x];
        point.subtitle = [subtitles objectAtIndex:x];
        point.coordinate = coord;
        [annotations addObject:point];
        [self.mapView addAnnotation:point];
    }
}

#pragma mark Actions
- (void)orient {
    CLLocationCoordinate2D mbs;
    mbs.latitude = 40.804085;
    mbs.longitude = -74.44892;

    viewRegion = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? MKCoordinateRegionMakeWithDistance(mbs, .3 * METERSTOMILE, .3 * METERSTOMILE) : MKCoordinateRegionMakeWithDistance(mbs, .22 * METERSTOMILE, .22 * METERSTOMILE);

    [self.mapView setRegion:viewRegion animated:YES];
}

- (IBAction)pushedTable:(id)sender {
    [SVProgressHUD dismiss];
    if (self.mapView.hidden == YES) {
        // going back to the map
        self.mapView.hidden = NO;
        self.listings.hidden = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self.swap  setTitle:@"View listings" forState:UIControlStateNormal];
    } else {
        // to table view
        self.mapView.hidden = YES;
        self.listings.hidden = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [self.swap setTitle:@"Back to map" forState:UIControlStateNormal];
    }
}

#pragma mark Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return lat.count;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (![subtitles[indexPath.row] isEqualToString:@" "])
        [SVProgressHUD showImage:nil status:subtitles[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.mapView.hidden = NO;
    self.listings.hidden = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self.swap  setTitle:@"View listings" forState:UIControlStateNormal];

    [self.mapView selectAnnotation:[annotations objectAtIndex:indexPath.row] animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *iden = @"iden";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];

    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:iden];
    
    cell.textLabel.text = descriptions[indexPath.row];
    cell.detailTextLabel.text = subtitles[indexPath.row];
    // this is bad practice (to use pre-game values like this)
    cell.accessoryType = ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad && indexPath.row != 0 && indexPath.row != 1 && indexPath.row != 15 && indexPath.row != 22) ?
    UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryNone;
    return cell;
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) return YES;
    return (toInterfaceOrientation == UIDeviceOrientationPortrait) ? YES : NO;
}

#pragma mark Map
- (MKOverlayView *)mapView:(MKMapView *)map viewForOverlay:(id <MKOverlay>)overlay {
    MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
    circleView.strokeColor = [[UIColor redColor] colorWithAlphaComponent:.5];
    circleView.fillColor = [[UIColor whiteColor] colorWithAlphaComponent:0.18];
    return circleView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    [mapView deselectAnnotation:view.annotation animated:YES];
    self.mapView.hidden = YES;
    self.listings.hidden = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.swap  setTitle:@"Back to map" forState:UIControlStateNormal];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[annotations indexOfObject:view.annotation] inSection:0];
    [self.listings selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        ((MKUserLocation *)annotation).title = @"You!";
        return nil;
    }
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pinView"];
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinView"];
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.animatesDrop = FALSE;
        pinView.canShowCallout = YES;

        pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    } else
        pinView.annotation = annotation;
    return pinView;
}
- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    [SVProgressHUD showErrorWithStatus:error.localizedDescription];
}

@end