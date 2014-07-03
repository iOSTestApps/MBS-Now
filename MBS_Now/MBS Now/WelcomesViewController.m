//
//  WelcomesViewController.m
//  MBS Now
//
//  Created by gdyer on 4/1/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import "WelcomesViewController.h"

@implementation WelcomesViewController
- (id)initWithIndexOfWelcome:(int)_iow {
    iow = _iow;
    return [super initWithNibName:@"WelcomesViewController_7" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    switch (iow) {
        case 0: {
            imageView.image = [UIImage imageNamed:@"Headmaster_Caldwell_Oct.jpg"];
            NSString *path = [[NSBundle mainBundle] pathForResource:@"HeadmasterWelcome"
                                                             ofType:@"txt"];
            [textView setText:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil]]
            ;
            navBar.topItem.title = @"Headmaster's Welcome";
            break;
        }
        case 1: {
            imageView.image = [UIImage imageNamed:@"RMitchellWebPic.jpg"];
            NSString *path = [[NSBundle mainBundle] pathForResource:@"AdmissionWelcome" ofType:@"txt"];
            [textView setText:[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil]];
            navBar.topItem.title = @"Admission Welcome";
        }
        default:
            break;
    }
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) return YES;
    return (toInterfaceOrientation == UIDeviceOrientationPortrait) ? YES : NO;
}

- (BOOL)shouldAutorotate {
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? YES : NO;
}

@end
