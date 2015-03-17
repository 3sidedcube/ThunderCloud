//
//  TSCPokemonCollectionViewCell.h
//  ThunderStorm
//
//  Created by Andrew Hart on 15/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>

#define POKEMON_IMAGE_SIZE CGSizeMake(57, 57)

/**
 `TSCPokemonItemView` is a view which represents an app inside a `TSCPokemonTableViewCell`
 */
@interface TSCPokemonItemView : UIView

/**
 @abstract A `UIButton` that gets laid out over the top of the view to handle selection
 */
@property (nonatomic, strong) UIButton *button;

/**
 @abstract A `UIImageView` that is the apps icon
 */
@property (nonatomic, strong) UIImageView *imageView;

/**
 @abstract A `UILabel` that is set to the name of the app
 */
@property (nonatomic, strong) UILabel *label;

@end
