//
//  TSCPokemonCollectionViewCell.h
//  ThunderStorm
//
//  Created by Andrew Hart on 15/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import <UIKit/UIKit.h>

#define POKEMON_IMAGE_SIZE CGSizeMake(57, 57)

@interface TSCPokemonItemView : UIView

@property (nonatomic, strong) UIButton *button;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *label;

@end
