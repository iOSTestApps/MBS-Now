//
//  StandardTableViewCell.m
//  MBS Now
//
//  Created by gdyer on 5/18/14.
//  Copyright (c) 2014 DevelopMBS. All rights reserved.
//

#import "StandardTableViewCell.h"

@implementation StandardTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
