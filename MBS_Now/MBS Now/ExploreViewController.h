//
//  ExploreViewController.h
//  MBS Now
//
//  Created by gdyer on 3/22/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ExploreViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    MKCoordinateRegion viewRegion;
    NSArray *descriptions;
    NSArray *subtitles;
    NSArray *lat;
    NSArray *lon;

    NSMutableArray *annotations;
}

- (IBAction)pushedTable:(id)sender;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *listings;
@property (weak, nonatomic) IBOutlet UIButton *swap;

@property (assign) int *accessoryIndex;
@end