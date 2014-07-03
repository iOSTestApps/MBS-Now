//
//  OfflineViewerViewController.h
//  MBS Now
//
//  Created by gdyer on 3/11/13.
//  Copyright (c) 2014 MBS Now. Some rights reserved; (CC) BY-NC-SA
//

#import <UIKit/UIKit.h>

@interface OfflineViewerViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate> {
    
    IBOutlet UIBarButtonItem *output;
    UIActionSheet *sheet;
    
    NSString *imageName;
    UIImage *_image;
    IBOutlet UIImageView *imageView;
    IBOutlet UIScrollView *scrollView;
}

- (id)initWithImageName:(NSString *)iName;
- (IBAction)output:(id)sender;
- (IBAction)done:(id)sender;

@end
