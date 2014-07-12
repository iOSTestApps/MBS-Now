//
//  UILabel+Avenir.m
//  MBS Now
//
//  Created by gdyer on 7/10/14.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "UILabel+Avenir.h"

@implementation UILabel (Avenir)

- (void)awakeFromNib {
    float s = self.font.pointSize - .5;
    self.font = [UIFont fontWithName:@"Avenir" size:s];
}

@end