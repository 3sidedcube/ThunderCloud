//
//  RCBadgeScrollerItemViewCell.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSCBadgeScrollerItemViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *badgeImage;
@property (nonatomic) BOOL completed;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@end
