//
//  OfflineViewerViewController.m
//  MBS Now
//
//  Created by Graham Dyer on 3/11/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
//

#import "OfflineViewerViewController.h"
#import <AudioToolbox/AudioServices.h>

@implementation OfflineViewerViewController

UIAlertView *defaultAlert;

- (void)viewDidLoad {
    [super viewDidLoad];

    imageView.image = [UIImage imageNamed:imageName];
    
    scrollView.contentSize = CGSizeMake(imageView.frame.size.width , imageView.frame.size.height);
    scrollView.maximumZoomScale = 3;
    scrollView.minimumZoomScale = 1;
    scrollView.clipsToBounds = YES;
    scrollView.delegate = self;
    scrollView.zoomScale = 1;
    [scrollView addSubview:imageView];
}

- (void)viewDidAppear:(BOOL)animated {
    if ([imageName isEqualToString:@"02.png"]) [SVProgressHUD showErrorWithStatus:@"Monday schedule here is not correct. A replacement has yet to be made available."];
}

- (id)initWithImageName:(NSString *)iName {
    imageName = iName;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        return [super initWithNibName:@"OfflineViewerViewController_7"  bundle:nil];
    } else {
        return [super initWithNibName:@"OfflineViewerViewController_6"  bundle:nil];
    }
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

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [sheet showFromBarButtonItem:output animated:YES];
    } else {
        [sheet showInView:self.view];
    }
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    
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
