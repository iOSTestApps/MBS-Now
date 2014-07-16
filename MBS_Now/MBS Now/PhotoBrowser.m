//
//  PhotoBrowser.m
//  MBS Now
//
//  Created by gdyer on 12/10/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "PhotoBrowser.h"
@implementation PhotoBrowser

// CHANGE INIT AND STOPMEASURING'S NSUSERDEFAULT KEY FOR EACH VERSION

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];

    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Avenir" size:16], NSFontAttributeName, [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];

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

    if (!_showDismiss) {
        UISwipeGestureRecognizer *down = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        down.direction = UISwipeGestureRecognizerDirectionDown;
        [down setNumberOfTouchesRequired:1];
        [self.view addGestureRecognizer:down];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Avenir" size:16], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startMeasuring];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopMeasuring];
}

- (void)appDidEnterBackground:(NSNotification *)not {
    [self stopMeasuring];
}

- (void)appDidEnterForeground:(NSNotification *)not {
    [self startMeasuring];
}

- (void)startMeasuring {
    _startDate = [NSDate date];
}

- (void)stopMeasuring {
    NSInteger secondsInScreen = ABS([_startDate timeIntervalSinceNow]);
    // only record if this their first time (that what it's organic, and they cannot dismiss the view)
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"timeInPhotoBrowser"])
        [[NSUserDefaults standardUserDefaults] setInteger:secondsInScreen forKey:@"timeInPhotoBrowser"];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (id)init {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDict objectForKey:@"CFBundleShortVersionString"];
    PhotoBrowser *pb = [[PhotoBrowser alloc] initWithImages:@[@"lucas.png", @"t1.png", @"t2.png", @"cs.png", @"ios7-icon.jpg"] showDismiss:NO description:@[@"Lucas Fagan will be running the app from now on! Thank you for supporting MBS Now for the past two years! —Graham", @"Introducing Today, a personalized summary of all things MBS. Quickly view schedules, calendar events, news, meetings, deadlines, and more.", @"Today provides a data-driven approach to simplifying your day. It accumulates all the things you need and helps you keep on track.", @"Introducing Community Service. Add or view service opportunities to get more involved in and out of MBS.", @"For various reasons, MBS Now requires iOS 7 and higher. Tell your lame iOS 5 and 6 friends that it's time to update."] title:[NSString stringWithFormat:@"What's new in %@", version]];
    return pb;
}

- (id)initWithImages:(NSArray *)imageNames showDismiss:(BOOL)show description:(NSArray *)subtitles title:(NSString *)title {
    self.imgNames = imageNames;
    self.showDismiss = show;
    self.descriptions = subtitles;
    self.navTitle = title;
    return [super initWithNibName:@"PhotoBrowser_7"  bundle:nil];
}

- (void)rightSwipeHandle {
    [self.left setImage:[UIImage imageNamed:@"arrow-circle-01.png"] forState:UIControlStateNormal];
    if (self.counter < self.imgs.count - 1) {
        self.counter++;
        self.imgView.image = self.imgs[self.counter];
        self.pager.currentPage = self.counter;
        self.txtView.text = self.descriptions[self.counter];
        self.txtView.textColor = [UIColor whiteColor];
        self.txtView.font = [UIFont fontWithName:@"Avenir" size:14.0f];
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
        self.txtView.font = [UIFont fontWithName:@"Avenir" size:14.0f];
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