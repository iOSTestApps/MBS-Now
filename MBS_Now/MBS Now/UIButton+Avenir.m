//
//  UIButton+Avenir.m
//  MBS Now
//
//  Created by gdyer on 7/10/14.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "UIButton+Avenir.h"

@implementation UIButton (Avenir)

- (void)setFrame:(CGRect)frame {
    float s = self.titleLabel.font.pointSize;
    self.titleLabel.font = [UIFont fontWithName:@"Avenir" size:s];
    [super setFrame:frame];
}

@end