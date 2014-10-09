//
//  DirectionsViewController.h
//  MBS Now
//
//  Created by gdyer on 1/29/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DirectionsViewController : UIViewController {
    MKCoordinateRegion viewRegion;
}
- (IBAction)openAction:(id)sender;
@property (weak, nonatomic) IBOutlet MKMapView *directionsView;
@end