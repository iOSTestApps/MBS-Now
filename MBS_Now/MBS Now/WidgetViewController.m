//
//  WidgetViewController.m
//  MBS Now
//
//  Created by Graham Dyer on 1/10/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "WidgetViewController.h"
#import "FormsViewerViewController.h"

@implementation WidgetViewController
@synthesize _webView, receivedData;

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [self viewDidLoad];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autoCheck"] == 0) {
        NSURL *myURL = [NSURL URLWithString:@"https://docs.google.com/spreadsheet/pub?key=0Ar9jhHUssWrpdGJSYTFjWWhDWndKQW0yckluTU5PX1E&output=csv"];
        NSURLRequest *request = [NSURLRequest requestWithURL:myURL
                                                 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                             timeoutInterval:20];
        meetingsConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    [specialConnection cancel];
    specialConnection = nil;
    [_webView stopLoading];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.unique = YES;
    [_webView setDelegate:self];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://campus.mbs.net/mbs/widget/daySched.php"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:25];
    [_webView loadRequest:request];

    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE];

    if (connection)
        receivedData = [NSMutableData data];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark Actions
- (IBAction)pushedReload:(id)sender {
    [SVProgressHUD dismiss];
    [self viewDidAppear:YES];
}

- (IBAction)pushedSpecial:(id)sender {
    [_webView stopLoading];
    [SVProgressHUD dismiss];

    [SVProgressHUD showWithStatus:@"Loading"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://campus.mbs.net/mbsnow/home/forms/Special.pdf"] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:20];
    specialConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:TRUE];
    if (specialConnection) receivedData = [NSMutableData data];
}

#pragma mark Connection
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == specialConnection) {
        if ([(NSHTTPURLResponse *)response statusCode] == 404)
            [SVProgressHUD showImage:[UIImage imageNamed:@"clock@2x.png"] status:@"No special schedules this week"];
        else {
            FormsViewerViewController *fvvc = [[FormsViewerViewController alloc] initWithStringForURL:@"Special"];
            fvvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentViewController:fvvc animated:YES completion:nil];
        }
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    [SVProgressHUD showWithStatus:@"Loading..."];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [SVProgressHUD dismiss];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [SVProgressHUD dismiss];
    [SVProgressHUD showErrorWithStatus:[error localizedDescription]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == meetingsConnection) {
        NSString *separation = @"\n";
        NSString *fileText = [NSString stringWithContentsOfURL:connection.currentRequest.URL encoding:NSMacOSRomanStringEncoding error:nil];
        NSArray *raw = [fileText componentsSeparatedByString:separation];
        NSMutableArray *csv = [[NSMutableArray alloc] init];
        for (NSString *foo in raw) {
            NSArray *dummy = [foo componentsSeparatedByString:@","];
            [csv addObject:dummy];
        }
        [csv removeObjectAtIndex:0];

        NSArray *clubNames = [[NSUserDefaults standardUserDefaults] objectForKey:@"meetingLog"];
        if ([self compareArrays:csv and:clubNames] == NO) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Meetings have changed" message:@"A meeting has been modified or added since your last refresh. Tap the 'Clubs' tab to learn more." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
            [alert show];
            [[NSUserDefaults standardUserDefaults] setObject:csv forKey:@"meetingLog"];
        }
    }
}

- (BOOL)compareArrays:(NSArray *)array1 and:(NSArray *)array2 {
    for (NSString *name in array1) {
        if (![array2 containsObject:name]) {
            return NO;
            break;
        }
    }

    for (NSString *name in array2) {
        if (![array1 containsObject:name]) {
            return NO;
            break;
        }
    }

    return YES; // they're the same
}

#pragma mark Rotation
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://campus.mbs.net/mbs/widget/daySched.php"]]];
}

#pragma mark Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) return YES;
    return (toInterfaceOrientation == UIDeviceOrientationPortrait) ? YES : NO;
}


@end