//
//  UITableView+Reload.m
//  MBS Now
//
//  Created by gdyer on 11/24/14.
//  Copyright (c) 2014 MBS Now. All rights reserved.
//

#import "UITableView+Reload.h"

@implementation UITableView (Reload)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
- (void)reload {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) [self reloadData];
    else [self reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

@end