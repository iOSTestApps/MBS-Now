//
//  PhotoBrowser.m
//  MBS Now
//
//  Created by Graham Dyer on 12/10/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import "PhotoBrowser.h"

@implementation PhotoBrowser

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imgs = [[NSMutableArray alloc] init];
    NSMutableArray *foo = [[NSMutableArray alloc] init];
    for (NSString *name in self.imgNames)
        [foo addObject:[UIImage imageNamed:name]];
    self.imgs = foo;

    self.imgView.image = self.imgs[0];
    self.pager.numberOfPages = self.imgs.count;
    self.pager.currentPage = 0;
    self.counter = 0;
    self.dismiss.hidden = !self.showDismiss;
    self.navBar.topItem.title = self.navTitle;
    self.txtView.text = self.descriptions[0];

    UISwipeGestureRecognizer *rrecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeHandle)];
    rrecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [rrecognizer setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:rrecognizer];

    UISwipeGestureRecognizer *lrecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeHandle)];
    lrecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [lrecognizer setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:lrecognizer];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (id)init {
    PhotoBrowser *pb = [[PhotoBrowser alloc] initWithImages:[NSArray arrayWithObjects:@"lucas.png", @"campus.png", @"github.png", nil] showDismiss:NO description:[NSArray arrayWithObjects:@"We're happy to announce Lucas Fagan will be running the app from now on! Graham is leaving for college!", @"All of our data is now stored on campus.mbs.net/mbsnow, making connections much faster (and more secure).", @"The app is now entirely open sourced on GitHub. Tell your friends! ow.ly/wlnSW.", nil] title:@"What's new in 3.6.1"];
    return pb;
}

- (id)initWithImages:(NSArray *)imageNames showDismiss:(BOOL)show description:(NSArray *)subtitles title:(NSString *)title {
    self.imgNames = imageNames;
    self.showDismiss = show;
    self.descriptions = subtitles;
    self.navTitle = title;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        return [super initWithNibName:@"PhotoBrowser_7"  bundle:nil];
    } else {
        return [super initWithNibName:@"PhotoBrowser_6"  bundle:nil];
    }
    return self;
}

- (void)rightSwipeHandle {
    [self.left setImage:[UIImage imageNamed:@"arrow-circle-01.png"] forState:UIControlStateNormal];
    if (self.counter < self.imgs.count - 1) {
        self.counter++;
        self.imgView.image = self.imgs[self.counter];
        self.pager.currentPage = self.counter;
        self.txtView.text = self.descriptions[self.counter];
        self.txtView.textColor = [UIColor whiteColor];
        self.txtView.font = [UIFont systemFontOfSize:15];
    } else if (self.counter == self.imgs.count - 1) {
        // reached end
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)leftSwipeHandle {
    if (self.counter < self.imgs.count && self.counter > 0) {
        self.counter--;
        self.imgView.image = self.imgs[self.counter];
        self.pager.currentPage = self.counter;
        self.txtView.text = self.descriptions[self.counter];
        self.txtView.textColor = [UIColor whiteColor];
        self.txtView.font = [UIFont systemFontOfSize:15];
        if (self.counter == 0)
            [self.left setImage:[UIImage imageNamed:@"arrow-circle-01g.png"] forState:UIControlStateNormal];
    }
}

#pragma mark Actions
- (IBAction)leftButton:(id)sender {
    [self leftSwipeHandle];
}

- (IBAction)rightButton:(id)sender {
    [self rightSwipeHandle];
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
