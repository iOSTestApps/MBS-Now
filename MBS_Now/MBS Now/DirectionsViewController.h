//
//  DirectionsViewController.h
//  MBS Now
//
//  Created by Graham Dyer on 1/29/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DirectionsViewController : UIViewController {
    
    MKCoordinateRegion viewRegion;
}

- (IBAction)openInMaps:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)pushedOrient:(id)sender;

@property (weak, nonatomic) IBOutlet MKMapView *directionsView;

@end
