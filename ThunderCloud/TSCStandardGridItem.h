//
//  TSCStandardGridItem.h
//  ThunderCloud
//
//  Created by Sam Houghton on 16/03/2015.
//  Copyright (c) 2015 threesidedcube. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 
 A standard `UICollectionViewCell` which displays an image, title and detail string
 */
@interface TSCStandardGridItem : UICollectionViewCell

/**
 @abstract The imageView for the colleciton view cell
 */
@property (nonatomic, strong) UIImageView *imageView;

/**
 @abstract The text label for the colleciton view cell
 */
@property (nonatomic, strong) UILabel *textLabel;

/**
 @abstract The detail text label for the colleciton view cell
 */
@property (nonatomic, strong) UILabel *detailTextLabel;


@end
