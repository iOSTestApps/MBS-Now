//
//  StandardTableViewCell.h
//  MBS Now
//
//  Created by gdyer on 5/18/14.
//  Copyright (c) 2014 DevelopMBS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StandardTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) NSString *url;

@end