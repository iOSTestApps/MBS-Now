//
//  WelcomesViewController.m
//  MBS Now
//
//  Created by gdyer on 4/1/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "WelcomesViewController.h"

@implementation WelcomesViewController
- (id)initWithIndexOfWelcome:(int)_iow {
    iow = _iow;
    return [super initWithNibName:@"WelcomesViewController_7" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UISwipeGestureRecognizer *down = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(done:)];
    down.direction = UISwipeGestureRecognizerDirectionDown;
    [down setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:down];

    switch (iow) {
        case 0: {
            imageView.image = [UIImage imageNamed:@"HMW.jpg"];
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
    return toInterfaceOrientation == UIDeviceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
}

@end