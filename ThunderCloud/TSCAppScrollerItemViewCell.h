//
//  TSCAppScrollerItemViewCell.h
//  ThunderCloud
//
//  Created by Matt Cheetham on 23/06/2014.
//  Copyright (c) 2014 3 SIDED CUBE. All rights reserved.
//

@import UIKit;

/**
 A subclass of `UICollecionViewCell` for displaying an app
 */
@interface TSCAppScrollerItemViewCell : UICollectionViewCell

/**
 @abstract An image view for displaying the app icon
 */
@property (nonatomic, strong) UIImageView *appIconView;

/**
 @abstract A label for displaying the app name
 */
@property (nonatomic, strong) UILabel *nameLabel;

/**
 @abstract A label for displaying the app price
 */
@property (nonatomic, strong) UILabel *priceLabel;

@end
