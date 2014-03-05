//
//  WelcomesViewController.m
//  MBS Now
//
//  Created by gdyer on 4/1/13.
//  Copyright (c) 2013 DevelopMBS. All rights reserved.
//

#import "WelcomesViewController.h"

@implementation WelcomesViewController

- (id)initWithIndexOfWelcome:(int)_iow {
    iow = _iow;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        return [super initWithNibName:@"WelcomesViewController_7"  bundle:nil];
    } else {
        return [super initWithNibName:@"WelcomesViewController_6"  bundle:nil];
    }
}

- (void)viewDidLoad
{
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        if(toInterfaceOrientation == UIDeviceOrientationPortrait) return YES;
        return NO;
    }
}

- (BOOL)shouldAutorotate {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return NO;
    }
}

@end
