//
//  UILabel+Avenir.m
//  MBS Now
//
//  Created by gdyer on 7/10/14.
//  Copyright (c) 2014 DevelopMBS. All rights reserved.
//

#import "UILabel+Avenir.h"

@implementation UILabel (Avenir)

- (void)awakeFromNib {
    float s = self.font.pointSize - .5;
    self.font = [UIFont fontWithName:@"Avenir" size:s];
}

@end