//
//  RCBadgeScrollerItemViewCell.h
//  ThunderStorm
//
//  Created by Matt Cheetham on 27/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 `TSCBadgeScrollerItemViewCell` is a `UICollectionViewCell` that represents a badge in a collection view
 */
@interface TSCBadgeScrollerItemViewCell : UICollectionViewCell

/**
 @abstract a `UIImageView` that gets set to the badges icon
 */
@property (nonatomic, strong) UIImageView *badgeImage;

/**
 @abstract a BOOL thats is used to see if the badge has been unlocked or not
 */
@property (nonatomic) BOOL completed;

/**
 @abstract a `UILabel` that gets set to the badges title
 */
@property (nonatomic, strong) UILabel *titleLabel;

@end
