//
//  AboutViewController.m
//  MBS Now
//
//  Created by gdyer on 2/7/13.
//  Copyright (c) 2013 DevelopMBS. All rights reserved.
//

#import "AboutViewController.h"
#import "WebViewController.h"
#import "WelcomesViewController.h"

@implementation AboutViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
         [self setUpButtonsWithColor:@"grey" andButtons:[NSArray arrayWithObjects:_1, _2, nil]];
    } else {
        // iPad
        [self setUpButtonsWithColor:@"grey" andButtons:[NSArray arrayWithObjects:_1, _2, _3, _4, nil]];
    }
    UIImage *toLoad = [UIImage imageNamed:@"P0.png"];
    imageView.image = toLoad;
}

- (void)setUpButtonsWithColor:(NSString *)name andButtons:(NSArray *)buttons {

    UIImage *buttonImage = [[UIImage imageNamed:[NSString stringWithFormat:@"%@Button.png", name]]
                            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:[NSString stringWithFormat:@"%@ButtonHighlight.png", name]]
                                     resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];

    for (int x = 0; x < buttons.count; x++) {
        [[buttons objectAtIndex:x] setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [[buttons objectAtIndex:x] setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
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
    
    WebViewController *wvc = [[WebViewController alloc] initWithURL:[NSURL URLWithString:@"http://gdyer.de/USCurriculum.html"]];
    [self presentViewController:wvc animated:YES completion:nil];
}

- (IBAction)pushedMSCurriculum:(id)sender {

    WebViewController *wvc = [[WebViewController alloc] initWithURL:[NSURL URLWithString:@"http://gdyer.de/MSCurriculum.html"]];
    [self presentViewController:wvc animated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    
    [self dismissViewControllerAnimated:TRUE completion:nil];
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

@end
