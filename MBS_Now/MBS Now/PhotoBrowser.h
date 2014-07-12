//
//  PhotoBrowser.h
//  MBS Now
//
//  Created by gdyer on 12/10/13.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import <UIKit/UIKit.h>

@interface PhotoBrowser : UIViewController <UIGestureRecognizerDelegate>
@property (strong, nonatomic) NSArray *imgNames;
@property (strong, nonatomic) NSMutableArray *imgs;
@property (strong, nonatomic) NSArray *descriptions;
@property (strong, nonatomic) NSString *navTitle;

@property (assign) BOOL showDismiss;
@property (assign) int counter;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIPageControl *pager;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIButton *dismiss;
@property (weak, nonatomic) IBOutlet UIButton *left;
@property (weak, nonatomic) IBOutlet UITextView *txtView;

- (IBAction)rightButton:(id)sender;
- (IBAction)leftButton:(id)sender;
- (IBAction)dismiss:(id)sender;

- (id)initWithImages:(NSArray *)imageNames showDismiss:(BOOL)show description:(NSArray *)subtitles title:(NSString *)title; // default

@end
