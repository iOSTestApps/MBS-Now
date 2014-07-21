//
//  EventTableViewCell.h
//  MBS Now
//
//  Created by gdyer on 7/11/14.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import <UIKit/UIKit.h>

@interface EventTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *locIcon;
@property (weak, nonatomic) IBOutlet UILabel *locTag;
@property (weak, nonatomic) IBOutlet UILabel *dateTag;
@property (weak, nonatomic) IBOutlet UITextView *eventBody;
//@property (weak, nonatomic) IBOutlet UILabel *addToCal;
@end