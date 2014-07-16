//
//  ArticleTableViewCell.h
//  MBS Now
//
//  Created by gdyer on 7/16/14.
//  Copyright (c) 2014 MBS Now. CC BY-NC 3.0 Unported https://creativecommons.org/licenses/by-nc/3.0/
//

#import <UIKit/UIKit.h>

@interface ArticleTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateTag;
@property (weak, nonatomic) IBOutlet UILabel *articleBody;

@end