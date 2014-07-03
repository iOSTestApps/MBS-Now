//
//  OfflineViewController.h
//  MBS Now
//
//  Created by gdyer on 6/6/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import <UIKit/UIKit.h>

@interface OfflineViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {

    NSArray *divisions;
}

- (IBAction)done:(id)sender;

@end
