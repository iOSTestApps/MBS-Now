//
//  AddItemViewController.h
//  Community Service
//
//  Created by Lucas Fagan on 5/15/14.
//  Copyright (c) 2014 Lucas Fagan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddItemViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)donePressed:(id)sender;

@end
