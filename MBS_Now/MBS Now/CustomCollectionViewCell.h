//
//  CustomCollectionViewCell.h
//  MBS Now
//
//  Created by Lucas Fagan on 1/2/15.
//  Copyright (c) 2015 MBS Now. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end
