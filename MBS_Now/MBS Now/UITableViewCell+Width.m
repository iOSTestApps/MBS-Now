//
//  UITableViewCell+Width.m
//  GasMoney
//
//  Created by gdyer on 3/8/14.
//  Copyright (c) 2014 Hack@Brown. All rights reserved.
//

#import "UITableViewCell+Width.h"

@implementation UITableViewCell (Width)

- (void)setFrame:(CGRect)frame {
    frame.origin.x += 6;
    frame.size.width -= 2 * 6;
    [super setFrame:frame];
}

@end