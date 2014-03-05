//
//  ExploreViewController.h
//  MBS Now
//
//  Created by gdyer on 3/22/13.
//  Copyright (c) 2013 DevelopMBS. All rights reserved.
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

- (IBAction)done:(id)sender;
- (IBAction)pushedOrient:(id)sender;
- (IBAction)pushedTable:(id)sender;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *listings;
@property (weak, nonatomic) IBOutlet UIButton *swap;
@property (weak, nonatomic) IBOutlet UIButton *home;

@property (assign) int *accessoryIndex;

@end
