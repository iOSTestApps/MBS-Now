//
//  OfflineViewController.h
//  MBS Now
//
//  Created by gdyer on 6/6/13.
//  Copyright (c) 2013 DevelopMBS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OfflineViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {

    NSArray *divisions;
}

- (IBAction)done:(id)sender;

@end
