//
//  UIButton+Avenir.m
//  MBS Now
//
//  Created by gdyer on 7/10/14.
//  Copyright (c) 2014 DevelopMBS. All rights reserved.
//

#import "UIButton+Avenir.h"

@implementation UIButton (Avenir)

- (void)setFrame:(CGRect)frame {
    float s = self.titleLabel.font.pointSize;
    self.titleLabel.font = [UIFont fontWithName:@"Avenir" size:s];
    [super setFrame:frame];
}


@end
