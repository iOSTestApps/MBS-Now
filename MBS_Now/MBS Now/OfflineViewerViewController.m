//
//  OfflineViewerViewController.m
//  MBS Now
//
//  Created by gdyer on 3/11/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import "OfflineViewerViewController.h"
#import <AudioToolbox/AudioServices.h>
#import "UIView+Toast.h"
@implementation OfflineViewerViewController

UIAlertView *defaultAlert;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Offline Schedules";
    imageView.image = [UIImage imageNamed:imageName];
    
    scrollView.contentSize = CGSizeMake(imageView.frame.size.width , imageView.frame.size.height);
    scrollView.maximumZoomScale = 3;
    scrollView.minimumZoomScale = 1;
    scrollView.clipsToBounds = YES;
    scrollView.delegate = self;
    scrollView.zoomScale = 1;
    [scrollView addSubview:imageView];

    UISwipeGestureRecognizer *down = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(done:)];
    down.direction = UISwipeGestureRecognizerDirectionDown;
    [down setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:down];
}

- (id)initWithImageName:(NSString *)iName {
    imageName = iName;
    return [super initWithNibName:@"OfflineViewerViewController_7"  bundle:nil];
}

- (IBAction)done:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    imageName = nil;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return imageView;
}

- (IBAction)output:(id)sender {
    if (sheet) {
        [sheet dismissWithClickedButtonIndex:-1 animated:YES];
        sheet = nil;
        return;
    }
    
    sheet = [[UIActionSheet alloc] initWithTitle:@"Output options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save to camera roll", nil];

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [sheet showFromBarButtonItem:output animated:YES];
    else
        [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSData *pngdata = UIImagePNGRepresentation (imageView.image); //PNG wrap
        UIImage *img = [UIImage imageWithData:pngdata];
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);

        [SVProgressHUD showImage:[UIImage imageNamed:@"image@2x.png"] status:@"Saved"];
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    sheet = nil;
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