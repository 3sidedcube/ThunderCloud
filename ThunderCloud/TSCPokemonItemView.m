//
//  TSCPokemonCollectionViewCell.m
//  ThunderStorm
//
//  Created by Andrew Hart on 15/11/2013.
//  Copyright (c) 2013 3 SIDED CUBE. All rights reserved.
//

#import "TSCPokemonItemView.h"

@interface TSCPokemonItemView ()

@end

@implementation TSCPokemonItemView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.layer.cornerRadius = 14;
        self.imageView.layer.masksToBounds = YES;
        [self addSubview:self.imageView];
        
        self.button = [[UIButton alloc] initWithFrame:self.bounds];
        self.button.contentMode = UIViewContentModeScaleAspectFit;
        self.button.imageView.hidden = NO;
        [self addSubview:self.button];
        
        self.label = [[UILabel alloc] init];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont systemFontOfSize:10];
        [self addSubview:self.label];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, POKEMON_IMAGE_SIZE.width, POKEMON_IMAGE_SIZE.height);
    self.button.frame = CGRectMake(0, 0, POKEMON_IMAGE_SIZE.width, POKEMON_IMAGE_SIZE.height);
    self.label.frame = CGRectMake(0, self.bounds.size.height - 12, self.bounds.size.width, 12);
}

@end