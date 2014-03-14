//
//  AboutViewController.h
//  MBS Now
//
//  Created by Graham Dyer on 2/7/13.
//  Copyright (c) 2013 MBS Now. All rights reserved.
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

@end
