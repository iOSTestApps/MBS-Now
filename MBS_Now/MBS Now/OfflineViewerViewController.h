//
//  OfflineViewerViewController.h
//  MBS Now
//
//  Created by gdyer on 3/11/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
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
