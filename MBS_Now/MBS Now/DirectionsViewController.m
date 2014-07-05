//
//  DirectionsViewController.m
//  MBS Now
//
//  Created by gdyer on 1/29/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import "DirectionsViewController.h"
#define METERSTOMILE 1609.344

@implementation DirectionsViewController
@synthesize directionsView;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	CLLocationCoordinate2D mbs;
    mbs.latitude = 40.804085;
    mbs.longitude = -74.448408;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Open Maps" style:UIBarButtonItemStyleBordered target:self action:@selector(openMaps)];

    viewRegion = MKCoordinateRegionMakeWithDistance(mbs, .3 * METERSTOMILE, .3 * METERSTOMILE);
    
    [directionsView setRegion:viewRegion animated:YES];
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = mbs;
    point.title = @"Morristown-Beard School";
    point.subtitle = @"70 Whippany Road, 07960";
    [self.directionsView addAnnotation:point];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home-7-active.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(orient)];
}

#pragma mark Actions
- (IBAction)openAction:(id)sender {
    [self openMaps];
}
- (void)openMaps {
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
        CLLocationCoordinate2D mbs = CLLocationCoordinate2DMake(40.804085, -74.448408);
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:mbs addressDictionary:nil];
        MKMapItem *mapItem = [[[MKMapItem alloc] init] initWithPlacemark:placemark];
        
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
        [MKMapItem openMapsWithItems:@[currentLocation, mapItem] launchOptions:launchOptions];
    }
}

- (void)orient {
    CLLocationCoordinate2D mbs;
    mbs.latitude = 40.80;
    mbs.longitude = -74.44;
    
    [directionsView setRegion:viewRegion animated:YES];
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    [SVProgressHUD dismiss];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mapping Failed" message:[NSString stringWithFormat:@"%@", error.localizedDescription] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) return YES;
    return (toInterfaceOrientation == UIDeviceOrientationPortrait) ? YES : NO;
}

@end