//
//  TodayCellTableViewCell.h
//  MBS Now
//
//  Created by gdyer on 5/18/14.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import <UIKit/UIKit.h>

@interface TodayCellTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *dateTag;
@property (weak, nonatomic) IBOutlet UITextView *messageBody;
@end