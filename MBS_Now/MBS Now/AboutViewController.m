//
//  AboutViewController.m
//  MBS Now
//
//  Created by gdyer on 2/7/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "AboutViewController.h"
#import "SVModalWebViewController.h"
#import "WelcomesViewController.h"

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpButtonsWithColor:@"grey" andButtons:([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? @[_1, _2] : @[_1, _2, _3, _4]];
    imageView.image = [UIImage imageNamed:@"P0.png"];
}

- (void)setUpButtonsWithColor:(NSString *)name andButtons:(NSArray *)buttons {
    UIImage *buttonImage = [[UIImage imageNamed:[NSString stringWithFormat:@"%@Button.png", name]]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:[NSString stringWithFormat:@"%@ButtonHighlight.png", name]]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];

    for (UIButton *foo in buttons) {
        [foo setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [foo setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    }
}

#pragma mark Actions
- (IBAction)pushedHeadmaster:(id)sender {
    WelcomesViewController *wvc = [[WelcomesViewController alloc] initWithIndexOfWelcome:0];
    [self presentViewController:wvc animated:YES completion:nil];
}

- (IBAction)pushedAdmission:(id)sender {
    WelcomesViewController *wvc = [[WelcomesViewController alloc] initWithIndexOfWelcome:1];
    [self presentViewController:wvc animated:YES completion:nil];
}

- (IBAction)pushedUSCurriculum:(id)sender {
    SVModalWebViewController *wvc = [[SVModalWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://www.mbs.net/page.cfm?p=529"]];
    [self presentViewController:wvc animated:YES completion:nil];
}

- (IBAction)pushedMSCurriculum:(id)sender {
    SVModalWebViewController *wvc = [[SVModalWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://www.mbs.net/page.cfm?p=1412"]];
    [self presentViewController:wvc animated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) return YES;
    return toInterfaceOrientation == UIDeviceOrientationPortrait;
}

@end