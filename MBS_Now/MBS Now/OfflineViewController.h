//
//  OfflineViewController.h
//  MBS Now
//
//  Created by gdyer on 6/6/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import <UIKit/UIKit.h>

@interface OfflineViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {

    NSArray *divisions;
}

- (IBAction)done:(id)sender;

@end