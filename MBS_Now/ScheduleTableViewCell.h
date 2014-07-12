//
//  ScheduleTableViewCell.h
//  MBS Now
//
//  Created by gdyer on 5/27/14.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import <UIKit/UIKit.h>

@interface ScheduleTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *today;
@property (weak, nonatomic) IBOutlet UIImageView *tomorrow;

@end