//
//  WelcomesViewController.h
//  MBS Now
//
//  Created by gdyer on 4/1/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import <UIKit/UIKit.h>

@interface WelcomesViewController : UIViewController {
    
    IBOutlet UIImageView *imageView;
    IBOutlet UITextView *textView;
    IBOutlet UINavigationBar *navBar;
    UIImage *image;
    int iow;
    NSString *stringToLoad;
}

- (IBAction)done:(id)sender;
- (id)initWithIndexOfWelcome:(int)_iow;

@end
