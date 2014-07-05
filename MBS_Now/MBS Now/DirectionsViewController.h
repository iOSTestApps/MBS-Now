//
//  DirectionsViewController.h
//  MBS Now
//
//  Created by gdyer on 1/29/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DirectionsViewController : UIViewController {
    MKCoordinateRegion viewRegion;
}
- (IBAction)openAction:(id)sender;
@property (weak, nonatomic) IBOutlet MKMapView *directionsView;
@end