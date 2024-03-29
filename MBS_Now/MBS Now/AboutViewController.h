//
//  AboutViewController.h
//  MBS Now
//
//  Created by gdyer on 2/7/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController {

    IBOutlet UIButton *_1;
    IBOutlet UIButton *_2;
    IBOutlet UIButton *_3;
    IBOutlet UIButton *_4;

    IBOutlet UITextView *textView;
    IBOutlet UIImageView *imageView;
}

- (IBAction)pushedHeadmaster:(id)sender;
- (IBAction)pushedUSCurriculum:(id)sender;
- (IBAction)pushedMSCurriculum:(id)sender;
- (IBAction)pushedAdmission:(id)sender;
- (IBAction)done:(id)sender;

@end