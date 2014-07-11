//
//  UITableViewCell+Width.m
//  MBS Now
//
//  Created by gdyer on 3/8/14.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import "UITableViewCell+Width.h"

@implementation UITableViewCell (Width)

- (void)setFrame:(CGRect)frame {
    frame.origin.x += 6;
    frame.size.width -= 2 * 6;
    self.textLabel.font = ([self.detailTextLabel.text isEqualToString:@""]) ? [UIFont fontWithName:@"Avenir" size:18.0f] : [UIFont fontWithName:@"Avenir" size:16.0f];
    self.detailTextLabel.font = [UIFont fontWithName:@"Avenir" size:12.0f];
    self.detailTextLabel.textColor = [UIColor darkGrayColor];
    [super setFrame:frame];
}

@end